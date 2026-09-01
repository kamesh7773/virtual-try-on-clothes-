import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// "LiveLook" set in two weights, matching the web app's masthead.
class LiveLookWordmark extends StatelessWidget {
  final double fontSize;

  const LiveLookWordmark({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize.sp,
          color: AppColors.onStagePrimary,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        children: const [
          TextSpan(text: 'Live', style: TextStyle(fontWeight: FontWeight.w300)),
          TextSpan(text: 'Look', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
