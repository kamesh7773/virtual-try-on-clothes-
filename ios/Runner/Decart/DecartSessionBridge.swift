import AVFoundation
import DecartSDK
import Foundation
import LiveKit

/// Which feed a video view is showing.
enum DecartVideoSource: String {
  /// The phone's own camera, before or alongside a session.
  case local
  /// Decart's transformed feed. Only carries a track while connected.
  case remote
  /// Whichever feed is current — remote once a session produces one, the
  /// camera otherwise. One view instead of two means one renderer running.
  case auto
}

/// Owns the Decart realtime session for the whole app.
///
/// The SDK takes ownership of the camera (`createLocalCameraStream` builds the
/// capture track), so this replaces the standalone AVCaptureSession preview
/// used before Decart was wired in — two owners of the camera do not coexist.
///
/// `@MainActor` because `createLocalCameraStream` is main-actor bound and every
/// video view it feeds is a UIView.
@MainActor
final class DecartSessionBridge {
  static let shared = DecartSessionBridge()

  private var client: DecartClient?
  private var model: ModelDefinition?
  private var manager: DecartRealtimeManager?

  private var localStream: RealtimeMediaStream?
  private var remoteStream: RealtimeMediaStream?

  private var eventTask: Task<Void, Never>?
  private var remoteStreamTask: Task<Void, Never>?
  private var autoDisconnectTask: Task<Void, Never>?

  /// Views waiting to be handed a track. Held weakly so a disposed platform
  /// view does not keep its renderer alive.
  private var views: [WeakVideoView] = []

  /// Emits `(state, message)` for the Dart event channel.
  var onEvent: ((String, String?) -> Void)?

  private init() {}

  // MARK: - Setup

  /// Builds the client and starts the camera. Safe to call more than once;
  /// only the first call does work.
  func initialize(apiKey: String, baseURL: String, modelName: String) throws {
    if client != nil { return }

    guard let realtimeModel = RealtimeModel(rawValue: modelName) else {
      throw DecartError.modelNotFound(modelName)
    }

    let resolved = Models.realtime(realtimeModel)
    let created = DecartClient(
      decartConfiguration: DecartConfiguration(baseURL: baseURL, apiKey: apiKey)
    )

    client = created
    model = resolved
    localStream = created.createLocalCameraStream(model: resolved, mirror: .auto)

    rebindViews()
    emit(state: "idle")
  }

  var isConnected: Bool {
    manager != nil
  }

  // MARK: - Session

  /// Connects and applies the first garment. `imageData` is the garment shot;
  /// without it the model works from the prompt alone.
  func connect(
    prompt: String,
    imageData: Data?,
    autoDisconnectAfter seconds: Double
  ) async throws {
    guard let client, let model else {
      throw DecartError.invalidOptions("initialize() must run before connect()")
    }
    if manager != nil { return }

    emit(state: "connecting")

    let stream = localStream ?? client.createLocalCameraStream(
      model: model,
      mirror: .auto
    )
    localStream = stream

    let created = try client.createRealtimeManager(
      options: RealtimeConfiguration(
        model: model,
        initialPrompt: DecartPrompt(
          text: prompt,
          referenceImageData: imageData,
          enrich: false
        )
      )
    )
    manager = created

    observe(created)

    do {
      remoteStream = try await created.connect(localStream: stream)
      rebindViews()
      scheduleAutoDisconnect(after: seconds)
    } catch {
      manager = nil
      cancelObservation()
      // The room may have started publishing before it failed, which stops
      // the capture track and would strand the preview on a frozen frame.
      await restartLocalCamera()
      rebindViews()
      emit(state: "error", message: describe(error))
      throw error
    }
  }

  /// Swaps the garment on a live session.
  func setGarment(prompt: String, imageData: Data?) async throws {
    guard let manager else {
      throw DecartError.invalidOptions("no active session")
    }
    try await manager.setPrompt(
      DecartPrompt(text: prompt, referenceImageData: imageData, enrich: false)
    )
  }

  func disconnect() async {
    autoDisconnectTask?.cancel()
    autoDisconnectTask = nil

    if let manager {
      await manager.disconnect()
    }
    manager = nil
    remoteStream = nil
    cancelObservation()

    await restartLocalCamera()

    rebindViews()
    emit(state: "disconnected")
  }

  /// Rebuilds the capture track after a session ends.
  ///
  /// The local track is published into the LiveKit room, and closing the room
  /// stops it. The track object survives, so the preview keeps rendering its
  /// last frame and looks frozen — only a fresh capture track brings the
  /// camera back.
  private func restartLocalCamera() async {
    if let previous = localStream?.videoTrack as? LocalVideoTrack {
      // Release the camera before claiming it again; two capturers on one
      // device do not coexist.
      try? await previous.stop()
    }
    localStream = nil

    views.removeAll { $0.value == nil }

    // Disconnecting also happens when the screen goes away. Reopening the
    // camera then would hold the device — and its recording indicator — open
    // with nothing rendering it.
    guard !views.isEmpty, let client, let model else { return }

    localStream = client.createLocalCameraStream(model: model, mirror: .auto)
  }

  // MARK: - Observation

  private func observe(_ manager: DecartRealtimeManager) {
    cancelObservation()

    eventTask = Task { [weak self] in
      for await state in manager.events {
        guard let self else { return }
        await self.handle(state)
      }
    }

    remoteStreamTask = Task { [weak self] in
      for await stream in manager.remoteStreamUpdates {
        guard let self else { return }
        await self.handleRemote(stream)
      }
    }
  }

  private func handle(_ state: DecartRealtimeState) {
    emit(state: state.connectionState.rawValue.lowercased())
  }

  private func handleRemote(_ stream: RealtimeMediaStream) {
    remoteStream = stream
    rebindViews()
  }

  private func cancelObservation() {
    eventTask?.cancel()
    eventTask = nil
    remoteStreamTask?.cancel()
    remoteStreamTask = nil
  }

  /// A live session bills continuously, so it is not left running on a screen
  /// nobody is watching. Zero or less disables the cap.
  private func scheduleAutoDisconnect(after seconds: Double) {
    autoDisconnectTask?.cancel()
    guard seconds > 0 else { return }

    autoDisconnectTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(seconds))
      guard !Task.isCancelled, let self else { return }
      await self.disconnect()
      self.emit(
        state: "disconnected",
        message: "Session ended automatically after \(Int(seconds))s to limit credit use."
      )
    }
  }

  // MARK: - Views

  func register(_ view: DecartVideoPlatformView) {
    views.removeAll { $0.value == nil }
    views.append(WeakVideoView(value: view))
    view.attach(track(for: view.source))
  }

  func unregister(_ view: DecartVideoPlatformView) {
    views.removeAll { $0.value == nil || $0.value === view }
  }

  private func rebindViews() {
    views.removeAll { $0.value == nil }
    for box in views {
      guard let view = box.value else { continue }
      view.attach(track(for: view.source))
    }
  }

  private func track(for source: DecartVideoSource) -> VideoTrack? {
    switch source {
    case .local: return localStream?.videoTrack
    case .remote: return remoteStream?.videoTrack
    case .auto: return remoteStream?.videoTrack ?? localStream?.videoTrack
    }
  }

  // MARK: - Helpers

  private func emit(state: String, message: String? = nil) {
    onEvent?(state, message)
  }

  private func describe(_ error: Error) -> String {
    if let decart = error as? DecartError {
      return decart.errorDescription ?? String(describing: decart)
    }
    return error.localizedDescription
  }
}

private struct WeakVideoView {
  weak var value: DecartVideoPlatformView?
}
