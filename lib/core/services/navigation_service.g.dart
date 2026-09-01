// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavigationService)
final navigationServiceProvider = NavigationServiceProvider._();

final class NavigationServiceProvider
    extends $NotifierProvider<NavigationService, void> {
  NavigationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationServiceHash();

  @$internal
  @override
  NavigationService create() => NavigationService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$navigationServiceHash() => r'495aaf1e0e7f4f3a18e2616ad646219a815eaeb6';

abstract class _$NavigationService extends $Notifier<void> {
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
