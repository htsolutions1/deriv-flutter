import 'package:flutter/foundation.dart';

import '../enums/app_enums.dart';

/// Domain model representing a trading signal (UI layer only — no persistence).
///
/// Requirements: 6.4
@immutable
class SignalModel {
  final String id;
  final TradeDirection direction;
  final String? source;
  final DateTime? timestamp;
  final SignalStatus status;

  const SignalModel({
    required this.id,
    required this.direction,
    required this.status,
    this.source,
    this.timestamp,
  });
}
