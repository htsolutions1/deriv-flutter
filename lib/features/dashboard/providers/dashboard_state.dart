import 'package:flutter/foundation.dart';
import 'package:ht_bot/core/enums/app_enums.dart';

/// Immutable state model for the Dashboard screen.
///
/// Null numeric fields signal "no data yet" and the UI renders "--".
/// A null [winRate] causes the win-rate chart to show an [EmptyState].
///
/// Requirements: 4.1–4.5
@immutable
class DashboardState {
  /// Current account balance. Null → display "--".
  final double? balance;

  /// Profit earned today. Null → display "--".
  final double? todayProfit;

  /// Win rate as a percentage (0–100). Null → show EmptyState in chart.
  final double? winRate;

  /// Number of currently active trades.
  final int activeTrades;

  /// Number of trades executed today.
  final int tradesToday;

  /// Current operational status of the trading bot.
  final BotStatus botStatus;

  /// Current WebSocket / API connection status.
  final ConnectionStatus connectionStatus;

  const DashboardState({
    this.balance,
    this.todayProfit,
    this.winRate,
    this.activeTrades = 0,
    this.tradesToday = 0,
    this.botStatus = BotStatus.idle,
    this.connectionStatus = ConnectionStatus.disconnected,
  });

  /// Returns a state with all fields at their empty/default values.
  factory DashboardState.empty() => const DashboardState(
        balance: null,
        todayProfit: null,
        winRate: null,
        activeTrades: 0,
        tradesToday: 0,
        botStatus: BotStatus.idle,
        connectionStatus: ConnectionStatus.disconnected,
      );

  /// Returns a copy of this state with the provided fields replaced.
  DashboardState copyWith({
    double? balance,
    double? todayProfit,
    double? winRate,
    int? activeTrades,
    int? tradesToday,
    BotStatus? botStatus,
    ConnectionStatus? connectionStatus,
    // Explicit sentinels to allow nulling out nullable fields.
    bool clearBalance = false,
    bool clearTodayProfit = false,
    bool clearWinRate = false,
  }) {
    return DashboardState(
      balance: clearBalance ? null : (balance ?? this.balance),
      todayProfit:
          clearTodayProfit ? null : (todayProfit ?? this.todayProfit),
      winRate: clearWinRate ? null : (winRate ?? this.winRate),
      activeTrades: activeTrades ?? this.activeTrades,
      tradesToday: tradesToday ?? this.tradesToday,
      botStatus: botStatus ?? this.botStatus,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardState &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          todayProfit == other.todayProfit &&
          winRate == other.winRate &&
          activeTrades == other.activeTrades &&
          tradesToday == other.tradesToday &&
          botStatus == other.botStatus &&
          connectionStatus == other.connectionStatus;

  @override
  int get hashCode => Object.hash(
        balance,
        todayProfit,
        winRate,
        activeTrades,
        tradesToday,
        botStatus,
        connectionStatus,
      );

  @override
  String toString() => 'DashboardState('
      'balance: $balance, '
      'todayProfit: $todayProfit, '
      'winRate: $winRate, '
      'activeTrades: $activeTrades, '
      'tradesToday: $tradesToday, '
      'botStatus: $botStatus, '
      'connectionStatus: $connectionStatus)';
}
