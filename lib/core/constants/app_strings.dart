/// All UI string literals used across the HT BOT app.
///
/// Centralising strings here makes future localisation straightforward and
/// keeps raw string literals out of widget code.
abstract final class AppStrings {
  // ── App identity ─────────────────────────────────────────────────────────
  static const String appName           = 'HT BOT';
  static const String appSubtitle       = 'Deriv Trading Bot';

  // ── Screen titles ────────────────────────────────────────────────────────
  static const String titleDashboard    = 'Dashboard';
  static const String titleActiveTrades = 'Active Trades';
  static const String titleSignals      = 'Signal Monitor';
  static const String titleSettings     = 'Settings';
  static const String titleAccount      = 'Account';
  static const String titleHistory      = 'Trade History';
  static const String titleLogin        = 'Login';

  // ── Navigation labels ────────────────────────────────────────────────────
  static const String navDashboard      = 'Dashboard';
  static const String navTrades         = 'Trades';
  static const String navSignals        = 'Signals';
  static const String navSettings       = 'Settings';
  static const String navAccount        = 'Account';
  static const String navHistory        = 'History';

  // ── Button labels ────────────────────────────────────────────────────────
  static const String btnConnectDeriv   = 'Connect with Deriv';
  static const String btnStartBot       = 'Start Bot';
  static const String btnStopBot        = 'Stop Bot';
  static const String btnEmergencyStop  = 'Emergency Stop';
  static const String btnCloseAllTrades = 'Close All Trades';
  static const String btnManageApiToken = 'Manage API Token';
  static const String btnSwitchAccount  = 'Switch Account';
  static const String btnLogout         = 'Logout';
  static const String btnCancel         = 'Cancel';
  static const String btnConfirm        = 'Confirm';
  static const String btnRetry          = 'Retry';

  // ── Empty state labels ───────────────────────────────────────────────────
  static const String emptyActiveTrades      = 'No active trades';
  static const String emptyWaitingSignal     = 'Waiting for next signal…';
  static const String emptyAccountNotConnected = 'Account not connected';
  static const String emptyNoHistory         = 'No history available';
  static const String emptyNoAnalytics       = 'No analytics available';
  static const String emptyNoTrades          = 'No trades to display';
  static const String emptyNoTradeHistory    = 'No trade history yet';

  // ── Settings group headers ───────────────────────────────────────────────
  static const String settingsGroupTrading      = 'Trading Settings';
  static const String settingsGroupConnection   = 'Connection Settings';
  static const String settingsGroupNotification = 'Notification Settings';

  // ── Settings tile labels ─────────────────────────────────────────────────
  // Trading Settings
  static const String settingStakeAmount          = 'Stake Amount';
  static const String settingTakeProfit           = 'Take Profit';
  static const String settingStopLoss             = 'Stop Loss';
  static const String settingMaxConcurrentTrades  = 'Max Concurrent Trades';
  static const String settingDailyProfitTarget    = 'Daily Profit Target';
  static const String settingDailyLossLimit       = 'Daily Loss Limit';
  static const String settingMartingaleMultiplier = 'Martingale Multiplier';
  static const String settingCooldownPeriod       = 'Cooldown Period';
  // Connection Settings
  static const String settingApiToken             = 'API Token';
  static const String settingPythonEngineUrl      = 'Python Engine URL';
  static const String settingAutoReconnect        = 'Auto Reconnect';
  // Notification Settings
  static const String settingTradeExecuted        = 'Trade Executed';
  static const String settingSignalReceived       = 'Signal Received';
  static const String settingBotStopped           = 'Bot Stopped';
  static const String settingConnectionLost       = 'Connection Lost';

  // ── ConnectionBadge labels ───────────────────────────────────────────────
  static const String badgeLive        = 'Live';
  static const String badgeConnecting  = 'Connecting';
  static const String badgeOffline     = 'Offline';
  static const String badgeError       = 'Error';

  // ── Error messages ───────────────────────────────────────────────────────
  static const String errorOAuthStateMismatch =
      'Security error: state mismatch. Please try again.';
  static const String errorOAuthFailure =
      'OAuth authentication failed. Please try again.';
  static const String errorUrlLaunchFailure =
      'Could not open the authentication URL. Please try again.';
}
