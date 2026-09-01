import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Which Decart feed to render.
enum DecartVideoSource {
  /// The phone's own camera, shown before and between sessions.
  local,

  /// Decart's transformed feed. Blank until a session is live.
  remote,

  /// Whichever feed is current. Renders through one native view instead of
  /// stacking two, so only one video renderer ever runs.
  auto,
}

/// Renders a Decart video track through a native view.
///
/// The native side keeps this bound to the session's track across
/// connect/disconnect, so switching between [DecartVideoSource.local] and
/// [DecartVideoSource.remote] is a widget swap, not a camera restart.
class DecartVideoView extends StatelessWidget {
  final DecartVideoSource source;

  const DecartVideoView({super.key, this.source = DecartVideoSource.auto});

  /// Keep in sync with `DecartVideoViewType.id` in the Swift factory.
  static const String viewType = 'livelook/decart_video';

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const _VideoUnavailable();
    }

    return UiKitView(
      // Rebuilding under a new key would tear down the renderer, so each
      // source keeps its own view for the life of the screen.
      key: ValueKey(source),
      viewType: viewType,
      creationParams: <String, dynamic>{'source': source.name},
      creationParamsCodec: const StandardMessageCodec(),
      // Swipe and taps belong to Flutter; the video is not interactive.
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }
}

class _VideoUnavailable extends StatelessWidget {
  const _VideoUnavailable();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.stageSurface,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                size: 32.r,
                color: AppColors.onStageFaint,
              ),
              SizedBox(height: 12.h),
              Text(
                'Live try-on is iOS-only for now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.onStageMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
