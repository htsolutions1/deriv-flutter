import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:ht_bot/core/config/supabase_config.dart';

/// Result of OAuth initiation
class OAuthInitResult {
  final String authorizationUrl;
  final String state;

  OAuthInitResult({
    required this.authorizationUrl,
    required this.state,
  });
}

/// Supabase service for backend integration
/// Handles authentication, database, and Edge Functions
class SupabaseService {
  static late SupabaseClient _client;
  
  /// Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client => _client;
  
  /// Instance access to client
  SupabaseClient get instanceClient => _client;
  
  /// Get current authenticated user
  static User? get currentUser => _client.auth.currentUser;
  
  /// Instance access to current user
  User? get instanceCurrentUser => _client.auth.currentUser;
  
  /// Get current user ID
  static String? get currentUserId => currentUser?.id;
  
  /// Instance access to current user ID
  String? get instanceCurrentUserId => instanceCurrentUser?.id;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  // ============================================================
  // AUTHENTICATION (OAuth with Deriv)
  // ============================================================
  
  /// Initiate OAuth login/signup flow
  /// Returns authorization URL to open in browser
  static Future<OAuthInitResult> initiateOAuth({
    required String action, // 'login' or 'signup'
    Map<String, String>? utmParams,
  }) async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = await _generateCodeChallenge(codeVerifier);
    final state = _generateState();

    // Store OAuth session in database
    await _client.from('oauth_sessions').insert({
      'state': state,
      'code_verifier': codeVerifier,
      'code_challenge': codeChallenge,
      'redirect_uri': SupabaseConfig.derivRedirectUri,
      'scopes': ['trade', 'account_manage'],
      'is_signup': action == 'signup',
      'utm_source': utmParams?['utm_source'],
      'utm_medium': utmParams?['utm_medium'],
      'utm_campaign': utmParams?['utm_campaign'],
      'tracking_token': utmParams?['tracking_token'],
    });

    // Build authorization URL
    final authUrl = Uri.https('auth.deriv.com', '/oauth2/auth', {
      'response_type': 'code',
      'client_id': SupabaseConfig.derivClientId,
      'redirect_uri': SupabaseConfig.derivRedirectUri,
      'scope': 'trade account_manage',
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      if (action == 'signup') ...{
        'prompt': 'registration',
        if (utmParams?['tracking_token'] != null) 't': utmParams!['tracking_token']!,
        if (utmParams?['utm_campaign'] != null) 'utm_campaign': utmParams!['utm_campaign']!,
        if (utmParams?['utm_medium'] != null) 'utm_medium': utmParams!['utm_medium']!,
        if (utmParams?['utm_source'] != null) 'utm_source': utmParams!['utm_source']!,
      },
    });

    return OAuthInitResult(
      authorizationUrl: authUrl.toString(),
      state: state,
    );
  }
  
  /// Handle OAuth callback after user authenticates
  /// Call this with code and state from redirect URL
  static Future<Map<String, dynamic>> handleOAuthCallback({
    required String code,
    required String state,
  }) async {
    // Get OAuth session from database
    final response = await _client
        .from('oauth_sessions')
        .select()
        .eq('state', state)
        .eq('status', 'pending')
        .single();

    final codeVerifier = response['code_verifier'] as String;

    // Exchange code for token with Deriv
    final tokenResponse = await http.post(
      Uri.parse('https://auth.deriv.com/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': SupabaseConfig.derivClientId,
        'code': code,
        'code_verifier': codeVerifier,
        'redirect_uri': SupabaseConfig.derivRedirectUri,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Token exchange failed: ${tokenResponse.body}');
    }

    final tokenData = jsonDecode(tokenResponse.body);
    final accessToken = tokenData['access_token'] as String;

    // Get user info from Deriv
    final userInfoResponse = await http.get(
      Uri.parse('https://api.derivws.com/trading/v1/accounts'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (userInfoResponse.statusCode != 200) {
      throw Exception('Failed to get user info: ${userInfoResponse.body}');
    }

    final userInfo = jsonDecode(userInfoResponse.body);

    // Check if user exists
    final existingUser = await _client
        .from('users')
        .select('id')
        .eq('email', userInfo['email'])
        .maybeSingle();

    String userId;

    if (existingUser != null) {
      // Update existing user
      userId = existingUser['id'] as String;
      await _client.from('users').update({
        'deriv_access_token': accessToken,
        'deriv_token_expires_at': DateTime.now()
            .add(Duration(seconds: tokenData['expires_in'] as int))
            .toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } else {
      // Create new user via Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: userInfo['email'],
        password: _generateSecurePassword(),
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      userId = authResponse.user!.id;

      // Insert user data
      await _client.from('users').insert({
        'id': userId,
        'email': userInfo['email'],
        'full_name': userInfo['name'],
        'deriv_account_id': userInfo['account_id'],
        'deriv_access_token': accessToken,
        'deriv_token_expires_at': DateTime.now()
            .add(Duration(seconds: tokenData['expires_in'] as int))
            .toIso8601String(),
      });

      // Create default preferences
      await _client.from('user_preferences').insert({
        'user_id': userId,
      });
    }

    // Mark OAuth session as completed
    await _client.from('oauth_sessions').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('state', state);

    // Sign in user
    await _client.auth.signInWithPassword(
      email: userInfo['email'],
      password: '', // Password is stored in auth, not used for Deriv OAuth
    );

    return {
      'user_id': userId,
      'email': userInfo['email'],
      'deriv_account_id': userInfo['account_id'],
    };
  }
  
  // Helper functions for OAuth PKCE
  static String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  static Future<String> _generateCodeChallenge(String verifier) async {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _generateSecurePassword() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }
  
  /// Sign out user
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // ============================================================
  // DASHBOARD
  // ============================================================
  
  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    if (currentUser == null) throw Exception('User not authenticated');

    // Get active bots count
    final activeBotsResponse = await _client
        .from('bots')
        .select()
        .eq('user_id', currentUser!.id)
        .eq('status', 'running');

    final activeBots = List<Map<String, dynamic>>.from(activeBotsResponse);

    // Get active trades count
    final activeTradesResponse = await _client
        .from('trades')
        .select()
        .eq('user_id', currentUser!.id)
        .eq('outcome', 'open');

    final activeTrades = List<Map<String, dynamic>>.from(activeTradesResponse);

    // Get today's trades
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todayTradesData = await _client
        .from('trades')
        .select('pnl, outcome')
        .eq('user_id', currentUser!.id)
        .gte('opened_at', todayStart.toIso8601String());

    final todayTrades = todayTradesData as List;
    final todayTradesCount = todayTrades.length;
    final todayProfit = todayTrades.fold<double>(
      0.0,
      (sum, trade) => sum + (trade['pnl'] as double? ?? 0.0),
    );
    final todayWins = todayTrades.where((t) => t['outcome'] == 'win').length;
    final todayWinRate = todayTradesCount > 0 ? (todayWins / todayTradesCount) * 100 : 0.0;

    // Get latest connection status
    final latestConnection = await _client
        .from('api_connections')
        .select('status')
        .eq('user_id', currentUser!.id)
        .eq('connection_type', 'websocket')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    // Get recent signals
    final recentSignals = await _client
        .from('signals')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(5);

    // Get total balance
    final allTradesData = await _client
        .from('trades')
        .select('pnl')
        .eq('user_id', currentUser!.id)
        .neq('outcome', 'open');

    final allTrades = allTradesData as List;
    final totalBalance = allTrades.fold<double>(
      0.0,
      (sum, trade) => sum + (trade['pnl'] as double? ?? 0.0),
    );

    return {
      'connection_status': latestConnection?['status'] ?? 'disconnected',
      'active_bots_count': activeBots.length,
      'active_trades_count': activeTrades.length,
      'today_trades': todayTradesCount,
      'today_profit': double.parse(todayProfit.toStringAsFixed(2)),
      'win_rate_today': double.parse(todayWinRate.toStringAsFixed(2)),
      'total_balance': double.parse(totalBalance.toStringAsFixed(2)),
      'recent_signals': recentSignals,
    };
  }
  
  // ============================================================
  // BOTS
  // ============================================================
  
  /// Get all user bots
  static Future<List<Map<String, dynamic>>> getBots() async {
    final response = await _client
        .from('bots')
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Create new bot
  static Future<Map<String, dynamic>> createBot({
    required String name,
    required String strategyType,
    required Map<String, dynamic> strategyConfig,
    String? description,
    double? maxDailyLoss,
  }) async {
    final response = await _client
        .from('bots')
        .insert({
          'name': name,
          'description': description,
          'strategy_type': strategyType,
          'strategy_config': strategyConfig,
          'max_daily_loss': maxDailyLoss,
        })
        .select()
        .single();
    
    return response;
  }
  
  /// Update bot
  static Future<Map<String, dynamic>> updateBot(
    String botId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _client
        .from('bots')
        .update(updates)
        .eq('id', botId)
        .select()
        .single();
    
    return response;
  }
  
  /// Delete bot
  static Future<void> deleteBot(String botId) async {
    await _client.from('bots').delete().eq('id', botId);
  }
  
  // ============================================================
  // TRADES
  // ============================================================
  
  /// Get all trades with optional filters
  static Future<List<Map<String, dynamic>>> getTrades({
    String? outcome, // 'open', 'win', 'loss'
    int limit = 50,
    int offset = 0,
  }) async {
    PostgrestFilterBuilder query = _client
        .from('trades')
        .select();
    
    if (outcome != null) {
      query = query.eq('outcome', outcome);
    }
    
    final response = await query
        .order('opened_at', ascending: false)
        .range(offset, offset + limit - 1);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Get active trades only
  static Future<List<Map<String, dynamic>>> getActiveTrades() async {
    return getTrades(outcome: 'open');
  }
  
  /// Get trade history (closed trades)
  static Future<List<Map<String, dynamic>>> getTradeHistory({
    String? outcome, // 'win' or 'loss'
    int limit = 50,
    int offset = 0,
  }) async {
    PostgrestFilterBuilder query = _client
        .from('trades')
        .select()
        .neq('outcome', 'open');
    
    if (outcome != null) {
      query = query.eq('outcome', outcome);
    }
    
    final response = await query
        .order('closed_at', ascending: false)
        .range(offset, offset + limit - 1);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Create new trade
  static Future<Map<String, dynamic>> createTrade({
    required String direction,
    required String symbol,
    required String contractType,
    required double stake,
    required int durationSeconds,
    String? botId,
  }) async {
    final response = await _client
        .from('trades')
        .insert({
          'direction': direction,
          'symbol': symbol,
          'contract_type': contractType,
          'stake': stake,
          'duration_seconds': durationSeconds,
          'bot_id': botId,
        })
        .select()
        .single();
    
    return response;
  }
  
  // ============================================================
  // SIGNALS
  // ============================================================
  
  /// Get recent signals
  static Future<List<Map<String, dynamic>>> getSignals({
    String? status, // 'pending', 'executed'
    int limit = 20,
  }) async {
    PostgrestFilterBuilder query = _client
        .from('signals')
        .select();
    
    if (status != null) {
      query = query.eq('status', status);
    }
    
    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // ============================================================
  // NOTIFICATIONS
  // ============================================================
  
  /// Get user notifications
  static Future<List<Map<String, dynamic>>> getNotifications({
    bool? isRead,
    int limit = 20,
  }) async {
    PostgrestFilterBuilder query = _client
        .from('notifications')
        .select();
    
    if (isRead != null) {
      query = query.eq('is_read', isRead);
    }
    
    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('id', notificationId);
  }
  
  // ============================================================
  // REALTIME SUBSCRIPTIONS
  // ============================================================
  
  /// Subscribe to new signals
  static Stream<List<Map<String, dynamic>>> subscribeToSignals() {
    return _client
        .from('signals')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending');
  }
  
  /// Subscribe to active trades updates
  static Stream<List<Map<String, dynamic>>> subscribeToActiveTrades() {
    return _client
        .from('trades')
        .stream(primaryKey: ['id'])
        .eq('outcome', 'open');
  }
  
  /// Subscribe to notifications
  static Stream<List<Map<String, dynamic>>> subscribeToNotifications() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('is_read', false);
  }
  
  // ============================================================
  // USER PREFERENCES
  // ============================================================
  
  /// Get user preferences
  static Future<Map<String, dynamic>> getPreferences() async {
    final response = await _client
        .from('user_preferences')
        .select()
        .eq('user_id', currentUser!.id)
        .single();
    
    return response;
  }
  
  /// Update user preferences
  static Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> updates,
  ) async {
    final response = await _client
        .from('user_preferences')
        .update(updates)
        .eq('user_id', currentUser!.id)
        .select()
        .single();
    
    return response;
  }
}
