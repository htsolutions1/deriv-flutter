import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/core/providers/connection_provider.dart';
import 'package:ht_bot/shared/navigation/drawer_provider.dart';
import 'package:ht_bot/shared/widgets/connection_badge.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// Top app bar shown on all authenticated screens.
///
/// Layout:
///   - Left: hamburger [IconButton] that opens [DrawerOverlay] by toggling
///     [drawerOpenProvider] to `true`.
///   - Center: [title] text rendered in [AppTextStyles.titleStyle].
///   - Right: [ConnectionBadge] reflecting [connectionStatusProvider].
///
/// Renders on a transparent background with a [SafeArea] top inset.
///
/// Requirements: 3.5, 3.6
class NavigationHeader extends ConsumerWidget {
  const NavigationHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.defaultPadding.w),
        child: Row(
          children: [
            // ── Hamburger ──────────────────────────────────────────────────
            IconButton(
              onPressed: () {
                ref.read(drawerOpenProvider.notifier).state = true;
              },
              icon: Icon(
                Icons.menu,
                color: AppColors.primaryText,
                size: AppSizes.iconMedium.sp,
              ),
            ),

            // ── Title ──────────────────────────────────────────────────────
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleStyle,
              ),
            ),

            // ── Connection badge ───────────────────────────────────────────
            ConnectionBadge(status: connectionStatus),
          ],
        ),
      ),
    );
  }
}
