import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../theme/text_styles.dart';
import 'glass_card.dart';

/// A card that displays a monetary profit/loss value with directional colouring.
///
/// - [value] == null  → shows "--" in [AppColors.secondaryText]
/// - [isPositive] == true  → shows "+\$x.xx" in [AppColors.success]
/// - [isPositive] == false → shows "\$x.xx" in [AppColors.loss]
///
/// Values are formatted using [NumberFormat.currency] from the `intl` package.
///
/// Requirements: 10.2, 4.2
class ProfitCard extends StatelessWidget {
  const ProfitCard({
    super.key,
    required this.label,
    this.value,
    this.isPositive,
  });

  /// Descriptor label shown above the value (e.g. "Today's Profit").
  final String label;

  /// Raw numeric profit/loss amount. When null, "--" is shown.
  final double? value;

  /// Direction indicator. `true` → green with `+` prefix, `false` → red.
  /// Ignored when [value] is null.
  final bool? isPositive;

  static final _currencyFormat = NumberFormat.currency(symbol: r'$');

  String get _displayValue {
    if (value == null) return '--';
    final formatted = _currencyFormat.format(value!.abs());
    return (isPositive == true) ? '+$formatted' : formatted;
  }

  Color get _valueColor {
    if (value == null) return AppColors.secondaryText;
    return (isPositive == true) ? AppColors.success : AppColors.loss;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.captionStyle),
          Gap(AppSizes.paddingSmall.h),
          Text(
            _displayValue,
            style: AppTextStyles.subtitleStyle.copyWith(
              color: _valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
