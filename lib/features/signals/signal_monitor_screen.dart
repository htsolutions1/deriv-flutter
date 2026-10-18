import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/app_enums.dart';
import '../../core/providers/connection_provider.dart';
import '../../shared/cards/glass_card.dart';
import '../../shared/cards/metric_tile.dart';
import '../../shared/tiles/signal_tile.dart';
import '../../shared/widgets/connection_badge.dart';
import '../../shared/widgets/empty_state.dart';
import '../../theme/text_styles.dart';
import 'providers/signals_provider.dart';

/// Signal Monitor screen — displays the current connection status, metrics,
/// and a live-updating list of incoming trading signals.
///
/// Requirements: 6.1–6.6
class SignalMonitorScreen extends ConsumerWidget {
  const SignalMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final signals = ref.watch(signalsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Connection Status Card ──────────────────────────────────
            GlassCard(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Signal Source',
                          style: AppTextStyles.captionStyle,
                        ),
                        Gap(2.h),
                        Text(
                          connectionStatus == ConnectionStatus.connected
                              ? 'Connected'
                              : 'Disconnected',
                          style: AppTextStyles.bodyStyle.copyWith(
                            color: connectionStatus == ConnectionStatus.connected
                                ? AppColors.success
                                : AppColors.disconnected,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConnectionBadge(status: connectionStatus),
                ],
              ),
            ),

            Gap(12.h),

            // ── 2. Metrics Row ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: 'Last Heartbeat',
                    value: '--',
                  ),
                ),
                Gap(8.w),
                Expanded(
                  child: MetricTile(
                    label: 'Last Signal',
                    value: '--',
                  ),
                ),
                Gap(8.w),
                Expanded(
                  child: MetricTile(
                    label: 'Avg Latency',
                    value: '--',
                  ),
                ),
              ],
            ),

            Gap(16.h),

            // ── 3. Section header ──────────────────────────────────────────
            Text(
              'Recent Signals',
              style: AppTextStyles.sectionStyle,
            ),

            Gap(8.h),

            // ── 4. Signals list ────────────────────────────────────────────
            Expanded(
              child: signals.isEmpty
                  ? const EmptyState(label: AppStrings.emptyWaitingSignal)
                  : ListView.builder(
                      itemCount: signals.length,
                      itemBuilder: (_, i) => SignalTile(signal: signals[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
