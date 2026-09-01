// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Modern async-init pattern: `build()` returns a `Future` so the provider
/// state is `AsyncValue<SharedPreferences>`. Consumers can either:
///
///   - `await ref.read(storageServiceProvider.future)` to use the instance,
///   - or `ref.watch(storageServiceProvider).when(...)` to react to it.
///
/// Inside the notifier, methods read `future` to get the resolved
/// `SharedPreferences`.

@ProviderFor(StorageService)
final storageServiceProvider = StorageServiceProvider._();

/// Modern async-init pattern: `build()` returns a `Future` so the provider
/// state is `AsyncValue<SharedPreferences>`. Consumers can either:
///
///   - `await ref.read(storageServiceProvider.future)` to use the instance,
///   - or `ref.watch(storageServiceProvider).when(...)` to react to it.
///
/// Inside the notifier, methods read `future` to get the resolved
/// `SharedPreferences`.
final class StorageServiceProvider
    extends $AsyncNotifierProvider<StorageService, SharedPreferences> {
  /// Modern async-init pattern: `build()` returns a `Future` so the provider
  /// state is `AsyncValue<SharedPreferences>`. Consumers can either:
  ///
  ///   - `await ref.read(storageServiceProvider.future)` to use the instance,
  ///   - or `ref.watch(storageServiceProvider).when(...)` to react to it.
  ///
  /// Inside the notifier, methods read `future` to get the resolved
  /// `SharedPreferences`.
  StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  StorageService create() => StorageService();
}

String _$storageServiceHash() => r'5bf376929f6cd2dfb1b7f1a46a2aaa41224af716';

/// Modern async-init pattern: `build()` returns a `Future` so the provider
/// state is `AsyncValue<SharedPreferences>`. Consumers can either:
///
///   - `await ref.read(storageServiceProvider.future)` to use the instance,
///   - or `ref.watch(storageServiceProvider).when(...)` to react to it.
///
/// Inside the notifier, methods read `future` to get the resolved
/// `SharedPreferences`.

abstract class _$StorageService extends $AsyncNotifier<SharedPreferences> {
  FutureOr<SharedPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SharedPreferences>, SharedPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SharedPreferences>, SharedPreferences>,
              AsyncValue<SharedPreferences>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
