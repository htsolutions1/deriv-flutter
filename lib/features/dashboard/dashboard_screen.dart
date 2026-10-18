import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/app_enums.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/glass_card.dart';
import '../../shared/cards/metric_tile.dart';
import '../../shared/cards/profit_card.dart';
import '../../shared/cards/statistic_card.dart';
import '../../shared/cards/status_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/text_styles.dart';
import 'providers/dashboard_state.dart';
import 'providers/dashboard_controller.dart';

/// The main dashboard screen showing account balance, profit, win rate,
/// trade metrics, status grid, and bot control buttons.
///
/// Requirements: 4.1–4.10
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStateControllerProvider);
    final controllerState = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: controllerState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              Gap(16.h),
              Text(
                'Failed to load dashboard',
                style: AppTextStyles.sectionStyle,
              ),
              Gap(8.h),
              Text(
                error.toString(),
                style: AppTextStyles.captionStyle,
                textAlign: TextAlign.center,
              ),
              Gap(24.h),
              PrimaryButton(
                label: 'Retry',
                onPressed: () {
                  ref.invalidate(dashboardControllerProvider);
                },
              ),
            ],
          ),
        ),
        data: (_) => SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Index 0 — Balance Card
              _stagger(
                index: 0,
                child: _buildBalanceCard(state),
              ),
              Gap(12.h),

              // Index 1 — Profit + Win Rate row
              _stagger(
                index: 1,
                child: _buildProfitWinRateRow(state),
              ),
              Gap(12.h),

              // Index 2 — Active Trades / Trades Today row
              _stagger(
                index: 2,
                child: _buildMetricsRow(state),
              ),
              Gap(12.h),

              // Index 3 — Status Cards Grid
              _stagger(
                index: 3,
                child: _buildStatusGrid(context, state),
              ),
              Gap(16.h),

              // Index 4 — Start Bot Button
              _stagger(
                index: 4,
                child: PrimaryButton(
                  label: AppStrings.btnStartBot,
                  onPressed: () {},
                ),
              ),
              Gap(8.h),

              // Index 5 — Emergency Stop Button
              _stagger(
                index: 5,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error, width: 1.5),
                    minimumSize: Size(double.infinity, AppSizes.buttonHeight.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadiusSmall.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.btnEmergencyStop,
                    style: AppTextStyles.sectionStyle.copyWith(color: AppColors.error),
                  ),
                ),
              ),
              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stagger helper
  // ---------------------------------------------------------------------------

  Widget _stagger({required int index, required Widget child}) {
    return child
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 350.ms)
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ---------------------------------------------------------------------------
  // Index 0 — Balance Card
  // ---------------------------------------------------------------------------

  Widget _buildBalanceCard(DashboardState state) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Account Balance', style: AppTextStyles.captionStyle),
                Gap(4.h),
                Text(
                  state.balance != null
                      ? '\$${state.balance!.toStringAsFixed(2)}'
                      : '--',
                  style: AppTextStyles.titleStyle,
                ),
              ],
            ),
          ),
          StatusBadge(status: state.botStatus),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Index 1 — Profit + Win Rate row
  // ---------------------------------------------------------------------------

  Widget _buildProfitWinRateRow(DashboardState state) {
    return Row(
      children: [
        Expanded(
          child: ProfitCard(
            label: "Today's Profit",
            value: state.todayProfit,
            isPositive: state.todayProfit != null
                ? state.todayProfit! >= 0
                : null,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: StatisticCard(
            label: 'Win Rate',
            value: state.winRate,
            chart: state.winRate != null
                ? _buildDonutChart(state.winRate!)
                : null,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Index 2 — Metrics row
  // ---------------------------------------------------------------------------

  Widget _buildMetricsRow(DashboardState state) {
    return Row(
      children: [
        Expanded(
          child: MetricTile(
            label: 'Active Trades',
            value: state.activeTrades.toString(),
          ),
        ),
        Gap(12.w),
        Expanded(
          child: MetricTile(
            label: 'Trades Today',
            value: state.tradesToday.toString(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Index 3 — Status Cards Grid
  // ---------------------------------------------------------------------------

  Widget _buildStatusGrid(BuildContext context, DashboardState state) {
    final cardWidth = (MediaQuery.of(context).size.width - 48.w) / 2;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        // Bot Status
        SizedBox(
          width: cardWidth,
          child: StatusCard(
            label: 'Bot Status',
            statusText: _botStatusText(state.botStatus),
            statusColor: _botStatusColor(state.botStatus),
          ),
        ),
        // Signal Source
        SizedBox(
          width: cardWidth,
          child: const StatusCard(
            label: 'Signal Source',
            statusText: 'Disconnected',
            statusColor: AppColors.disconnected,
          ),
        ),
        // Connection
        SizedBox(
          width: cardWidth,
          child: const StatusCard(
            label: 'Connection',
            statusText: 'Offline',
            statusColor: AppColors.disconnected,
          ),
        ),
        // Server
        SizedBox(
          width: cardWidth,
          child: const StatusCard(
            label: 'Server',
            statusText: 'Offline',
            statusColor: AppColors.disconnected,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Donut chart
  // ---------------------------------------------------------------------------

  Widget _buildDonutChart(double winRate) {
    return SizedBox(
      height: 80.h,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: winRate,
              color: AppColors.accent,
              radius: 12.r,
              showTitle: false,
            ),
            PieChartSectionData(
              value: 100 - winRate,
              color: AppColors.border,
              radius: 12.r,
              showTitle: false,
            ),
          ],
          centerSpaceRadius: 30.r,
          sectionsSpace: 0,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------

  String _botStatusText(BotStatus s) => switch (s) {
        BotStatus.idle => 'Idle',
        BotStatus.running => 'Running',
        BotStatus.stopped => 'Stopped',
        BotStatus.error => 'Error',
      };

  Color _botStatusColor(BotStatus s) => switch (s) {
        BotStatus.idle => AppColors.secondaryText,
        BotStatus.running => AppColors.success,
        BotStatus.stopped => AppColors.disconnected,
        BotStatus.error => AppColors.error,
      };
}
