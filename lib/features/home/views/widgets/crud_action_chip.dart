import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Compact pill button used inside [ProductCard] for GET / PUT / DELETE
/// actions. Named to avoid colliding with Material's [ActionChip].
class CrudActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const CrudActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: onTap == null ? 0.05 : 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: onTap == null ? AppColors.textSecondary : tint,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: onTap == null ? AppColors.textSecondary : tint,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
