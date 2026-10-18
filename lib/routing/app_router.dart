import 'package:go_router/go_router.dart';

import 'package:ht_bot/features/auth/login_screen_new.dart';
import 'package:ht_bot/features/auth/oauth_callback_screen.dart';
import 'package:ht_bot/features/dashboard/dashboard_screen.dart';
import 'package:ht_bot/features/trades/active_trades_screen.dart';
import 'package:ht_bot/features/signals/signal_monitor_screen.dart';
import 'package:ht_bot/features/settings/settings_screen.dart';
import 'package:ht_bot/features/account/account_screen.dart';
import 'package:ht_bot/features/history/trade_history_screen.dart';
import 'package:ht_bot/shared/navigation/authenticated_shell.dart';
import 'package:ht_bot/debug/oauth_debug_screen.dart';

/// All named route paths used throughout the application.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String callback = '/callback';
  static const String dashboard = '/dashboard';
  static const String trades = '/trades';
  static const String signals = '/signals';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String history = '/history';
  static const String oauthDebug = '/oauth-debug';
}

/// GoRouter configuration for the entire application.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreenNew(),
      ),
      GoRoute(
        path: AppRoutes.oauthDebug,
        builder: (context, state) => const OAuthDebugScreen(),
      ),
      GoRoute(
        path: AppRoutes.callback,
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          final stateParam = state.uri.queryParameters['state'];
          final error = state.uri.queryParameters['error'];
          final errorDescription = state.uri.queryParameters['error_description'];
          
          return OAuthCallbackScreen(
            code: code,
            state: stateParam,
            error: error,
            errorDescription: errorDescription,
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AuthenticatedShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.trades,
            builder: (context, state) => const ActiveTradesScreen(),
          ),
          GoRoute(
            path: AppRoutes.signals,
            builder: (context, state) => const SignalMonitorScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.account,
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const TradeHistoryScreen(),
          ),
        ],
      ),
    ],
  );
}
