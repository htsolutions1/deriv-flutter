import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/core/constants/app_strings.dart';
import 'package:ht_bot/routing/app_router.dart';
import 'package:ht_bot/shared/widgets/web_safe_blur.dart';

/// Bottom navigation bar shown on all authenticated screens.
///
/// Five items: Dashboard, Trades, Signals, Settings, Account.
/// The active item is highlighted with [AppColors.accent]; inactive items
/// use [AppColors.secondaryText].
///
/// Active route is detected via [GoRouterState.of(context).uri.path] so the
/// indicator updates automatically on deep-link navigation without any
/// additional state.
///
/// Uses a [BackdropFilter] frosted-glass background.
///
/// Requirements: 3.1, 3.2, 3.3, 3.4
class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  static const List<_NavItem> _items = [
    _NavItem(
      label: AppStrings.navDashboard,
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      label: AppStrings.navTrades,
      route: AppRoutes.trades,
    ),
    _NavItem(
      label: AppStrings.navSignals,
      route: AppRoutes.signals,
    ),
    _NavItem(
      label: AppStrings.navSettings,
      route: AppRoutes.settings,
    ),
    _NavItem(
      label: AppStrings.navAccount,
      route: AppRoutes.account,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;

    return ClipRect(
      child: WebSafeBlur(
        sigmaX: 10,
        sigmaY: 10,
        child: Container(
          height: AppSizes.bottomNavHeight.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: _items.map((item) {
              final isActive = currentPath == item.route;
              final color =
                  isActive ? AppColors.accent : AppColors.secondaryText;

              return Expanded(
                child: InkWell(
                  onTap: () => context.go(item.route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _iconFor(item.route),
                        color: color,
                        size: AppSizes.iconMedium.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10.sp,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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
      _                   => Icons.home_outlined,
    };
  }
}

/// Internal data holder for a bottom nav item.
class _NavItem {
  const _NavItem({required this.label, required this.route});

  final String label;
  final String route;
}
