import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/app_enums.dart';
import '../../shared/cards/glass_card.dart';
import '../../shared/cards/metric_tile.dart';
import '../../shared/tiles/trade_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../../theme/text_styles.dart';
import 'providers/history_provider.dart';

/// Trade History screen — displays all completed trades filtered by outcome,
/// with a summary section showing win/loss statistics.
///
/// Requirements: 9.1–9.6
class TradeHistoryScreen extends ConsumerWidget {
  const TradeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final activeFilter = ref.watch(historyFilterProvider);

    // Apply filter: win → TradeOutcome.win, loss → TradeOutcome.loss, all → everything
    final filtered = history.where((trade) {
      return switch (activeFilter) {
        HistoryFilter.win  => trade.outcome == TradeOutcome.win,
        HistoryFilter.loss => trade.outcome == TradeOutcome.loss,
        HistoryFilter.all  => true,
      };
    }).toList();

    // Summary calculations (always based on full history, not filtered)
    final total = history.length;
    final wins = history.where((t) => t.outcome == TradeOutcome.win).length;
    final losses = history.where((t) => t.outcome == TradeOutcome.loss).length;
    final winRate = wins > 0
        ? '${(wins / total * 100).toStringAsFixed(0)}%'
        : '0%';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Gap(4.h),
          // ── Filter chips row ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                _HistoryFilterChip(
                  label: 'All',
                  filter: HistoryFilter.all,
                  selected: activeFilter == HistoryFilter.all,
                  onSelected: (filter) =>
                      ref.read(historyFilterProvider.notifier).state = filter,
                ),
                Gap(8.w),
                _HistoryFilterChip(
                  label: 'Win',
                  filter: HistoryFilter.win,
                  selected: activeFilter == HistoryFilter.win,
                  onSelected: (filter) =>
                      ref.read(historyFilterProvider.notifier).state = filter,
                ),
                Gap(8.w),
                _HistoryFilterChip(
                  label: 'Loss',
                  filter: HistoryFilter.loss,
                  selected: activeFilter == HistoryFilter.loss,
                  onSelected: (filter) =>
                      ref.read(historyFilterProvider.notifier).state = filter,
                ),
              ],
            ),
          ),

          Gap(12.h),

          // ── Trade list ───────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(label: AppStrings.emptyNoTradeHistory)
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => TradeTile(trade: filtered[i]),
                  ),
          ),

          // ── Summary section ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: AppTextStyles.sectionStyle),
                  Gap(8.h),
                  Builder(
                    builder: (context) {
                      final tileWidth =
                          (MediaQuery.of(context).size.width - 56.w) / 3;
                      return Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          SizedBox(
                            width: tileWidth,
                            child: MetricTile(
                              label: 'Total',
                              value: total.toString(),
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: MetricTile(
                              label: 'Wins',
                              value: wins.toString(),
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: MetricTile(
                              label: 'Losses',
                              value: losses.toString(),
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: MetricTile(
                              label: 'Win Rate',
                              value: winRate,
                            ),
                          ),
                          SizedBox(
                            width: tileWidth,
                            child: MetricTile(
                              label: 'Profit',
                              value: r'$0',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single filter choice chip for the history screen.
class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.filter,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final HistoryFilter filter;
  final bool selected;
  final ValueChanged<HistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(filter),
      selectedColor: AppColors.accent,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.secondaryText,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.accent
            : AppColors.secondaryText.withValues(alpha: 0.4),
      ),
      showCheckmark: false,
    );
  }
}
