import Flutter
import LiveKit
import UIKit

enum DecartVideoViewType {
  /// Keep in sync with `DecartVideoView.viewType` on the Dart side.
  static let id = "livelook/decart_video"
}

/// Builds one `DecartVideoPlatformView` per `UiKitView` in the widget tree.
final class DecartVideoViewFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let raw = (args as? [String: Any])?["source"] as? String ?? ""
    let source = DecartVideoSource(rawValue: raw) ?? .local
    return DecartVideoPlatformView(source: source)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

/// Renders one Decart video feed inside the Flutter widget tree.
///
/// The track is not owned here: `DecartSessionBridge` hands one over whenever
/// the session produces or drops it, so this view survives connect/disconnect
/// without being rebuilt.
final class DecartVideoPlatformView: NSObject, FlutterPlatformView {
  let source: DecartVideoSource

  private let videoView = VideoView()

  init(source: DecartVideoSource) {
    self.source = source
    super.init()

    // Flutter creates platform views on the platform thread, which is the main
    // thread — so the main-actor work below is safe to assume rather than hop
    // to, and the view is configured before its first frame.
    MainActor.assumeIsolated {
      videoView.backgroundColor = .black
      // Fill rather than letterbox: this is a mirror, and black bars around a
      // person read as a bug.
      videoView.layoutMode = .fill
      // The capture track already carries MirroringVideoProcessor; mirroring
      // again here would undo it.
      videoView.mirrorMode = .off

      DecartSessionBridge.shared.register(self)
    }
  }

  func view() -> UIView {
    videoView
  }

  /// Called by the bridge on the main actor.
  @MainActor
  func attach(_ track: VideoTrack?) {
    videoView.track = track
  }

  deinit {
    let view = videoView
    Task { @MainActor in
      view.track = nil
    }
  }
}
