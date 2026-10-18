import 'package:flutter/foundation.dart';

/// Immutable state model for the Settings screen.
///
/// Holds typed fields for all 15 configurable settings across three groups:
/// Trading, Connection, and Notifications.
///
/// Requirements: 7.1–7.3
@immutable
class SettingsState {
  // ---------------------------------------------------------------------------
  // Trading settings
  // ---------------------------------------------------------------------------

  /// Stake amount per trade in USD.
  final double stakeAmount;

  /// Take-profit threshold as a percentage.
  final double takeProfit;

  /// Stop-loss threshold as a percentage.
  final double stopLoss;

  /// Maximum number of trades allowed to run concurrently.
  final int maxConcurrentTrades;

  /// Daily profit target in USD.
  final double dailyProfitTarget;

  /// Daily loss limit in USD.
  final double dailyLossLimit;

  /// Martingale multiplier applied after a losing trade.
  final double martingaleMultiplier;

  /// Cooldown period in seconds between trades.
  final int cooldownPeriod;

  // ---------------------------------------------------------------------------
  // Connection settings
  // ---------------------------------------------------------------------------

  /// Deriv API authentication token.
  final String apiToken;

  /// URL of the Python trading engine WebSocket endpoint.
  final String pythonEngineUrl;

  /// Whether to automatically reconnect on connection loss.
  final bool autoReconnect;

  // ---------------------------------------------------------------------------
  // Notification settings
  // ---------------------------------------------------------------------------

  /// Notify when a trade is executed.
  final bool tradeExecuted;

  /// Notify when a new signal is received.
  final bool signalReceived;

  /// Notify when the bot stops unexpectedly.
  final bool botStopped;

  /// Notify when the connection is lost.
  final bool connectionLost;

  const SettingsState({
    this.stakeAmount = 2.0,
    this.takeProfit = 5.0,
    this.stopLoss = 2.0,
    this.maxConcurrentTrades = 3,
    this.dailyProfitTarget = 50.0,
    this.dailyLossLimit = 30.0,
    this.martingaleMultiplier = 1.0,
    this.cooldownPeriod = 30,
    this.apiToken = '',
    this.pythonEngineUrl = '',
    this.autoReconnect = false,
    this.tradeExecuted = false,
    this.signalReceived = false,
    this.botStopped = false,
    this.connectionLost = false,
  });

  /// Returns a state populated with all default setting values.
  factory SettingsState.defaults() => const SettingsState(
        stakeAmount: 2.0,
        takeProfit: 5.0,
        stopLoss: 2.0,
        maxConcurrentTrades: 3,
        dailyProfitTarget: 50.0,
        dailyLossLimit: 30.0,
        martingaleMultiplier: 1.0,
        cooldownPeriod: 30,
        apiToken: '',
        pythonEngineUrl: '',
        autoReconnect: false,
        tradeExecuted: false,
        signalReceived: false,
        botStopped: false,
        connectionLost: false,
      );

  /// Returns a copy of this state with the provided fields replaced.
  SettingsState copyWith({
    double? stakeAmount,
    double? takeProfit,
    double? stopLoss,
    int? maxConcurrentTrades,
    double? dailyProfitTarget,
    double? dailyLossLimit,
    double? martingaleMultiplier,
    int? cooldownPeriod,
    String? apiToken,
    String? pythonEngineUrl,
    bool? autoReconnect,
    bool? tradeExecuted,
    bool? signalReceived,
    bool? botStopped,
    bool? connectionLost,
  }) {
    return SettingsState(
      stakeAmount: stakeAmount ?? this.stakeAmount,
      takeProfit: takeProfit ?? this.takeProfit,
      stopLoss: stopLoss ?? this.stopLoss,
      maxConcurrentTrades: maxConcurrentTrades ?? this.maxConcurrentTrades,
      dailyProfitTarget: dailyProfitTarget ?? this.dailyProfitTarget,
      dailyLossLimit: dailyLossLimit ?? this.dailyLossLimit,
      martingaleMultiplier: martingaleMultiplier ?? this.martingaleMultiplier,
      cooldownPeriod: cooldownPeriod ?? this.cooldownPeriod,
      apiToken: apiToken ?? this.apiToken,
      pythonEngineUrl: pythonEngineUrl ?? this.pythonEngineUrl,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      tradeExecuted: tradeExecuted ?? this.tradeExecuted,
      signalReceived: signalReceived ?? this.signalReceived,
      botStopped: botStopped ?? this.botStopped,
      connectionLost: connectionLost ?? this.connectionLost,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          stakeAmount == other.stakeAmount &&
          takeProfit == other.takeProfit &&
          stopLoss == other.stopLoss &&
          maxConcurrentTrades == other.maxConcurrentTrades &&
          dailyProfitTarget == other.dailyProfitTarget &&
          dailyLossLimit == other.dailyLossLimit &&
          martingaleMultiplier == other.martingaleMultiplier &&
          cooldownPeriod == other.cooldownPeriod &&
          apiToken == other.apiToken &&
          pythonEngineUrl == other.pythonEngineUrl &&
          autoReconnect == other.autoReconnect &&
          tradeExecuted == other.tradeExecuted &&
          signalReceived == other.signalReceived &&
          botStopped == other.botStopped &&
          connectionLost == other.connectionLost;

  @override
  int get hashCode => Object.hash(
        stakeAmount,
        takeProfit,
        stopLoss,
        maxConcurrentTrades,
        dailyProfitTarget,
        dailyLossLimit,
        martingaleMultiplier,
        cooldownPeriod,
        apiToken,
        pythonEngineUrl,
        autoReconnect,
        tradeExecuted,
        signalReceived,
        botStopped,
        connectionLost,
      );

  @override
  String toString() => 'SettingsState('
      'stakeAmount: $stakeAmount, '
      'takeProfit: $takeProfit, '
      'stopLoss: $stopLoss, '
      'maxConcurrentTrades: $maxConcurrentTrades, '
      'dailyProfitTarget: $dailyProfitTarget, '
      'dailyLossLimit: $dailyLossLimit, '
      'martingaleMultiplier: $martingaleMultiplier, '
      'cooldownPeriod: $cooldownPeriod, '
      'apiToken: [hidden], '
      'pythonEngineUrl: $pythonEngineUrl, '
      'autoReconnect: $autoReconnect, '
      'tradeExecuted: $tradeExecuted, '
      'signalReceived: $signalReceived, '
      'botStopped: $botStopped, '
      'connectionLost: $connectionLost)';
}
