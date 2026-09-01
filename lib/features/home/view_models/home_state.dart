import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

@immutable
class HomeState {
  final List<ProductModel> products;
  final ProductModel? selectedProduct;
  final bool isLoading;
  final bool isMutating;

  const HomeState({
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.isMutating = false,
  });

  HomeState copyWith({
    List<ProductModel>? products,
    ProductModel? selectedProduct,
    bool? isLoading,
    bool? isMutating,
    bool clearSelected = false,
  }) =>
      HomeState(
        products: products ?? this.products,
        selectedProduct:
            clearSelected ? null : (selectedProduct ?? this.selectedProduct),
        isLoading: isLoading ?? this.isLoading,
        isMutating: isMutating ?? this.isMutating,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          listEquals(products, other.products) &&
          selectedProduct == other.selectedProduct &&
          isLoading == other.isLoading &&
          isMutating == other.isMutating;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(products),
        selectedProduct,
        isLoading,
        isMutating,
      );
}
