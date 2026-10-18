import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/app_enums.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/tiles/trade_tile.dart';
import '../../shared/widgets/empty_state.dart';
import 'providers/trades_provider.dart';

/// Active Trades screen — displays all current trades filtered by
/// [tradeFilterProvider] with chip controls for Running / Closed / All.
///
/// Requirements: 5.1–5.7
class ActiveTradesScreen extends ConsumerWidget {
  const ActiveTradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(tradesProvider);
    final activeFilter = ref.watch(tradeFilterProvider);

    // Apply filter: running → open outcome, closed → win/loss, all → everything
    final filteredTrades = trades.where((trade) {
      return switch (activeFilter) {
        TradeFilter.running => trade.outcome == TradeOutcome.open,
        TradeFilter.closed  => trade.outcome == TradeOutcome.win ||
                               trade.outcome == TradeOutcome.loss,
        TradeFilter.all     => true,
      };
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Gap(8.h),
          // ── Filter chips row ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Running',
                  filter: TradeFilter.running,
                  selected: activeFilter == TradeFilter.running,
                  onSelected: (filter) =>
                      ref.read(tradeFilterProvider.notifier).state = filter,
                ),
                Gap(8.w),
                _FilterChip(
                  label: 'Closed',
                  filter: TradeFilter.closed,
                  selected: activeFilter == TradeFilter.closed,
                  onSelected: (filter) =>
                      ref.read(tradeFilterProvider.notifier).state = filter,
                ),
                Gap(8.w),
                _FilterChip(
                  label: 'All',
                  filter: TradeFilter.all,
                  selected: activeFilter == TradeFilter.all,
                  onSelected: (filter) =>
                      ref.read(tradeFilterProvider.notifier).state = filter,
                ),
              ],
            ),
          ),

          Gap(12.h),

          // ── Trade list ───────────────────────────────────────────────────
          Expanded(
            child: filteredTrades.isEmpty
                ? const EmptyState(label: AppStrings.emptyNoTrades)
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: filteredTrades.length,
                    itemBuilder: (context, index) =>
                        TradeTile(trade: filteredTrades[index]),
                  ),
          ),

          // ── Bottom button ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: PrimaryButton(
              label: AppStrings.btnCloseAllTrades,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Single filter choice chip for the trades screen.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.filter,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final TradeFilter filter;
  final bool selected;
  final ValueChanged<TradeFilter> onSelected;

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
        color: selected ? AppColors.accent : AppColors.secondaryText.withValues(alpha: 0.4),
      ),
      showCheckmark: false,
    );
  }
}
