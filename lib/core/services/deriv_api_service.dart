import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ht_bot/core/config/supabase_config.dart';

/// Deriv API Service
/// Handles REST API and WebSocket connections to Deriv trading platform
class DerivApiService {
  static const String _baseUrl = 'https://api.derivws.com';
  static const String _publicWsUrl = 'wss://api.derivws.com/trading/v1/options/ws/public';
  
  WebSocketChannel? _wsChannel;
  String? _accessToken;
  String? _currentAccountId;
  
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  /// Stream of WebSocket messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  
  /// Initialize with access token
  void setAccessToken(String token) {
    _accessToken = token;
  }
  
  // ============================================================
  // ACCOUNT MANAGEMENT
  // ============================================================
  
  /// Get all Options trading accounts
  Future<List<Map<String, dynamic>>> getAccounts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trading/v1/options/accounts'),
      headers: {
        'Deriv-App-ID': SupabaseConfig.derivClientId,
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to get accounts: ${response.body}');
    }
  }
  
  /// Create new Options trading account
  Future<Map<String, dynamic>> createAccount({
    required String currency,
    required String accountType, // 'demo' or 'real'
    String group = 'row',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trading/v1/options/accounts'),
      headers: {
        'Deriv-App-ID': SupabaseConfig.derivClientId,
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currency': currency,
        'group': group,
        'account_type': accountType,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to create account: ${response.body}');
    }
  }
  
  /// Reset demo account balance
  Future<Map<String, dynamic>> resetDemoBalance(String accountId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trading/v1/options/accounts/$accountId/reset-demo-balance'),
      headers: {
        'Deriv-App-ID': SupabaseConfig.derivClientId,
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to reset demo balance: ${response.body}');
    }
  }
  
  // ============================================================
  // WEBSOCKET CONNECTION
  // ============================================================
  
  /// Get WebSocket URL with OTP for authenticated connection
  Future<String> _getWebSocketUrl(String accountId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trading/v1/options/accounts/$accountId/otp'),
      headers: {
        'Deriv-App-ID': SupabaseConfig.derivClientId,
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['url'];
    } else {
      throw Exception('Failed to get WebSocket URL: ${response.body}');
    }
  }
  
  /// Connect to WebSocket for authenticated trading
  Future<void> connectWebSocket(String accountId) async {
    await disconnectWebSocket();
    
    _currentAccountId = accountId;
    final wsUrl = await _getWebSocketUrl(accountId);
    
    _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    _wsChannel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _messageController.add(data);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }
  
  /// Connect to public WebSocket (no authentication, read-only market data)
  void connectPublicWebSocket() {
    disconnectWebSocket();
    
    _wsChannel = WebSocketChannel.connect(Uri.parse(_publicWsUrl));
    
    _wsChannel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _messageController.add(data);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }
  
  /// Disconnect WebSocket
  Future<void> disconnectWebSocket() async {
    await _wsChannel?.sink.close();
    _wsChannel = null;
  }
  
  /// Check if WebSocket is connected
  bool get isConnected => _wsChannel != null;
  
  /// Send message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (_wsChannel == null) {
      throw Exception('WebSocket not connected');
    }
    _wsChannel!.sink.add(jsonEncode(message));
  }
  
  // ============================================================
  // TRADING OPERATIONS (via WebSocket)
  // ============================================================
  
  /// Get price proposal for a contract
  void getProposal({
    required String contractType,
    required String symbol,
    required String currency,
    required double amount,
    required String basis, // 'payout' or 'stake'
    int? duration,
    String durationUnit = 's',
    String? barrier,
    bool subscribe = false,
  }) {
    sendMessage({
      'proposal': 1,
      'contract_type': contractType,
      'underlying_symbol': symbol,
      'currency': currency,
      'amount': amount,
      'basis': basis,
      if (duration != null) 'duration': duration,
      'duration_unit': durationUnit,
      if (barrier != null) 'barrier': barrier,
      if (subscribe) 'subscribe': 1,
    });
  }
  
  /// Buy contract using proposal ID
  void buyContract({
    required String proposalId,
    required double price,
  }) {
    sendMessage({
      'buy': proposalId,
      'price': price,
    });
  }
  
  /// Sell open contract
  void sellContract({
    required int contractId,
    required double price, // 0 for market price
  }) {
    sendMessage({
      'sell': contractId,
      'price': price,
    });
  }
  
  /// Get portfolio (open contracts)
  void getPortfolio({bool subscribe = false}) {
    sendMessage({
      'portfolio': 1,
      if (subscribe) 'subscribe': 1,
    });
  }
  
  /// Get profit table (closed contracts)
  void getProfitTable({
    int? limit,
    int? offset,
  }) {
    sendMessage({
      'profit_table': 1,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
  }
  
  /// Subscribe to price ticks for a symbol
  void subscribeTicks(String symbol) {
    sendMessage({
      'ticks': symbol,
      'subscribe': 1,
    });
  }
  
  /// Unsubscribe from ticks
  void unsubscribeTicks(String subscriptionId) {
    sendMessage({
      'forget': subscriptionId,
    });
  }
  
  /// Get active symbols (available markets)
  void getActiveSymbols() {
    sendMessage({
      'active_symbols': 'brief',
      'product_type': 'basic',
    });
  }
  
  /// Get trading times
  void getTradingTimes(String symbol) {
    sendMessage({
      'trading_times': symbol,
    });
  }
  
  /// Get account balance
  void getBalance({bool subscribe = false}) {
    sendMessage({
      'balance': 1,
      if (subscribe) 'subscribe': 1,
    });
  }
  
  /// Get statement (transaction history)
  void getStatement({
    int? limit,
    int? offset,
  }) {
    sendMessage({
      'statement': 1,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
  }
  
  // ============================================================
  // HELPER METHODS
  // ============================================================
  
  /// Listen for specific message types
  Stream<Map<String, dynamic>> listenForMessageType(String msgType) {
    return messages.where((msg) => msg['msg_type'] == msgType);
  }
  
  /// Get current account ID
  String? get currentAccountId => _currentAccountId;
  
  /// Dispose
  void dispose() {
    disconnectWebSocket();
    _messageController.close();
  }
}
