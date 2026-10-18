import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ht_bot/core/constants/app_colors.dart';

/// Named text style aliases and the base [TextTheme] for HT BOT.
///
/// [textTheme] is wired into [AppTheme.lightTheme] so every widget that reads
/// from `Theme.of(context).textTheme` inherits Inter automatically.
///
/// The named static getters provide pre-configured [TextStyle] constants that
/// can be referenced directly in any widget without going through the theme.
///
/// Requirements: 1.5, 12.4
abstract final class AppTextStyles {
  // ---------------------------------------------------------------------------
  // Base text theme
  // ---------------------------------------------------------------------------

  /// Returns an Inter-based [TextTheme] suitable for [ThemeData.textTheme].
  static TextTheme textTheme() => GoogleFonts.interTextTheme();

  // ---------------------------------------------------------------------------
  // Named style aliases
  // ---------------------------------------------------------------------------

  /// Hero / display headline — 32 sp, bold.
  static TextStyle get heroStyle => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      );

  /// Screen title — 22 sp, semi-bold.
  static TextStyle get titleStyle => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      );

  /// Card / section subtitle — 18 sp, medium.
  static TextStyle get subtitleStyle => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      );

  /// Section label / overline — 14 sp, semi-bold.
  static TextStyle get sectionStyle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      );

  /// General body text — 14 sp, regular.
  static TextStyle get bodyStyle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
      );

  /// Supporting caption / muted text — 12 sp, regular, secondary color.
  static TextStyle get captionStyle => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
      );
}
