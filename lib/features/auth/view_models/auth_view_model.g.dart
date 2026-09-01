// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the authenticated session.
///
/// - `bootstrap()` is called once at app start by [AuthGate]. It reads the
///   stored access token, calls `/auth/profile` to verify it's still valid,
///   and flips state to authenticated/unauthenticated accordingly.
/// - `login()` exchanges credentials for tokens, persists them, then loads
///   the profile. Toasts surface success/failure via [DialogService].
/// - `logout()` clears stored tokens and flips state back to unauthenticated.

@ProviderFor(AuthViewModel)
final authViewModelProvider = AuthViewModelProvider._();

/// Owns the authenticated session.
///
/// - `bootstrap()` is called once at app start by [AuthGate]. It reads the
///   stored access token, calls `/auth/profile` to verify it's still valid,
///   and flips state to authenticated/unauthenticated accordingly.
/// - `login()` exchanges credentials for tokens, persists them, then loads
///   the profile. Toasts surface success/failure via [DialogService].
/// - `logout()` clears stored tokens and flips state back to unauthenticated.
final class AuthViewModelProvider
    extends $NotifierProvider<AuthViewModel, AuthState> {
  /// Owns the authenticated session.
  ///
  /// - `bootstrap()` is called once at app start by [AuthGate]. It reads the
  ///   stored access token, calls `/auth/profile` to verify it's still valid,
  ///   and flips state to authenticated/unauthenticated accordingly.
  /// - `login()` exchanges credentials for tokens, persists them, then loads
  ///   the profile. Toasts surface success/failure via [DialogService].
  /// - `logout()` clears stored tokens and flips state back to unauthenticated.
  AuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authViewModelHash();

  @$internal
  @override
  AuthViewModel create() => AuthViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authViewModelHash() => r'5f3bf387d8852f90eb2372e1a4e02a18e8d246f4';

/// Owns the authenticated session.
///
/// - `bootstrap()` is called once at app start by [AuthGate]. It reads the
///   stored access token, calls `/auth/profile` to verify it's still valid,
///   and flips state to authenticated/unauthenticated accordingly.
/// - `login()` exchanges credentials for tokens, persists them, then loads
///   the profile. Toasts surface success/failure via [DialogService].
/// - `logout()` clears stored tokens and flips state back to unauthenticated.

abstract class _$AuthViewModel extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
