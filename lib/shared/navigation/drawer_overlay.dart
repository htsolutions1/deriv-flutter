import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/core/constants/app_strings.dart';
import 'package:ht_bot/routing/app_router.dart';
import 'package:ht_bot/shared/navigation/drawer_provider.dart';
import 'package:ht_bot/shared/widgets/sidebar_item.dart';
import 'package:ht_bot/shared/widgets/web_safe_blur.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// Full-screen drawer overlay driven by [drawerOpenProvider].
///
/// Uses [AnimatedPositioned] inside a [Stack] — NOT Flutter's built-in Drawer
/// widget — so content behind is never pushed aside.
///
/// When open:
///   - A semi-transparent black scrim covers the full screen. Tapping it
///     dismisses the drawer.
///   - [_DrawerPanel] slides in from the left.
///
/// When closed the panel is hidden at `left: -AppSizes.drawerWidth.w`.
///
/// Requirements: 3.6, 3.7, 3.8, 3.9
class DrawerOverlay extends ConsumerWidget {
  const DrawerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(drawerOpenProvider);

    return Stack(
      children: [
        // ── Scrim ──────────────────────────────────────────────────────────
        if (isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => ref.read(drawerOpenProvider.notifier).state = false,
              child: ColoredBox(color: Colors.black26),
            ),
          ),

        // ── Sliding panel ──────────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          left: isOpen ? 0 : -AppSizes.drawerWidth.w,
          top: 0,
          bottom: 0,
          width: AppSizes.drawerWidth.w,
          child: _DrawerPanel(
            onClose: () =>
                ref.read(drawerOpenProvider.notifier).state = false,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _DrawerPanel
// ---------------------------------------------------------------------------

/// The frosted-glass panel content rendered inside [DrawerOverlay].
///
/// Displays a header with the app name and a close button, followed by
/// [SidebarItem]s for every authenticated route. The currently active route
/// (detected from [GoRouterState]) is highlighted.
///
/// Tapping an item closes the drawer then navigates to the route.
///
/// Requirements: 3.6, 3.8, 3.9
class _DrawerPanel extends ConsumerWidget {
  const _DrawerPanel({required this.onClose});

  final VoidCallback onClose;

  static const List<_SidebarEntry> _entries = [
    _SidebarEntry(
      label: AppStrings.navDashboard,
      route: AppRoutes.dashboard,
    ),
    _SidebarEntry(
      label: AppStrings.navTrades,
      route: AppRoutes.trades,
    ),
    _SidebarEntry(
      label: AppStrings.navSignals,
      route: AppRoutes.signals,
    ),
    _SidebarEntry(
      label: AppStrings.navSettings,
      route: AppRoutes.settings,
    ),
    _SidebarEntry(
      label: AppStrings.navAccount,
      route: AppRoutes.account,
    ),
    _SidebarEntry(
      label: AppStrings.navHistory,
      route: AppRoutes.history,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return ClipRect(
      child: WebSafeBlur(
        sigmaX: 12,
        sigmaY: 12,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.defaultPadding.w,
                    vertical: AppSizes.paddingSmall.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.titleStyle,
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(
                          Icons.close,
                          color: AppColors.primaryText,
                          size: AppSizes.iconMedium.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: AppColors.border, height: 1),
                Gap(AppSizes.paddingSmall.h),

                // ── Navigation items ────────────────────────────────────────
                ..._entries.map((entry) {
                  return SidebarItem(
                    icon: _iconFor(entry.route),
                    label: entry.label,
                    selected: currentPath == entry.route,
                    onTap: () {
                      onClose();
                      context.go(entry.route);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String route) {
    return switch (route) {
      AppRoutes.dashboard => Icons.home_outlined,
      AppRoutes.trades    => Icons.show_chart,
      AppRoutes.signals   => Icons.notifications_outlined,
      AppRoutes.settings  => Icons.settings_outlined,
      AppRoutes.account   => Icons.person_outline,
      AppRoutes.history   => Icons.history,
      _                   => Icons.home_outlined,
    };
  }
}

// ---------------------------------------------------------------------------
// _SidebarEntry
// ---------------------------------------------------------------------------

/// Internal data holder for a sidebar navigation entry.
class _SidebarEntry {
  const _SidebarEntry({required this.label, required this.route});

  final String label;
  final String route;
}
