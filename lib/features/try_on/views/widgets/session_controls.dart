import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../view_models/session_state.dart';

/// Start/stop control for the try-on session, plus the live indicator.
///
/// A session bills for as long as it runs, so stopping is always one tap away
/// and the live state is never ambiguous.
class SessionControls extends StatelessWidget {
  final SessionState session;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const SessionControls({
    super.key,
    required this.session,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (session.isLive) {
      return _Button(
        label: 'END SESSION',
        filled: false,
        onPressed: onStop,
      );
    }

    if (session.isConnecting || session.isBusy) {
      return const _Button(label: 'CONNECTING', filled: true, isBusy: true);
    }

    return _Button(
      label: session.status == DecartStatus.error ? 'RETRY' : 'TRY IT ON',
      filled: true,
      onPressed: onStart,
    );
  }
}

class _Button extends StatelessWidget {
  final String label;
  final bool filled;
  final bool isBusy;
  final VoidCallback? onPressed;

  const _Button({
    required this.label,
    required this.filled,
    this.isBusy = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        filled ? AppColors.stageBackground : AppColors.onStagePrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.onStagePrimary : Colors.transparent,
            border: Border.all(
              color: filled
                  ? AppColors.onStagePrimary
                  : AppColors.stageBorderActive,
            ),
          ),
          child: isBusy
              ? SizedBox(
                  width: 14.r,
                  height: 14.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: foreground,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: foreground,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Small pulsing "LIVE" marker shown over the stream.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      color: Colors.black.withValues(alpha: 0.45),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: const BoxDecoration(
              color: AppColors.live,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 8.sp,
              color: AppColors.live,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
