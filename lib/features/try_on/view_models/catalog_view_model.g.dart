// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the garment catalog and which garment is currently previewed.
///
/// Deliberately knows nothing about Decart. Phase 5 layers the realtime
/// session on top by watching [CatalogState.selected] and pushing that
/// garment's prompt and image to the session.

@ProviderFor(CatalogViewModel)
final catalogViewModelProvider = CatalogViewModelProvider._();

/// Owns the garment catalog and which garment is currently previewed.
///
/// Deliberately knows nothing about Decart. Phase 5 layers the realtime
/// session on top by watching [CatalogState.selected] and pushing that
/// garment's prompt and image to the session.
final class CatalogViewModelProvider
    extends $NotifierProvider<CatalogViewModel, CatalogState> {
  /// Owns the garment catalog and which garment is currently previewed.
  ///
  /// Deliberately knows nothing about Decart. Phase 5 layers the realtime
  /// session on top by watching [CatalogState.selected] and pushing that
  /// garment's prompt and image to the session.
  CatalogViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogViewModelHash();

  @$internal
  @override
  CatalogViewModel create() => CatalogViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogState>(value),
    );
  }
}

String _$catalogViewModelHash() => r'2e4e3cc430f0fa4fc821dbd77d689d4479404aff';

/// Owns the garment catalog and which garment is currently previewed.
///
/// Deliberately knows nothing about Decart. Phase 5 layers the realtime
/// session on top by watching [CatalogState.selected] and pushing that
/// garment's prompt and image to the session.

abstract class _$CatalogViewModel extends $Notifier<CatalogState> {
  CatalogState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CatalogState, CatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CatalogState, CatalogState>,
              CatalogState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The garment currently previewed. Phase 5's try-on session watches this.
///
/// Riverpod compares this provider's own output, so watchers only rebuild
/// when the garment actually changes — not on every catalog state change.

@ProviderFor(selectedGarment)
final selectedGarmentProvider = SelectedGarmentProvider._();

/// The garment currently previewed. Phase 5's try-on session watches this.
///
/// Riverpod compares this provider's own output, so watchers only rebuild
/// when the garment actually changes — not on every catalog state change.

final class SelectedGarmentProvider
    extends $FunctionalProvider<GarmentModel?, GarmentModel?, GarmentModel?>
    with $Provider<GarmentModel?> {
  /// The garment currently previewed. Phase 5's try-on session watches this.
  ///
  /// Riverpod compares this provider's own output, so watchers only rebuild
  /// when the garment actually changes — not on every catalog state change.
  SelectedGarmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedGarmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedGarmentHash();

  @$internal
  @override
  $ProviderElement<GarmentModel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GarmentModel? create(Ref ref) {
    return selectedGarment(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GarmentModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GarmentModel?>(value),
    );
  }
}

String _$selectedGarmentHash() => r'7250b87018cde2f361bc3a7c596db2d9fccf9cd4';
