import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/services/deriv_api_service.dart';

/// Deriv API Service provider
final derivApiProvider = Provider<DerivApiService>((ref) {
  final service = DerivApiService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// WebSocket connection state provider
final wsConnectionProvider = StateProvider<bool>((ref) => false);

/// Current account provider
final currentAccountProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Account balance provider
final accountBalanceProvider = StateProvider<double>((ref) => 0.0);

/// Active trades provider
final activeTradesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
