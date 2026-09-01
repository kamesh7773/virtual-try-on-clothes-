// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wraps `permission_handler` as a Riverpod service. Each helper requests
/// the permission if not yet granted and returns whether access was given.
/// Status helpers (`hasCamera` etc.) check the current state without
/// triggering a system dialog.
///
/// ```dart
/// final granted = await ref
///     .read(permissionServiceProvider.notifier)
///     .requestCamera();
/// ```

@ProviderFor(PermissionService)
final permissionServiceProvider = PermissionServiceProvider._();

/// Wraps `permission_handler` as a Riverpod service. Each helper requests
/// the permission if not yet granted and returns whether access was given.
/// Status helpers (`hasCamera` etc.) check the current state without
/// triggering a system dialog.
///
/// ```dart
/// final granted = await ref
///     .read(permissionServiceProvider.notifier)
///     .requestCamera();
/// ```
final class PermissionServiceProvider
    extends $NotifierProvider<PermissionService, void> {
  /// Wraps `permission_handler` as a Riverpod service. Each helper requests
  /// the permission if not yet granted and returns whether access was given.
  /// Status helpers (`hasCamera` etc.) check the current state without
  /// triggering a system dialog.
  ///
  /// ```dart
  /// final granted = await ref
  ///     .read(permissionServiceProvider.notifier)
  ///     .requestCamera();
  /// ```
  PermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionServiceHash();

  @$internal
  @override
  PermissionService create() => PermissionService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$permissionServiceHash() => r'532253a325c27f2cce001b9548ce30f89554f8a9';

/// Wraps `permission_handler` as a Riverpod service. Each helper requests
/// the permission if not yet granted and returns whether access was given.
/// Status helpers (`hasCamera` etc.) check the current state without
/// triggering a system dialog.
///
/// ```dart
/// final granted = await ref
///     .read(permissionServiceProvider.notifier)
///     .requestCamera();
/// ```

abstract class _$PermissionService extends $Notifier<void> {
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
