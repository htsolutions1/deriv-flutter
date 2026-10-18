import 'package:flutter/material.dart';

/// Defines the canonical color palette for HT BOT.
///
/// All colors are compile-time constants. Semantic aliases reference the
/// primary constants so a single value change propagates everywhere.
///
/// Requirements: 1.2, 12.3
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Base palette
  // ---------------------------------------------------------------------------

  /// Main scaffold/background — #EAF4FF
  static const Color background = Color(0xFFEAF4FF);

  /// Glass card surface — rgba(255, 255, 255, 0.55)
  static const Color surface = Color(0x8CFFFFFF);

  /// Gold accent — #D4AF37
  static const Color accent = Color(0xFFD4AF37);

  /// Primary body text — #243447
  static const Color primaryText = Color(0xFF243447);

  /// Secondary / muted text — #64748B
  static const Color secondaryText = Color(0xFF64748B);

  /// Positive / profit / buy — #22C55E
  static const Color success = Color(0xFF22C55E);

  /// Negative / loss / sell — #EF4444
  static const Color loss = Color(0xFFEF4444);

  /// Card border — rgba(255, 255, 255, 0.35)
  static const Color border = Color(0x59FFFFFF);

  // ---------------------------------------------------------------------------
  // Semantic aliases
  // ---------------------------------------------------------------------------

  /// Buy-side trade direction label color (= success green)
  static const Color buyColor = success;

  /// Sell-side trade direction label color (= loss red)
  static const Color sellColor = loss;

  /// WebSocket / API connection active (= success green)
  static const Color connected = success;

  /// WebSocket / API connection offline — orange-500 #F97316
  static const Color disconnected = Color(0xFFF97316);

  /// Error state color (= loss red)
  static const Color error = loss;
}
