import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SignedInBanner extends StatelessWidget {
  final String? name;
  final String? email;

  const SignedInBanner({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? email ?? 'Signed in',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (email != null && name != null)
                  Text(
                    email!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
