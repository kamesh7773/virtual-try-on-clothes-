import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProductThumbnail extends StatelessWidget {
  final String? url;
  final double size;

  const ProductThumbnail({super.key, required this.url, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? _placeholder()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return _placeholder(showSpinner: true);
                },
              ),
      ),
    );
  }

  Widget _placeholder({bool showSpinner = false}) => Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: showSpinner
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.image_outlined,
                color: AppColors.textSecondary,
              ),
      );
}
