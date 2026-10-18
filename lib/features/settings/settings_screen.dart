import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/cards/glass_card.dart';
import '../../shared/dialogs/glass_bottom_sheet.dart';
import '../../shared/tiles/settings_tile.dart';
import '../../theme/text_styles.dart';
import 'providers/settings_provider.dart';

/// Settings screen presenting three groups of configurable options:
/// Trading Settings, Connection Settings, and Notification Settings.
///
/// Requirements: 7.1–7.8
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // ---------------------------------------------------------------------------
  // Edit dialog
  // ---------------------------------------------------------------------------

  /// Shows a [GlassBottomSheet] with a simple text field for editing [fieldName].
  /// No persistence — this is a UI-only interaction per the spec.
  void _showEditDialog(BuildContext context, String fieldName) {
    GlassBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(fieldName, style: AppTextStyles.titleStyle),
          Gap(16.h),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter value',
              hintStyle: AppTextStyles.captionStyle,
            ),
            autofocus: true,
          ),
          Gap(16.h),
          PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Group 1: Trading Settings ─────────────────────────────────
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  AppStrings.settingsGroupTrading,
                  style: AppTextStyles.sectionStyle,
                ),
              ),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SettingsTile(
                      label: AppStrings.settingStakeAmount,
                      value: '\$${state.stakeAmount}',
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingStakeAmount,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingTakeProfit,
                      value: '\$${state.takeProfit}',
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingTakeProfit,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingStopLoss,
                      value: '\$${state.stopLoss}',
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingStopLoss,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingMaxConcurrentTrades,
                      value: state.maxConcurrentTrades.toString(),
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingMaxConcurrentTrades,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingDailyProfitTarget,
                      value: '\$${state.dailyProfitTarget}',
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingDailyProfitTarget,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingDailyLossLimit,
                      value: '\$${state.dailyLossLimit}',
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingDailyLossLimit,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingMartingaleMultiplier,
                      value: state.martingaleMultiplier.toString(),
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingMartingaleMultiplier,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingCooldownPeriod,
                      value: '${state.cooldownPeriod}s',
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingCooldownPeriod,
                      ),
                    ),
                  ],
                ),
              ),

              Gap(16.h),

              // ── Group 2: Connection Settings ──────────────────────────────
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  AppStrings.settingsGroupConnection,
                  style: AppTextStyles.sectionStyle,
                ),
              ),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SettingsTile(
                      label: AppStrings.settingApiToken,
                      value: state.apiToken.isEmpty ? '--' : state.apiToken,
                      isSensitive: true,
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingApiToken,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingPythonEngineUrl,
                      value: state.pythonEngineUrl.isEmpty
                          ? '--'
                          : state.pythonEngineUrl,
                      onTap: () => _showEditDialog(
                        context,
                        AppStrings.settingPythonEngineUrl,
                      ),
                    ),
                    SettingsTile(
                      label: AppStrings.settingAutoReconnect,
                      isSwitch: true,
                      switchValue: state.autoReconnect,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .patch((s) => s.copyWith(autoReconnect: v)),
                    ),
                  ],
                ),
              ),

              Gap(16.h),

              // ── Group 3: Notification Settings ────────────────────────────
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  AppStrings.settingsGroupNotification,
                  style: AppTextStyles.sectionStyle,
                ),
              ),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SettingsTile(
                      label: AppStrings.settingTradeExecuted,
                      isSwitch: true,
                      switchValue: state.tradeExecuted,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .patch((s) => s.copyWith(tradeExecuted: v)),
                    ),
                    SettingsTile(
                      label: AppStrings.settingSignalReceived,
                      isSwitch: true,
                      switchValue: state.signalReceived,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .patch((s) => s.copyWith(signalReceived: v)),
                    ),
                    SettingsTile(
                      label: AppStrings.settingBotStopped,
                      isSwitch: true,
                      switchValue: state.botStopped,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .patch((s) => s.copyWith(botStopped: v)),
                    ),
                    SettingsTile(
                      label: AppStrings.settingConnectionLost,
                      isSwitch: true,
                      switchValue: state.connectionLost,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .patch((s) => s.copyWith(connectionLost: v)),
                    ),
                  ],
                ),
              ),

              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }
}
