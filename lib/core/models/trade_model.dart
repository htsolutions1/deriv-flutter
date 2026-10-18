import 'package:flutter/foundation.dart';

import '../enums/app_enums.dart';

/// Domain model representing a single trade (UI layer only — no persistence).
///
/// Requirements: 5.4
@immutable
class TradeModel {
  final String id;
  final TradeDirection direction;
  final double? stake;
  final double? entryPrice;
  final Duration? duration;
  final double? takeProfit;
  final double? stopLoss;
  final double? currentPnl;
  final TradeOutcome outcome;
  final DateTime? openedAt;

  const TradeModel({
    required this.id,
    required this.direction,
    required this.outcome,
    this.stake,
    this.entryPrice,
    this.duration,
    this.takeProfit,
    this.stopLoss,
    this.currentPnl,
    this.openedAt,
  });
}
