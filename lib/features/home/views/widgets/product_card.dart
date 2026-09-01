import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import 'crud_action_chip.dart';
import 'product_thumbnail.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isBusy;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.isBusy,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductThumbnail(url: product.primaryImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${product.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (product.price != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${product.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.title ?? '(no title)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.categoryName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.categoryName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (product.description != null) ...[
              const SizedBox(height: 8),
              Text(
                product.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CrudActionChip(
                  label: 'GET',
                  icon: Icons.visibility,
                  onTap: isBusy ? null : onView,
                ),
                CrudActionChip(
                  label: 'PUT',
                  icon: Icons.edit_note,
                  onTap: isBusy ? null : onEdit,
                ),
                CrudActionChip(
                  label: 'DELETE',
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: isBusy ? null : onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
