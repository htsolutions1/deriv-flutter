import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_sizes.dart';
import '../../theme/text_styles.dart';
import '../widgets/empty_state.dart';
import 'glass_card.dart';

/// A card that displays a labelled statistic with an optional chart widget.
///
/// - When [chart] is provided it is rendered in the card body.
/// - When both [value] and [chart] are null an [EmptyState] widget is shown.
///
/// Requirements: 10.2, 4.3
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.label,
    this.value,
    this.chart,
  });

  /// Descriptor label shown above the body (e.g. "Win Rate").
  final String label;

  /// Numeric value to display when no [chart] is provided.
  final double? value;

  /// Optional chart widget. Takes precedence over [value] display.
  final Widget? chart;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 80.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.captionStyle),
            Gap(AppSizes.paddingSmall.h),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Chart takes priority when provided.
    if (chart != null) return chart!;

    // Value available — render it.
    if (value != null) {
      return Text(
        value.toString(),
        style: AppTextStyles.subtitleStyle.copyWith(fontWeight: FontWeight.w700),
      );
    }

    // Neither chart nor value: use the EmptyState widget.
    return const EmptyState(label: '--');
  }
}
