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
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        final app = MaterialApp.router(
          title: 'HT BOT',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          routerConfig: AppRouter.router,
        );

        // On web: wrap in a responsive container with max width
        if (kIsWeb) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFFD0D8E0),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: app,
                  ),
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
