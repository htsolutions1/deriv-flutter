import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ht_bot/core/services/supabase_service.dart';
import 'package:ht_bot/core/config/supabase_config.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/shared/buttons/animated_button.dart';
import 'package:ht_bot/routing/app_router.dart';

/// Login screen with OAuth 2.0 flow
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Debug: Show configuration
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('OAuth Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Client ID:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(SupabaseConfig.derivClientId),
              const SizedBox(height: 8),
              const Text('Redirect URI:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(SupabaseConfig.derivRedirectUri),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _proceedWithOAuth();
              },
              child: const Text('Continue to Deriv'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _proceedWithOAuth() async {
    try {
      // Initiate OAuth flow
      final result = await SupabaseService.initiateOAuth(action: 'login');

      // Launch browser with authorization URL in app browser (not external)
      final uri = Uri.parse(result.authorizationUrl);
      if (await canLaunchUrl(uri)) {
        // Use inAppBrowserView for web so we can control the window
        await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        throw Exception('Could not launch browser');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initiate OAuth flow for signup
      final result = await SupabaseService.initiateOAuth(
        action: 'signup',
        utmParams: {
          // Add your UTM parameters if you have affiliate tracking
          // 'utm_source': 'your_source',
          // 'utm_medium': 'affiliate',
          // 'utm_campaign': 'your_campaign',
        },
      );

      // Launch browser with authorization URL
      final uri = Uri.parse(result.authorizationUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch browser');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    'HT',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Gap(24.h),
              
              // App name
              Text(
                'HTS Bot',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Gap(8.h),
              
              // Subtitle
              Text(
                'Deriv Binary Options Trading Bot',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              Gap(48.h),
              
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      Gap(8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Login button
              AnimatedButton(
                onTap: _isLoading ? null : _handleLogin,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Login with Deriv',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              Gap(16.h),
              
              // Signup button
              AnimatedButton(
                onTap: _isLoading ? null : _handleSignup,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD4AF37)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      _isLoading ? 'Loading...' : 'Sign Up with Deriv',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
              ),
              Gap(24.h),
              
              // Terms and conditions
              Text(
                'By continuing, you agree to Deriv\'s\nTerms and Conditions',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // OAuth Debug Button
              TextButton(
                onPressed: () {
                  context.go(AppRoutes.oauthDebug);
                },
                child: Text(
                  'Having OAuth issues? Click here',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFD4AF37),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
