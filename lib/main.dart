import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ht_bot/theme/app_theme.dart';
import 'package:ht_bot/routing/app_router.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/config/supabase_config.dart';
import 'package:ht_bot/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  runApp(const ProviderScope(child: HtBotApp()));
}

class HtBotApp extends ConsumerWidget {
  const HtBotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = MaterialApp.router(
      title: 'HT BOT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      routerConfig: AppRouter.router,
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        // On web: wrap in a responsive container with max width
        if (kIsWeb) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: Scaffold(
              backgroundColor: const Color(0xFFE5E5E5),
              body: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use full width on mobile, max 430px on desktop
                    final containerWidth = constraints.maxWidth > 600 
                        ? 430.0 
                        : constraints.maxWidth;
                    
                    return Container(
                      width: containerWidth,
                      height: constraints.maxHeight,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        boxShadow: constraints.maxWidth > 600 ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: ClipRect(child: app),
                    );
                  },
                ),
              ),
            ),
          );
        }

        return app;
      },
    );
  }
}
