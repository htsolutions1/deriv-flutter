import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';

class LoginScreenNew extends StatefulWidget {
  const LoginScreenNew({super.key});

  @override
  State<LoginScreenNew> createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends State<LoginScreenNew>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleOAuthLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithOAuth();
      if (result && mounted) {
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final cardWidth = isSmallScreen ? size.width * 0.9 : 480.0;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A4D4E),
              Color(0xFF064344),
              Color(0xFF083A3B),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 24,
                vertical: 24,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: cardWidth,
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: EdgeInsets.all(isSmallScreen ? 32 : 48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/deriv_logo.png',
                            height: isSmallScreen ? 40 : 50,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: isSmallScreen ? 40 : 50,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF444F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'DERIV',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 32 : 40),
                        
                        // Title
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 26 : 30,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        Text(
                          'Sign in to continue trading',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: const Color(0xFF7F8C8D),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 36 : 48),
                        
                        // OAuth Login Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleOAuthLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF444F),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: const Color(0xFFFF444F).withOpacity(0.6),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login_rounded, size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sign in with Deriv OAuth',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Divider with text
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Secure Trading Platform',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: const Color(0xFF95A5A6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // Features
                        _buildFeatureRow(
                          Icons.security_rounded,
                          'Secure OAuth Authentication',
                          isSmallScreen,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.speed_rounded,
                          'Real-time Market Data',
                          isSmallScreen,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.trending_up_rounded,
                          'Advanced Trading Tools',
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 32 : 40),
                        
                        // Footer text
                        Text(
                          'By signing in, you agree to our Terms of Service and Privacy Policy',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: const Color(0xFF95A5A6),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isSmall) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A4D4E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF0A4D4E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
              color: const Color(0xFF5D6D7E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
