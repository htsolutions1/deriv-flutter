import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// Provides the application [ThemeData] built on top of [FlexColorScheme].
///
/// Only a light theme is defined; HT BOT does not support a dark mode.
///
/// Requirements: 1.2, 1.5, 12.4
abstract final class AppTheme {
  /// Builds and returns the light [ThemeData] for the application.
  ///
  /// - Color scheme anchored to [AppColors.accent] (gold) with
  ///   [AppColors.background] as the surface seed.
  /// - Subtle surface blending at level 7 keeps the background visually light.
  /// - Typography is wired to Inter via [GoogleFonts] and the named aliases
  ///   in [AppTextStyles].
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      colors: FlexSchemeColor.from(
        primary: AppColors.accent,
        secondary: AppColors.accent,
      ),
      scaffoldBackground: AppColors.background,
      surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
      blendLevel: 7,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: AppTextStyles.textTheme(),
    );
  }
}
