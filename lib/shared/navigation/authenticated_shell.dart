import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_strings.dart';
import 'package:ht_bot/routing/app_router.dart';
import 'package:ht_bot/shared/navigation/bottom_nav_bar.dart';
import 'package:ht_bot/shared/navigation/drawer_overlay.dart';
import 'package:ht_bot/shared/navigation/navigation_header.dart';
import 'package:ht_bot/shared/widgets/loading_overlay.dart';

/// Shell widget that wraps every authenticated screen.
///
/// Provides:
///   - [NavigationHeader] at the top with the current screen title.
///   - [BottomNavBar] at the bottom.
///   - [DrawerOverlay] sliding in from the left via [AnimatedPositioned].
///   - [LoadingOverlay] on top for global loading states.
///
/// [child] is the currently active screen supplied by GoRouter's [ShellRoute].
///
/// Requirements: 3.3, 3.5, 10.6
class AuthenticatedShell extends ConsumerWidget {
  const AuthenticatedShell({super.key, required this.child});

  final Widget child;

  /// Maps each authenticated route path to its screen title.
  static const Map<String, String> _routeTitles = {
    AppRoutes.dashboard : AppStrings.titleDashboard,
    AppRoutes.trades    : AppStrings.titleActiveTrades,
    AppRoutes.signals   : AppStrings.titleSignals,
    AppRoutes.settings  : AppStrings.titleSettings,
    AppRoutes.account   : AppStrings.titleAccount,
    AppRoutes.history   : AppStrings.titleHistory,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final title = _routeTitles[currentPath] ?? AppStrings.appName;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNavBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Screen content + header ───────────────────────────────────────
          Column(
            children: [
              NavigationHeader(title: title),
              Expanded(child: child),
            ],
          ),

          // ── Drawer overlay (must be Positioned.fill to have a reference frame)
          const Positioned.fill(
            child: DrawerOverlay(),
          ),

          // ── Global loading overlay (topmost) ──────────────────────────────
          const Positioned.fill(
            child: LoadingOverlay(),
          ),
        ],
      ),
    );
  }
}
