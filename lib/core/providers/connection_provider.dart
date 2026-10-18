import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/app_enums.dart';

/// Tracks the current WebSocket / API connection state.
///
/// Defaults to [ConnectionStatus.disconnected] on app start.
/// Requirements: 3.10
final connectionStatusProvider = StateProvider<ConnectionStatus>(
  (ref) => ConnectionStatus.disconnected,
);
