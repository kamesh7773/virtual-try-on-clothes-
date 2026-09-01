import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routes/route_arguments.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/dialog_service.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../models/product_model.dart';
import '../view_models/home_state.dart';
import '../view_models/home_view_model.dart';
import 'widgets/product_card.dart';
import 'widgets/product_form.dart';
import 'widgets/signed_in_banner.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);
    final user = ref.watch(authViewModelProvider).user;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadProducts();
      });
      return null;
    }, const []);

    Future<ProductFormResult?> showProductFormSheet({
      required String title,
      String initialTitle = '',
      String initialPrice = '',
      String initialDescription = '',
      required String submitLabel,
    }) {
      return showModalBottomSheet<ProductFormResult>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: ProductForm(
            title: title,
            initialTitle: initialTitle,
            initialPrice: initialPrice,
            initialDescription: initialDescription,
            submitLabel: submitLabel,
          ),
        ),
      );
    }

    Future<void> showCreateSheet() async {
      final result = await showProductFormSheet(
        title: 'Create Product (POST)',
        submitLabel: 'Create',
      );
      if (result == null) return;
      await vm.createProduct(
        title: result.title,
        price: result.price,
        description: result.description,
      );
    }

    Future<void> showEditSheet(ProductModel product) async {
      final result = await showProductFormSheet(
        title: 'Update Product #${product.id} (PUT)',
        initialTitle: product.title ?? '',
        initialPrice: product.price?.toString() ?? '',
        initialDescription: product.description ?? '',
        submitLabel: 'Update',
      );
      if (result == null) return;
      await vm.updateProduct(
        id: product.id!,
        title: result.title,
        price: result.price,
        description: result.description,
      );
    }

    Future<void> confirmDelete(ProductModel product) async {
      final confirmed = await ref
          .read(dialogServiceProvider.notifier)
          .showConfirmation(
            title: 'Delete product?',
            message: 'DELETE /products/${product.id}',
            confirmText: 'Delete',
          );
      if (!confirmed) return;
      await vm.deleteProduct(product.id!);
    }

    Future<void> confirmLogout() async {
      final confirmed = await ref
          .read(dialogServiceProvider.notifier)
          .showConfirmation(
            title: 'Sign out?',
            message: 'You will need to sign in again to make changes.',
            confirmText: 'Sign out',
          );
      if (!confirmed) return;
      await ref.read(authViewModelProvider.notifier).logout();
      if (!context.mounted) return;
      await ref
          .read(navigationServiceProvider.notifier)
          .pushNamedAndRemoveUntil(
            Routes.login,
            arguments: const LoginScreenArgs(fromLogout: true),
          );
    }

    return AppScaffold(
      appBar: CustomAppBar(
        title: 'Products',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'GET /products',
            onPressed: state.isLoading ? null : () => vm.loadProducts(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: confirmLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isMutating ? null : showCreateSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('POST', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadProducts(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (user != null)
              SignedInBanner(name: user.name, email: user.email),
            if (user != null) const SizedBox(height: 12),
            _Header(isLoading: state.isLoading),
            const SizedBox(height: 12),
            _Body(
              state: state,
              onLoad: () => vm.loadProducts(),
              onView: (product) => vm.loadProductById(product.id!),
              onEdit: showEditSheet,
              onDelete: confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isLoading;

  const _Header({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
        const SizedBox(width: 8),
        const Text(
          'Products (CRUD)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (isLoading)
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final HomeState state;
  final VoidCallback onLoad;
  final ValueChanged<ProductModel> onView;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;

  const _Body({
    required this.state,
    required this.onLoad,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            const Text('No products loaded yet.'),
            const SizedBox(height: 12),
            CustomButton(
              text: 'GET /products',
              icon: Icons.cloud_download,
              onPressed: onLoad,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final product in state.products) ...[
          ProductCard(
            product: product,
            isBusy: state.isMutating,
            onView: () => onView(product),
            onEdit: () => onEdit(product),
            onDelete: () => onDelete(product),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
