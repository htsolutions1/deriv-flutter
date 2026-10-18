import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/features/dashboard/providers/dashboard_state.dart';

/// Notifier that manages [DashboardState] updates.
///
/// Initialized with [DashboardState.empty()] so all UI fields start in their
/// null / default sentinel state until real data arrives.
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState.empty());

  /// Replaces the current state with [newState].
  void update(DashboardState newState) => state = newState;

  /// Patches specific fields while keeping the rest unchanged.
  void patch(DashboardState Function(DashboardState current) updater) {
    state = updater(state);
  }
}

/// Global provider for dashboard state.
///
/// Screens read this to display balance, profit, bot status, etc.
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);
