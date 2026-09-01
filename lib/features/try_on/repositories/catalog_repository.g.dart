// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bundle assets are read through.
///
/// Injected rather than reaching for `rootBundle` directly so tests can supply
/// their own: real asset I/O never completes under a widget test's fake clock,
/// which leaves the catalog stuck loading forever.

@ProviderFor(assetBundle)
final assetBundleProvider = AssetBundleProvider._();

/// The bundle assets are read through.
///
/// Injected rather than reaching for `rootBundle` directly so tests can supply
/// their own: real asset I/O never completes under a widget test's fake clock,
/// which leaves the catalog stuck loading forever.

final class AssetBundleProvider
    extends $FunctionalProvider<AssetBundle, AssetBundle, AssetBundle>
    with $Provider<AssetBundle> {
  /// The bundle assets are read through.
  ///
  /// Injected rather than reaching for `rootBundle` directly so tests can supply
  /// their own: real asset I/O never completes under a widget test's fake clock,
  /// which leaves the catalog stuck loading forever.
  AssetBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetBundleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetBundleHash();

  @$internal
  @override
  $ProviderElement<AssetBundle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetBundle create(Ref ref) {
    return assetBundle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetBundle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetBundle>(value),
    );
  }
}

String _$assetBundleHash() => r'05918ac73d48cecb019264aef4f8b20db4807660';

@ProviderFor(catalogRepository)
final catalogRepositoryProvider = CatalogRepositoryProvider._();

final class CatalogRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogRepository,
          CatalogRepository,
          CatalogRepository
        >
    with $Provider<CatalogRepository> {
  CatalogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogRepository create(Ref ref) {
    return catalogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogRepository>(value),
    );
  }
}

String _$catalogRepositoryHash() => r'359831c85fdfb29fc3763bc855960e0e17ef3a57';
