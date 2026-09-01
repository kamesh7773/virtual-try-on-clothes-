import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/env.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/garment_model.dart';
import '../repositories/catalog_repository.dart';
import '../services/decart_session_service.dart';
import 'session_state.dart';

part 'session_view_model.g.dart';

/// Owns the live Decart session.
///
/// Knows which garment is on screen only because the caller passes it in —
/// the catalog stays independent so it keeps working with no session at all.
@riverpod
class SessionViewModel extends _$SessionViewModel {
  /// A live session bills the whole time it runs, so it is capped. The web app
  /// used the same one-minute limit for the same reason.
  static const double autoDisconnectSeconds = 60;

  /// Ceiling on how long a connect may sit before it is called off. Without
  /// it a stalled handshake pins the UI in `connecting`, where the button is
  /// disabled and only restarting the app recovers.
  static const Duration connectTimeout = Duration(seconds: 45);

  /// Swiping through the strip would otherwise fire one prompt-and-image
  /// upload per step. Only the garment the user settles on is sent.
  static const Duration garmentDebounce = Duration(milliseconds: 350);

  StreamSubscription<DecartEvent>? _events;
  Timer? _garmentTimer;

  /// Guards setup independently of [state]: the status only reaches `idle`
  /// once the native side reports back, and two calls could race in between.
  bool _prepared = false;

  @override
  SessionState build() {
    // Resolved up front: `ref` cannot be used inside a lifecycle callback, so
    // the dispose handler has to close over the service instead of reading it.
    final service = ref.read(decartSessionServiceProvider);

    ref.onDispose(() {
      _garmentTimer?.cancel();
      _events?.cancel();
      // Fire-and-forget: the provider is going away and cannot await. Leaving
      // a session running would keep billing after the screen is gone.
      unawaited(service.disconnect());
    });

    return const SessionState();
  }

  DecartSessionService get _service => ref.read(decartSessionServiceProvider);

  /// Prepares the SDK and starts the camera. Called when the screen appears,
  /// so the preview is live before anyone taps Try On.
  Future<void> prepare() async {
    if (_prepared) return;
    _prepared = true;

    final apiKey = await _resolveApiKey();
    if (!ref.mounted) return;

    if (apiKey == null || apiKey.isEmpty) {
      _prepared = false;
      state = state.copyWith(
        status: DecartStatus.error,
        message: 'No Decart API key configured for this build.',
      );
      return;
    }

    _listen();

    try {
      await _service.initialize(
        apiKey: apiKey,
        baseUrl: Env.apiBaseUrl,
        model: Env.realtimeModel,
      );
      if (!ref.mounted) return;
      // The camera is live and nothing is billing yet.
      state = state.copyWith(status: DecartStatus.idle, clearMessage: true);
    } catch (e) {
      // Let the user retry rather than stranding the screen.
      _prepared = false;
      if (!ref.mounted) return;
      state = state.copyWith(
        status: DecartStatus.error,
        message: _describe(e, fallback: 'Could not start the camera'),
      );
    }
  }

  /// Opens the session with [garment] applied.
  Future<void> start(GarmentModel garment) async {
    if (!state.canConnect) return;
    state = state.copyWith(
      isBusy: true,
      status: DecartStatus.connecting,
      clearMessage: true,
    );

    try {
      await _service
          .connect(
            prompt: garment.prompt,
            image: await _garmentBytes(garment),
            autoDisconnectSeconds: autoDisconnectSeconds,
          )
          .timeout(connectTimeout);
      if (!ref.mounted) return;
      // Claim `connected` here rather than waiting for an event. A dropped or
      // late state event used to leave the screen stuck on "CONNECTING"
      // forever; events still refine this to `generating`.
      state = state.copyWith(isBusy: false, status: DecartStatus.connected);
    } on TimeoutException {
      if (!ref.mounted) return;
      unawaited(_service.disconnect());
      state = state.copyWith(
        isBusy: false,
        status: DecartStatus.error,
        message: 'Decart did not respond in time. Tap retry.',
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isBusy: false,
        status: DecartStatus.error,
        message: _describe(e, fallback: 'Could not start the try-on session'),
      );
    }
  }

  /// Pushes a new garment onto a running session. A no-op when nothing is
  /// live, so the catalog can be browsed freely while disconnected.
  void applyGarment(GarmentModel garment) {
    if (!state.isLive) return;

    _garmentTimer?.cancel();
    _garmentTimer = Timer(garmentDebounce, () => unawaited(_push(garment)));
  }

  Future<void> _push(GarmentModel garment) async {
    if (!ref.mounted || !state.isLive) return;

    try {
      await _service.setGarment(
        prompt: garment.prompt,
        image: await _garmentBytes(garment),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        message: _describe(e, fallback: 'Could not switch garment'),
      );
    }
  }

  Future<void> stop() async {
    try {
      await _service.disconnect();
    } catch (_) {
      // Nothing useful to tell the user — the session is over either way.
    }
    if (!ref.mounted) return;
    state = state.copyWith(status: DecartStatus.idle, clearMessage: true);
  }

  void _listen() {
    _events?.cancel();
    _events = _service.events.listen(
      (event) {
        if (!ref.mounted) return;
        final status = DecartStatus.fromName(event.state);
        state = state.copyWith(
          status: status,
          message: event.message,
          // A message-only event (the auto-disconnect notice) should not
          // clear itself on the next state change.
          clearMessage: event.message == null && status != DecartStatus.error,
        );
      },
      onError: (Object error) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: DecartStatus.error,
          message: error.toString(),
        );
      },
    );
  }

  String _describe(Object error, {required String fallback}) => switch (error) {
        MissingPluginException() => 'Live try-on is not available on this '
            'platform yet.',
        PlatformException(:final message?) => message,
        _ => fallback,
      };

  /// A user-supplied key wins over the build-time one, matching how the Dio
  /// client resolves it.
  Future<String?> _resolveApiKey() async {
    try {
      final stored =
          await ref.read(secureStorageServiceProvider.notifier).getApiKey();
      if (stored != null && stored.isNotEmpty) return stored;
    } catch (_) {
      // The Keychain can fail (locked device, missing entitlement). Falling
      // back beats refusing to start over a lookup that is only an override.
    }
    return Env.decartApiKey;
  }

  /// Loads the garment shot that rides along with the prompt. A missing image
  /// is not fatal — the model still works from the prompt alone.
  Future<Uint8List?> _garmentBytes(GarmentModel garment) async {
    try {
      final data = await ref.read(assetBundleProvider).load(garment.image);
      return data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
    } catch (_) {
      return null;
    }
  }
}
