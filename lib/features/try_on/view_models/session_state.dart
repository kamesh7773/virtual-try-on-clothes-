import 'package:flutter/foundation.dart';

/// Mirrors `DecartRealtimeConnectionState` on the native side, plus the
/// `idle` the bridge reports once the camera is up but no session exists.
enum DecartStatus {
  /// No session, and the SDK has not been set up yet.
  uninitialized,

  /// Camera is live, ready to connect.
  idle,
  connecting,
  connected,

  /// Connected and actively transforming frames — the state that bills.
  generating,
  reconnecting,
  disconnected,
  error;

  static DecartStatus fromName(String raw) => switch (raw) {
        'idle' => DecartStatus.idle,
        'connecting' => DecartStatus.connecting,
        'connected' => DecartStatus.connected,
        'generating' => DecartStatus.generating,
        'reconnecting' => DecartStatus.reconnecting,
        'disconnected' => DecartStatus.disconnected,
        'error' => DecartStatus.error,
        _ => DecartStatus.uninitialized,
      };
}

@immutable
class SessionState {
  final DecartStatus status;

  /// Set when the session fails, or when the safety timer ends it — the user
  /// needs to know why the stream stopped.
  final String? message;

  /// True from tapping Try On until the native call returns, so the button
  /// cannot be fired twice.
  final bool isBusy;

  const SessionState({
    this.status = DecartStatus.uninitialized,
    this.message,
    this.isBusy = false,
  });

  /// Whether Decart is producing frames worth rendering.
  bool get isLive =>
      status == DecartStatus.connected || status == DecartStatus.generating;

  bool get isConnecting =>
      status == DecartStatus.connecting || status == DecartStatus.reconnecting;

  bool get canConnect =>
      !isBusy &&
      !isLive &&
      status != DecartStatus.connecting &&
      status != DecartStatus.reconnecting;

  SessionState copyWith({
    DecartStatus? status,
    String? message,
    bool? isBusy,
    bool clearMessage = false,
  }) =>
      SessionState(
        status: status ?? this.status,
        message: clearMessage ? null : (message ?? this.message),
        isBusy: isBusy ?? this.isBusy,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionState &&
          status == other.status &&
          message == other.message &&
          isBusy == other.isBusy;

  @override
  int get hashCode => Object.hash(status, message, isBusy);
}
