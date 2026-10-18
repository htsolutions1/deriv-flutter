import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// A reusable empty-state placeholder widget.
///
/// Displays an optional icon, a required label, and an optional sub-label
/// centred both horizontally and vertically within its parent.
///
/// Requirements: 10.6
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    required this.label,
    this.subLabel,
  });

  /// Optional icon rendered above the label.
  final IconData? icon;

  /// Primary descriptive label (always shown).
  final String label;

  /// Optional secondary caption below the label.
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSizes.iconLarge.sp,
              color: AppColors.secondaryText,
            ),
            Gap(8.h),
          ],
          Text(
            label,
            style: AppTextStyles.bodyStyle,
            textAlign: TextAlign.center,
          ),
          if (subLabel != null) ...[
            Gap(4.h),
            Text(
              subLabel!,
              style: AppTextStyles.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
