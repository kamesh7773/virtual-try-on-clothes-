import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/garment_model.dart';

/// Small card floating over the camera showing which garment is queued up.
///
/// The web app had room for a full-height product column beside the stream;
/// on a phone the stream takes the whole width, so the garment rides on top
/// of it instead.
class GarmentOverlayCard extends StatelessWidget {
  final GarmentModel garment;

  const GarmentOverlayCard({super.key, required this.garment});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.18, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(garment.id),
        width: 68.w,
        decoration: BoxDecoration(
          color: AppColors.stageElevated,
          border: Border.all(color: AppColors.stageBorderActive),
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Image.asset(
            garment.image,
            // The source shots are 1920x2880. Decoding all 5.5 megapixels for
            // a thumbnail this size wastes memory and stalls frames.
            cacheWidth: 320,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              Icons.checkroom_outlined,
              size: 22.r,
              color: AppColors.onStageFaint,
            ),
          ),
        ),
      ),
    );
  }
}
