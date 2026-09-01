import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/garment_model.dart';
import '../repositories/catalog_repository.dart';
import 'catalog_state.dart';

part 'catalog_view_model.g.dart';

/// Owns the garment catalog and which garment is currently previewed.
///
/// Deliberately knows nothing about Decart. Phase 5 layers the realtime
/// session on top by watching [CatalogState.selected] and pushing that
/// garment's prompt and image to the session.
@riverpod
class CatalogViewModel extends _$CatalogViewModel {
  @override
  CatalogState build() => const CatalogState();

  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  Future<void> load() async {
    // A deferred caller can land after the screen is gone.
    if (!ref.mounted) return;
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repo.fetchGarments();

    // The screen can be torn down while the catalog is still loading —
    // writing state after that throws.
    if (!ref.mounted) return;

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        garments: response.data!,
        selectedIndex: 0,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load the catalog',
      );
    }
  }

  /// Selects by index. Out-of-range values are ignored rather than clamped —
  /// a bad index is a caller bug, not a state to render.
  void select(int index) {
    if (!state.hasGarments) return;
    if (index < 0 || index >= state.garments.length) return;
    if (index == state.selectedIndex) return;
    state = state.copyWith(selectedIndex: index);
  }

  void selectById(String id) {
    final index = state.garments.indexWhere((g) => g.id == id);
    if (index != -1) select(index);
  }

  /// Advances one garment, wrapping at the end — matches the web app, where
  /// the catalog is a loop rather than a list with edges.
  void next() {
    if (!state.hasGarments) return;
    state = state.copyWith(
      selectedIndex: (state.selectedIndex + 1) % state.garments.length,
    );
  }

  void previous() {
    if (!state.hasGarments) return;
    final count = state.garments.length;
    state = state.copyWith(
      selectedIndex: (state.selectedIndex - 1 + count) % count,
    );
  }
}

/// The garment currently previewed. Phase 5's try-on session watches this.
///
/// Riverpod compares this provider's own output, so watchers only rebuild
/// when the garment actually changes — not on every catalog state change.
@riverpod
GarmentModel? selectedGarment(Ref ref) =>
    ref.watch(catalogViewModelProvider).selected;
