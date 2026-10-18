import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/services/supabase_service.dart';
import 'package:ht_bot/core/providers/service_providers.dart';
import 'package:ht_bot/features/dashboard/services/dashboard_service.dart';
import 'package:ht_bot/features/dashboard/providers/dashboard_state.dart';

/// Controller to initialize dashboard on mount
class DashboardController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  DashboardService? _dashboardService;
  
  DashboardController(this._ref) 
      : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    state = const AsyncValue.loading();
    
    try {
      // Get user's access token and account
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        state = AsyncValue.error('User not authenticated', StackTrace.current);
        return;
      }
      
      // Get Deriv access token from database
      final userResponse = await SupabaseService.client
          .from('users')
          .select('deriv_access_token')
          .eq('id', userId)
          .single();
      
      final accessToken = userResponse['deriv_access_token'] as String?;
      if (accessToken == null) {
        state = AsyncValue.error('Deriv access token not found', StackTrace.current);
        return;
      }
      
      final derivApi = _ref.read(derivApiServiceProvider);
      
      // Set access token
      derivApi.setAccessToken(accessToken);
      
      // Get first account
      final accounts = await derivApi.getAccounts();
      if (accounts.isEmpty) {
        state = AsyncValue.error('No Deriv accounts found', StackTrace.current);
        return;
      }
      
      final accountId = accounts[0]['id'] as String;
      
      // Get dashboard state controller
      final stateController = _ref.read(dashboardStateControllerProvider.notifier);
      
      // Create dashboard service
      final supabase = _ref.read(supabaseServiceProvider);
      _dashboardService = DashboardService(derivApi, supabase, stateController);
      
      // Initialize dashboard
      await _dashboardService!.initialize(accountId);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Manually refresh dashboard data
  Future<void> refresh() async {
    try {
      await _dashboardService?.refresh();
    } catch (e) {
      // Silent fail on refresh
      print('Dashboard refresh error: $e');
    }
  }
}

/// State controller provider for dashboard state
final dashboardStateControllerProvider = 
    StateProvider<DashboardState>((ref) => DashboardState.empty());

/// Provider for dashboard controller
final dashboardControllerProvider = 
    StateNotifierProvider<DashboardController, AsyncValue<void>>((ref) {
  return DashboardController(ref);
});
