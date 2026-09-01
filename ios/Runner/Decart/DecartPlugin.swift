import Flutter
import Foundation

/// Bridges `DecartSessionBridge` to Dart.
///
/// Commands arrive on a method channel; connection state and errors go back
/// on an event channel, because they originate in the SDK rather than in
/// response to any one call.
final class DecartPlugin: NSObject {
  private static let methodChannelName = "livelook/decart"
  private static let eventChannelName = "livelook/decart/events"

  private var eventSink: FlutterEventSink?

  static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = DecartPlugin()

    let methods = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    methods.setMethodCallHandler { call, result in
      plugin.handle(call, result: result)
    }

    let events = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    events.setStreamHandler(plugin)

    registrar.register(
      DecartVideoViewFactory(),
      withId: DecartVideoViewType.id
    )
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "initialize":
      guard
        let apiKey = args["apiKey"] as? String, !apiKey.isEmpty,
        let baseURL = args["baseUrl"] as? String,
        let model = args["model"] as? String
      else {
        result(invalidArgs("initialize needs apiKey, baseUrl and model"))
        return
      }
      Task { @MainActor in
        do {
          try DecartSessionBridge.shared.initialize(
            apiKey: apiKey,
            baseURL: baseURL,
            modelName: model
          )
          result(nil)
        } catch {
          result(self.failure(error))
        }
      }

    case "connect":
      guard let prompt = args["prompt"] as? String else {
        result(invalidArgs("connect needs a prompt"))
        return
      }
      let image = (args["image"] as? FlutterStandardTypedData)?.data
      let timeout = args["autoDisconnectSeconds"] as? Double ?? 0
      Task { @MainActor in
        do {
          try await DecartSessionBridge.shared.connect(
            prompt: prompt,
            imageData: image,
            autoDisconnectAfter: timeout
          )
          result(nil)
        } catch {
          result(self.failure(error))
        }
      }

    case "setGarment":
      guard let prompt = args["prompt"] as? String else {
        result(invalidArgs("setGarment needs a prompt"))
        return
      }
      let image = (args["image"] as? FlutterStandardTypedData)?.data
      Task { @MainActor in
        do {
          try await DecartSessionBridge.shared.setGarment(
            prompt: prompt,
            imageData: image
          )
          result(nil)
        } catch {
          result(self.failure(error))
        }
      }

    case "disconnect":
      Task { @MainActor in
        await DecartSessionBridge.shared.disconnect()
        result(nil)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func invalidArgs(_ message: String) -> FlutterError {
    FlutterError(code: "invalid_arguments", message: message, details: nil)
  }

  private func failure(_ error: Error) -> FlutterError {
    FlutterError(
      code: "decart_error",
      message: error.localizedDescription,
      details: nil
    )
  }
}

extension DecartPlugin: FlutterStreamHandler {
  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    // Set synchronously: hopping through a Task lets the bridge emit before
    // the sink is wired, and a dropped state event strands the UI mid-connect.
    MainActor.assumeIsolated {
      DecartSessionBridge.shared.onEvent = { [weak self] state, message in
        var payload: [String: Any] = ["state": state]
        if let message { payload["message"] = message }
        // Event sinks must be fed from the platform thread.
        DispatchQueue.main.async {
          self?.eventSink?(payload)
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    MainActor.assumeIsolated {
      DecartSessionBridge.shared.onEvent = nil
    }
    return nil
  }
}
