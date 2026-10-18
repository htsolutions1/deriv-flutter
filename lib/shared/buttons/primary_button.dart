import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// A full-width gold-filled primary action button.
///
/// Wraps Flutter's [ElevatedButton] with the HT BOT accent color and
/// typography. Pass [width] to constrain to a specific size; omit it for
/// full-width behaviour.
///
/// Requirements: 10.3
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
  });

  /// Button label text.
  final String label;

  /// Tap callback. When `null` the button is rendered in a disabled state.
  final VoidCallback? onPressed;

  /// Explicit width. Defaults to [double.infinity] (full width).
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primaryText,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.primaryText.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusSmall.r),
          ),
          minimumSize: Size(double.infinity, AppSizes.buttonHeight.h),
        ),
        child: Text(label, style: AppTextStyles.sectionStyle),
      ),
    );
  }
}
