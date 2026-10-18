import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../routing/app_router.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/secondary_button.dart';
import '../../shared/cards/glass_card.dart';
import '../../shared/dialogs/glass_bottom_sheet.dart';
import '../../shared/dialogs/glass_dialog.dart';
import '../../shared/tiles/account_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../../theme/text_styles.dart';
import 'providers/account_provider.dart';

/// Account screen — displays the connected Deriv account's profile,
/// account details, and provides actions for API token management,
/// account switching, and logout.
///
/// Requirements: 10.1, 10.3, 10.4, 10.5, 10.6
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  // ---------------------------------------------------------------------------
  // Action dialogs
  // ---------------------------------------------------------------------------

  void _showManageApiToken(BuildContext context) {
    GlassBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.btnManageApiToken, style: AppTextStyles.titleStyle),
          Gap(16.h),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter API token',
              hintStyle: AppTextStyles.captionStyle,
            ),
            autofocus: true,
          ),
          Gap(16.h),
          PrimaryButton(
            label: AppStrings.btnConfirm,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showSwitchAccount(BuildContext context) {
    GlassDialog.show(
      context,
      title: AppStrings.btnSwitchAccount,
      content: Text(
        'Account switching will be available once connected to the Deriv API.',
        style: AppTextStyles.bodyStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.btnCancel,
            style: AppTextStyles.bodyStyle.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    GlassDialog.show(
      context,
      title: AppStrings.btnLogout,
      content: Text(
        'Are you sure you want to log out?',
        style: AppTextStyles.bodyStyle,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.btnCancel,
            style: AppTextStyles.bodyStyle.copyWith(color: AppColors.secondaryText),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go(AppRoutes.login);
          },
          child: Text(
            AppStrings.btnConfirm,
            style: AppTextStyles.bodyStyle.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable — provider reserved for future account data
    final _ = ref.watch(accountProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.defaultPadding.w,
          vertical: AppSizes.paddingSmall.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile section ─────────────────────────────────────────────
            GlassCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32.r,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person_outline,
                      size: AppSizes.iconLarge.sp,
                      color: AppColors.accent,
                    ),
                  ),
                  Gap(12.h),
                  const EmptyState(
                    label: AppStrings.emptyAccountNotConnected,
                    subLabel: 'Connect your Deriv account to see details',
                  ),
                ],
              ),
            ),

            Gap(16.h),

            // ── Account details section ──────────────────────────────────────
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  AccountTile(label: 'Account ID',     value: '--'),
                  AccountTile(label: 'Account Type',   value: '--'),
                  AccountTile(label: 'Currency',       value: '--'),
                  AccountTile(label: 'Balance',        value: '--'),
                  AccountTile(label: 'Server',         value: '--'),
                  AccountTile(label: 'Landing Company', value: '--'),
                ],
              ),
            ),

            Gap(24.h),

            // ── Action buttons ───────────────────────────────────────────────
            PrimaryButton(
              label: AppStrings.btnManageApiToken,
              onPressed: () => _showManageApiToken(context),
            ),

            Gap(12.h),

            SecondaryButton(
              label: AppStrings.btnSwitchAccount,
              onPressed: () => _showSwitchAccount(context),
            ),

            Gap(12.h),

            SecondaryButton(
              label: AppStrings.btnLogout,
              onPressed: () => _showLogoutConfirm(context),
            ),

            Gap(AppSizes.defaultPadding.h),
          ],
        ),
      ),
    );
  }
}
