import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/garment_model.dart';

/// Horizontally scrolling garment picker. Keeps the active item centred as
/// the selection moves, so swiping the preview and tapping the strip stay in
/// agreement.
class GarmentStrip extends HookWidget {
  final List<GarmentModel> garments;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const GarmentStrip({
    super.key,
    required this.garments,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const double _itemWidth = 64;
  static const double _itemGap = 10;
  static const double _itemHeight = 84;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();

    // Re-centre whenever the selection changes — including when it changed
    // from a swipe on the preview rather than a tap in here.
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.hasClients) return;
        final extent = (_itemWidth + _itemGap).w;
        final target = (selectedIndex * extent) -
            (controller.position.viewportDimension / 2) +
            (extent / 2);
        controller.animateTo(
          target.clamp(
            controller.position.minScrollExtent,
            controller.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      });
      return null;
    }, [selectedIndex]);

    return SizedBox(
      height: _itemHeight.h,
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: garments.length,
        separatorBuilder: (_, _) => SizedBox(width: _itemGap.w),
        itemBuilder: (context, index) => _StripItem(
          garment: garments[index],
          isActive: index == selectedIndex,
          onTap: () => onSelect(index),
        ),
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  final GarmentModel garment;
  final bool isActive;
  final VoidCallback onTap;

  const _StripItem({
    required this.garment,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: garment.name,
      selected: isActive,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: GarmentStrip._itemWidth.w,
          decoration: BoxDecoration(
            color: AppColors.stageElevated,
            border: Border.all(
              color:
                  isActive ? AppColors.onStagePrimary : AppColors.stageBorder,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Opacity(
            opacity: isActive ? 1 : 0.55,
            child: Image.asset(
              garment.image,
              // Eight full-size decodes at once is most of a strip's cost.
              cacheWidth: 256,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.checkroom_outlined,
                size: 20.r,
                color: AppColors.onStageFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
