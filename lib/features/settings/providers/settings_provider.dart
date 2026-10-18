import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/features/settings/providers/settings_state.dart';

/// Notifier that manages [SettingsState] updates.
///
/// Initialized with [SettingsState.defaults()] which applies all documented
/// default values across the three settings groups (Trading, Connection,
/// Notifications).
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.defaults());

  /// Replaces the current settings state with [newState].
  void update(SettingsState newState) => state = newState;

  /// Patches specific fields while keeping the rest unchanged.
  void patch(SettingsState Function(SettingsState current) updater) {
    state = updater(state);
  }
}

/// Global provider for settings state.
///
/// Screens read this to display and modify all configurable settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
