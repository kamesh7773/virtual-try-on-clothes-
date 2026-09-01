import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/dialog_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

part 'auth_view_model.g.dart';

/// Owns the authenticated session.
///
/// - `bootstrap()` is called once at app start by [AuthGate]. It reads the
///   stored access token, calls `/auth/profile` to verify it's still valid,
///   and flips state to authenticated/unauthenticated accordingly.
/// - `login()` exchanges credentials for tokens, persists them, then loads
///   the profile. Toasts surface success/failure via [DialogService].
/// - `logout()` clears stored tokens and flips state back to unauthenticated.
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SecureStorageService get _storage =>
      ref.read(secureStorageServiceProvider.notifier);
  DialogService get _dialog => ref.read(dialogServiceProvider.notifier);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider.notifier);

  /// Runs on app start. Decides whether to land on home or login.
  Future<void> bootstrap() async {
    final token = await _storage.getToken();
    if (token == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      );
      return;
    }

    final response = await _repo.fetchProfile();
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data,
      );
      await _notifications.requestPermission();
    } else {
      await _storage.deleteTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      );
    }
  }

  /// POST /auth/login → store tokens → GET /auth/profile.
  /// Returns `true` on success so the caller can navigate if needed.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);

    final tokensResp = await _repo.login(email: email, password: password);
    if (!tokensResp.isSuccess || tokensResp.data == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      );
      _dialog.showError(tokensResp.error ?? 'Login failed');
      return false;
    }

    await _storage.saveToken(tokensResp.data!.accessToken);
    await _storage.saveRefreshToken(tokensResp.data!.refreshToken);

    final profile = await _repo.fetchProfile();
    if (!profile.isSuccess || profile.data == null) {
      await _storage.deleteTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      );
      _dialog.showError(profile.error ?? 'Could not load profile');
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: profile.data,
    );
    await _notifications.requestPermission();
    final greeting = profile.data!.name ?? profile.data!.email ?? 'back';
    _dialog.showSuccess('Welcome, $greeting');
    await _notify(
      title: 'Signed in',
      body: 'Logged in as ${profile.data!.email ?? greeting}',
    );
    return true;
  }

  /// Clears tokens and resets state. The auth gate will rebuild to login.
  Future<void> logout() async {
    await _storage.deleteTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
    _dialog.showInfo('Signed out');
  }

  Future<void> _notify({
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 30),
          title: title,
          body: body,
        ),
      );
    } catch (_) {
      // Notification permission may not be granted — silently ignore.
    }
  }
}
