import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ht_bot/core/services/supabase_service.dart';
import 'package:ht_bot/core/providers/service_providers.dart';
import 'package:ht_bot/routing/app_router.dart';
import 'package:ht_bot/core/constants/app_colors.dart';

/// OAuth callback screen
/// This screen handles the redirect from Deriv after authentication
class OAuthCallbackScreen extends ConsumerStatefulWidget {
  final String? code;
  final String? state;
  final String? error;
  final String? errorDescription;

  const OAuthCallbackScreen({
    super.key,
    this.code,
    this.state,
    this.error,
    this.errorDescription,
  });

  @override
  ConsumerState<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends ConsumerState<OAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    // Check for errors
    if (widget.error != null) {
      _showError(widget.errorDescription ?? widget.error ?? 'Authentication failed');
      return;
    }

    // Validate required parameters
    if (widget.code == null || widget.state == null) {
      _showError('Missing required parameters');
      return;
    }

    try {
      // Exchange code for token
      final result = await SupabaseService.handleOAuthCallback(
        code: widget.code!,
        state: widget.state!,
      );

      // Get access token from database
      final userId = result['user_id'] as String;
      final userResponse = await SupabaseService.client
          .from('users')
          .select('deriv_access_token')
          .eq('id', userId)
          .single();
      
      final accessToken = userResponse['deriv_access_token'] as String;
      
      // Set access token in DerivApiService
      final derivApi = ref.read(derivApiServiceProvider);
      derivApi.setAccessToken(accessToken);

      // Navigate to dashboard - the controller will initialize on mount
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.login);
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Completing authentication...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
