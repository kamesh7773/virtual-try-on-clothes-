// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Secure key-value storage backed by Keychain (iOS) / EncryptedSharedPrefs
/// migration target (Android v10+). Exposed as a Riverpod service so it can
/// be injected like any other dependency:
///
/// ```dart
/// final token = await ref.read(secureStorageServiceProvider.notifier).getToken();
/// ```

@ProviderFor(SecureStorageService)
final secureStorageServiceProvider = SecureStorageServiceProvider._();

/// Secure key-value storage backed by Keychain (iOS) / EncryptedSharedPrefs
/// migration target (Android v10+). Exposed as a Riverpod service so it can
/// be injected like any other dependency:
///
/// ```dart
/// final token = await ref.read(secureStorageServiceProvider.notifier).getToken();
/// ```
final class SecureStorageServiceProvider
    extends $NotifierProvider<SecureStorageService, void> {
  /// Secure key-value storage backed by Keychain (iOS) / EncryptedSharedPrefs
  /// migration target (Android v10+). Exposed as a Riverpod service so it can
  /// be injected like any other dependency:
  ///
  /// ```dart
  /// final token = await ref.read(secureStorageServiceProvider.notifier).getToken();
  /// ```
  SecureStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageServiceHash();

  @$internal
  @override
  SecureStorageService create() => SecureStorageService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$secureStorageServiceHash() =>
    r'0f929272bdd048b85075e37e0f9c85b3d9177e82';

/// Secure key-value storage backed by Keychain (iOS) / EncryptedSharedPrefs
/// migration target (Android v10+). Exposed as a Riverpod service so it can
/// be injected like any other dependency:
///
/// ```dart
/// final token = await ref.read(secureStorageServiceProvider.notifier).getToken();
/// ```

abstract class _$SecureStorageService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
