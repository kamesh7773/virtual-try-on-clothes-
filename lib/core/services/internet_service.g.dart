// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internet_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InternetService)
final internetServiceProvider = InternetServiceProvider._();

final class InternetServiceProvider
    extends $NotifierProvider<InternetService, bool> {
  InternetServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'internetServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$internetServiceHash();

  @$internal
  @override
  InternetService create() => InternetService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$internetServiceHash() => r'69b0bc090a1509b812307891e02f9538ca82dbff';

abstract class _$InternetService extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
