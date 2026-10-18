import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_sizes.dart';
import '../../theme/text_styles.dart';
import 'glass_card.dart';

/// A compact card tile that shows a numeric or string value above its label.
///
/// Layout (top → bottom):
///   [value] — bold body text
///   [label] — caption text
///
/// Designed for dense metric grids such as the dashboard summary row and the
/// trade history summary section.
///
/// Requirements: 10.2, 4.1, 4.2, 4.3, 4.4
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  /// Human-readable descriptor shown below the value (e.g. "Active Trades").
  final String label;

  /// Pre-formatted value string shown prominently (e.g. "12", "87.5%").
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.defaultPadding.w,
        vertical: AppSizes.paddingSmall.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.bodyStyle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(2.h),
          Text(label, style: AppTextStyles.captionStyle),
        ],
      ),
    );
  }
}
