import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/dialog_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/product_model.dart';
import '../repositories/home_repository.dart';
import 'home_state.dart';

part 'home_view_model.g.dart';

/// View model for the home (products) screen.
///
/// API outcomes are surfaced via [DialogService] (toasts) and
/// [NotificationService] (system notifications). State holds only data
/// and in-flight flags — messaging is side-effectful.
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() => const HomeState();

  HomeRepository get _repo => ref.read(homeRepositoryProvider);
  DialogService get _dialog => ref.read(dialogServiceProvider.notifier);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider.notifier);

  Future<void> loadProducts({int limit = 20}) async {
    state = state.copyWith(isLoading: true);

    final response = await _repo.fetchProducts(limit: limit);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        products: response.data!,
        isLoading: false,
      );
      final count = response.data!.length;
      _dialog.showSuccess('Loaded $count products');
      await _notify(title: 'Products loaded', body: 'Fetched $count products');
    } else {
      state = state.copyWith(isLoading: false);
      _dialog.showError(response.error ?? 'Failed to load products');
    }
  }

  Future<void> loadProductById(int id) async {
    state = state.copyWith(isMutating: true);

    final response = await _repo.fetchProductById(id);

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        selectedProduct: response.data,
        isMutating: false,
      );
      _dialog.showSuccess('Fetched product #${response.data!.id}');
      await _notify(
        title: 'Product fetched',
        body: response.data!.title ?? 'Product #${response.data!.id}',
      );
    } else {
      state = state.copyWith(isMutating: false);
      _dialog.showError(response.error ?? 'Failed to fetch product');
    }
  }

  Future<void> createProduct({
    required String title,
    required num price,
    required String description,
    int categoryId = 1,
  }) async {
    state = state.copyWith(isMutating: true);

    final response = await _repo.createProduct(
      title: title,
      price: price,
      description: description,
      categoryId: categoryId,
    );

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        products: [response.data!, ...state.products],
        isMutating: false,
      );
      _dialog.showSuccess('Created product #${response.data!.id}');
      await _notify(
        title: 'Product created',
        body: response.data!.title ?? 'Product #${response.data!.id}',
      );
    } else {
      state = state.copyWith(isMutating: false);
      _dialog.showError(response.error ?? 'Failed to create product');
    }
  }

  Future<void> updateProduct({
    required int id,
    String? title,
    num? price,
    String? description,
  }) async {
    state = state.copyWith(isMutating: true);

    final response = await _repo.updateProduct(
      id: id,
      title: title,
      price: price,
      description: description,
    );

    if (response.isSuccess && response.data != null) {
      state = state.copyWith(
        products: _replaceInList(response.data!),
        selectedProduct: state.selectedProduct?.id == id
            ? response.data
            : state.selectedProduct,
        isMutating: false,
      );
      _dialog.showSuccess('Updated product #$id');
      await _notify(title: 'Product updated', body: 'Updated product #$id');
    } else {
      state = state.copyWith(isMutating: false);
      _dialog.showError(response.error ?? 'Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    state = state.copyWith(isMutating: true);

    final response = await _repo.deleteProduct(id);

    if (response.isSuccess) {
      state = state.copyWith(
        products:
            state.products.where((p) => p.id != id).toList(growable: false),
        isMutating: false,
        clearSelected: state.selectedProduct?.id == id,
      );
      _dialog.showSuccess('Deleted product #$id');
      await _notify(title: 'Product deleted', body: 'Removed product #$id');
    } else {
      state = state.copyWith(isMutating: false);
      _dialog.showError(response.error ?? 'Failed to delete product');
    }
  }

  Future<void> _notify({
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 30),
          title: title,
          body: body,
        ),
      );
    } catch (e) {
      debugPrint('HomeViewModel: notification failed: $e');
    }
  }

  List<ProductModel> _replaceInList(ProductModel updated) {
    final next = [...state.products];
    final index = next.indexWhere((p) => p.id == updated.id);
    if (index == -1) return next;
    next[index] = updated;
    return next;
  }
}
