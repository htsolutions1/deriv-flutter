import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/enums/app_enums.dart';
import '../../core/models/trade_model.dart';
import '../../theme/text_styles.dart';

/// Compact list tile displaying a single trade's key fields.
///
/// Null field values render as "--". P&L color follows profit/loss conventions.
///
/// Requirements: 5.4, 5.6
class TradeTile extends StatelessWidget {
  final TradeModel trade;

  const TradeTile({super.key, required this.trade});

  Color get _directionColor =>
      trade.direction == TradeDirection.buy ? AppColors.buyColor : AppColors.sellColor;

  String get _directionLabel =>
      trade.direction == TradeDirection.buy ? 'BUY' : 'SELL';

  String _fmt(double? value, {String prefix = ''}) =>
      value != null ? '$prefix${value.toStringAsFixed(2)}' : '--';

  String _fmtDuration(Duration? d) {
    if (d == null) return '--';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Color _pnlColor(double? pnl) {
    if (pnl == null) return AppColors.primaryText;
    return pnl >= 0 ? AppColors.success : AppColors.loss;
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Direction badge + trade ID
          Row(
            children: [
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
              const Spacer(),
              Text(
                trade.id,
                style: AppTextStyles.captionStyle,
              ),
            ],
          ),
          Gap(10.h),
          // Compact field grid — two columns
          Row(
            children: [
              Expanded(
                child: _FieldItem(label: 'Stake', value: _fmt(trade.stake, prefix: '\$')),
              ),
              Expanded(
                child: _FieldItem(label: 'Entry Price', value: _fmt(trade.entryPrice, prefix: '\$')),
              ),
            ],
          ),
          Gap(6.h),
          Row(
            children: [
              Expanded(
                child: _FieldItem(label: 'Duration', value: _fmtDuration(trade.duration)),
              ),
              Expanded(
                child: _FieldItem(label: 'Take Profit', value: _fmt(trade.takeProfit, prefix: '\$')),
              ),
            ],
          ),
          Gap(6.h),
          Row(
            children: [
              Expanded(
                child: _FieldItem(label: 'Stop Loss', value: _fmt(trade.stopLoss, prefix: '\$')),
              ),
              Expanded(
                child: _FieldItem(
                  label: 'Current P&L',
                  value: trade.currentPnl != null
                      ? '${trade.currentPnl! >= 0 ? '+' : '-'}\$${trade.currentPnl!.abs().toStringAsFixed(2)}'
                      : '--',
                  valueColor: _pnlColor(trade.currentPnl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _FieldItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.captionStyle),
        Gap(2.h),
        Text(
          value,
          style: AppTextStyles.bodyStyle.copyWith(
            color: valueColor ?? AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
