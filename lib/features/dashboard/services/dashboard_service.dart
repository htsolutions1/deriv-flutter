import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ht_bot/core/enums/app_enums.dart';
import 'package:ht_bot/core/services/deriv_api_service.dart';
import 'package:ht_bot/core/services/supabase_service.dart';
import 'package:ht_bot/core/providers/service_providers.dart';
import 'package:ht_bot/features/dashboard/providers/dashboard_state.dart';

/// Service to fetch and update dashboard metrics from Deriv API
class DashboardService {
  final DerivApiService _derivApi;
  final SupabaseService _supabase;
  final StateController<DashboardState> _stateController;
  
  StreamSubscription? _balanceSubscription;
  StreamSubscription? _portfolioSubscription;
  
  bool _isConnected = false;
  double? _currentBalance;
  int _activeContracts = 0;
  
  DashboardService(this._derivApi, this._supabase, this._stateController);
  
  /// Initialize dashboard with real Deriv account data
  Future<void> initialize(String accountId) async {
    try {
      // Connect to WebSocket
      await _derivApi.connectWebSocket(accountId);
      _isConnected = true;
      
      // Update connection status
      _updateDashboard((state) => state.copyWith(
        connectionStatus: ConnectionStatus.connected,
      ));
      
      // Subscribe to balance updates
      _subscribeToBalance();
      
      // Subscribe to portfolio (open contracts)
      _subscribeToPortfolio();
      
      // Fetch today's profit from profit table
      await _fetchTodayProfit();
      
      // Fetch win rate from database
      await _fetchWinRate();
      
    } catch (e) {
      print('Dashboard initialization error: $e');
      _updateDashboard((state) => state.copyWith(
        connectionStatus: ConnectionStatus.error,
      ));
    }
  }
  
  /// Subscribe to real-time balance updates
  void _subscribeToBalance() {
    _derivApi.getBalance(subscribe: true);
    
    _balanceSubscription = _derivApi
        .listenForMessageType('balance')
        .listen((message) {
      if (message['balance'] != null) {
        final balance = (message['balance']['balance'] as num).toDouble();
        _currentBalance = balance;
        
        _updateDashboard((state) => state.copyWith(
          balance: balance,
        ));
      }
    });
  }
  
  /// Subscribe to portfolio (open contracts) updates
  void _subscribeToPortfolio() {
    _derivApi.getPortfolio(subscribe: true);
    
    _portfolioSubscription = _derivApi
        .listenForMessageType('portfolio')
        .listen((message) {
      if (message['portfolio'] != null && message['portfolio']['contracts'] != null) {
        final contracts = message['portfolio']['contracts'] as List;
        _activeContracts = contracts.length;
        
        _updateDashboard((state) => state.copyWith(
          activeTrades: _activeContracts,
        ));
      }
    });
  }
  
  /// Fetch today's profit from profit table
  Future<void> _fetchTodayProfit() async {
    _derivApi.getProfitTable(limit: 1000);
    
    final profitSubscription = _derivApi
        .listenForMessageType('profit_table')
        .first
        .timeout(const Duration(seconds: 10));
    
    try {
      final message = await profitSubscription;
      
      if (message['profit_table'] != null && 
          message['profit_table']['transactions'] != null) {
        final transactions = message['profit_table']['transactions'] as List;
        
        // Calculate today's profit
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayStartTimestamp = todayStart.millisecondsSinceEpoch ~/ 1000;
        
        double todayProfit = 0.0;
        int todayTradeCount = 0;
        
        for (var tx in transactions) {
          final txTime = tx['sell_time'] as int?;
          if (txTime != null && txTime >= todayStartTimestamp) {
            final profit = (tx['sell_price'] as num).toDouble() - 
                          (tx['buy_price'] as num).toDouble();
            todayProfit += profit;
            todayTradeCount++;
          }
        }
        
        _updateDashboard((state) => state.copyWith(
          todayProfit: todayProfit,
          tradesToday: todayTradeCount,
        ));
      }
    } catch (e) {
      print('Error fetching today\'s profit: $e');
    }
  }
  
  /// Fetch win rate from database
  Future<void> _fetchWinRate() async {
    try {
      final userId = _supabase.instanceCurrentUserId;
      if (userId == null) return;
      
      // Get trades from last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final trades = await _supabase.instanceClient
          .from('trades')
          .select()
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false);
      
      if (trades.isEmpty) {
        _updateDashboard((state) => state.copyWith(winRate: null));
        return;
      }
      
      // Calculate win rate
      final totalTrades = trades.length;
      final winningTrades = trades.where((trade) {
        final profit = trade['profit'] as num?;
        return profit != null && profit > 0;
      }).length;
      
      final winRate = (winningTrades / totalTrades) * 100;
      
      _updateDashboard((state) => state.copyWith(
        winRate: winRate,
      ));
    } catch (e) {
      print('Error fetching win rate: $e');
    }
  }
  
  /// Refresh all dashboard data
  Future<void> refresh() async {
    if (!_isConnected) return;
    
    await _fetchTodayProfit();
    await _fetchWinRate();
    
    // Re-fetch balance
    _derivApi.getBalance();
    
    // Re-fetch portfolio
    _derivApi.getPortfolio();
  }
  
  /// Update bot status
  void updateBotStatus(BotStatus status) {
    _updateDashboard((state) => state.copyWith(
      botStatus: status,
    ));
  }
  
  /// Update dashboard state
  void _updateDashboard(DashboardState Function(DashboardState) updater) {
    _stateController.state = updater(_stateController.state);
  }
  
  /// Check connection status
  bool get isConnected => _isConnected;
  
  /// Get current balance
  double? get currentBalance => _currentBalance;
  
  /// Get active contracts count
  int get activeContracts => _activeContracts;
  
  /// Dispose and cleanup
  void dispose() {
    _balanceSubscription?.cancel();
    _portfolioSubscription?.cancel();
    _isConnected = false;
  }
}

/// Provider for DashboardService
/// Note: This provider should be used within a context that has dashboardStateControllerProvider
final dashboardServiceProvider = Provider.family<DashboardService, StateController<DashboardState>>((ref, stateController) {
  final derivApi = ref.watch(derivApiServiceProvider);
  final supabase = ref.watch(supabaseServiceProvider);
  
  return DashboardService(derivApi, supabase, stateController);
});
