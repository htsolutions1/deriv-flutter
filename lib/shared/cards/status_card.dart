import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_sizes.dart';
import '../../theme/text_styles.dart';
import 'glass_card.dart';

/// A card that displays a labelled status value with an optional leading icon.
///
/// Wraps [GlassCard] and uses [AppTextStyles.captionStyle] for the label and
/// [AppTextStyles.bodyStyle] (tinted with [statusColor]) for the status text.
///
/// Requirements: 10.2, 4.1
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.label,
    required this.statusText,
    required this.statusColor,
    this.icon,
  });

  /// Short descriptor shown above or beside the status value.
  final String label;

  /// Human-readable status string (e.g. "Running", "Offline").
  final String statusText;

  /// Color applied to [statusText].
  final Color statusColor;

  /// Optional leading icon rendered to the left of the text content.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.defaultPadding.w,
        vertical: AppSizes.paddingSmall.h,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconMedium.r, color: statusColor),
            Gap(AppSizes.paddingSmall.w),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.captionStyle),
              Gap(2.h),
              Text(
                statusText,
                style: AppTextStyles.bodyStyle.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
