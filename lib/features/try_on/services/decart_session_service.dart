import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'decart_session_service.g.dart';

@Riverpod(keepAlive: true)
DecartSessionService decartSessionService(Ref ref) =>
    const DecartSessionService();

/// One state change reported by the native session.
class DecartEvent {
  final String state;
  final String? message;

  const DecartEvent(this.state, this.message);
}

/// Thin wrapper over the native Decart bridge.
///
/// Deliberately dumb: it marshals arguments and surfaces errors, and holds no
/// state of its own. `SessionViewModel` owns what the UI reacts to.
class DecartSessionService {
  const DecartSessionService();

  static const MethodChannel _methods = MethodChannel('livelook/decart');
  static const EventChannel _events = EventChannel('livelook/decart/events');

  /// Connection state and errors pushed from the SDK. These arrive
  /// independently of any call, which is why they are not method results.
  Stream<DecartEvent> get events =>
      _events.receiveBroadcastStream().map((raw) {
        final map = (raw as Map).cast<Object?, Object?>();
        return DecartEvent(
          map['state'] as String? ?? 'error',
          map['message'] as String?,
        );
      });

  /// Creates the client and starts the camera. Idempotent natively, so it is
  /// safe to call whenever the screen appears.
  Future<void> initialize({
    required String apiKey,
    required String baseUrl,
    required String model,
  }) =>
      _methods.invokeMethod<void>('initialize', {
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'model': model,
      });

  /// Opens the session with the first garment applied.
  ///
  /// [autoDisconnectSeconds] caps how long the session may bill for; pass 0
  /// to leave it running until told otherwise.
  Future<void> connect({
    required String prompt,
    Uint8List? image,
    required double autoDisconnectSeconds,
  }) =>
      _methods.invokeMethod<void>('connect', {
        'prompt': prompt,
        'image': image,
        'autoDisconnectSeconds': autoDisconnectSeconds,
      });

  /// Swaps the garment on a live session.
  Future<void> setGarment({
    required String prompt,
    Uint8List? image,
  }) =>
      _methods.invokeMethod<void>('setGarment', {
        'prompt': prompt,
        'image': image,
      });

  Future<void> disconnect() => _methods.invokeMethod<void>('disconnect');
}
