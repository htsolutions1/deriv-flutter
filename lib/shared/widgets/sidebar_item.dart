import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';

/// A tappable navigation item used inside [DrawerOverlay].
///
/// When [selected] is `true` the item is highlighted with a gold left border
/// and the icon/label are rendered in [AppColors.accent]. When `false`, the
/// icon and label use [AppColors.secondaryText].
///
/// Requirements: 10.6, 10.7, 10.8, 10.9, 10.10, 10.11
class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.secondaryText;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: selected ? AppColors.accent : Colors.transparent,
              width: 3.w,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.defaultPadding.w,
          vertical: AppSizes.paddingSmall.h,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppSizes.iconMedium.sp),
            Gap(12.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
