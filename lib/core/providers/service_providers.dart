import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/services/deriv_api_service.dart';
import 'package:ht_bot/core/services/supabase_service.dart';

/// Provider for DerivApiService singleton
final derivApiServiceProvider = Provider<DerivApiService>((ref) {
  return DerivApiService();
});

/// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
