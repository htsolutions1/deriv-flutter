import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/enums/app_enums.dart';
import '../../core/models/signal_model.dart';
import '../../theme/text_styles.dart';

/// Compact list tile displaying a single trading signal.
///
/// Direction uses the same buy/sell color convention as [TradeTile].
/// Status is shown as a colored pill badge.
///
/// Requirements: 6.4, 6.5
class SignalTile extends StatelessWidget {
  final SignalModel signal;

  const SignalTile({super.key, required this.signal});

  static final _timeFmt = DateFormat('HH:mm:ss');

  Color get _directionColor =>
      signal.direction == TradeDirection.buy ? AppColors.buyColor : AppColors.sellColor;

  String get _directionLabel =>
      signal.direction == TradeDirection.buy ? 'BUY' : 'SELL';

  String get _formattedTimestamp =>
      signal.timestamp != null ? _timeFmt.format(signal.timestamp!) : '--';

  Color get _statusColor => switch (signal.status) {
        SignalStatus.pending  => const Color(0xFFF59E0B), // amber
        SignalStatus.executed => AppColors.success,
        SignalStatus.failed   => AppColors.loss,
        SignalStatus.expired  => AppColors.secondaryText,
      };

  String get _statusLabel => switch (signal.status) {
        SignalStatus.pending  => 'Pending',
        SignalStatus.executed => 'Executed',
        SignalStatus.failed   => 'Failed',
        SignalStatus.expired  => 'Expired',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(AppSizes.defaultPadding.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Direction badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _directionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              _directionLabel,
              style: AppTextStyles.sectionStyle.copyWith(
                color: _directionColor,
                fontSize: 12.sp,
              ),
            ),
          ),
          Gap(12.w),
          // Source & timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.source ?? '--',
                  style: AppTextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(2.h),
                Text(
                  _formattedTimestamp,
                  style: AppTextStyles.captionStyle,
                ),
              ],
            ),
          ),
          Gap(8.w),
          // Status pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _statusColor.withValues(alpha: 0.4), width: 1),
            ),
            child: Text(
              _statusLabel,
              style: AppTextStyles.captionStyle.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
