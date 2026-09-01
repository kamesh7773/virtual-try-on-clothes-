import 'package:flutter/foundation.dart';

import '../models/garment_model.dart';

@immutable
class CatalogState {
  final List<GarmentModel> garments;
  final int selectedIndex;
  final bool isLoading;
  final String? error;

  const CatalogState({
    this.garments = const [],
    this.selectedIndex = 0,
    this.isLoading = false,
    this.error,
  });

  bool get hasGarments => garments.isNotEmpty;

  /// Currently previewed garment, or `null` before the catalog loads.
  GarmentModel? get selected =>
      hasGarments && selectedIndex >= 0 && selectedIndex < garments.length
          ? garments[selectedIndex]
          : null;

  /// 1-based position for display, e.g. "3 / 8".
  int get displayPosition => hasGarments ? selectedIndex + 1 : 0;
  int get total => garments.length;

  CatalogState copyWith({
    List<GarmentModel>? garments,
    int? selectedIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      CatalogState(
        garments: garments ?? this.garments,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogState &&
          listEquals(garments, other.garments) &&
          selectedIndex == other.selectedIndex &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(garments),
        selectedIndex,
        isLoading,
        error,
      );
}
