import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

@immutable
class AuthState {
  final AuthStatus status;
  final UserModel? user;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading =>
      status == AuthStatus.authenticating || status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool clearUser = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: clearUser ? null : (user ?? this.user),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState && status == other.status && user == other.user;

  @override
  int get hashCode => Object.hash(status, user);
}
