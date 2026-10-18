import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// A full-width outlined secondary action button.
///
/// Wraps Flutter's [OutlinedButton] with a gold accent border and transparent
/// background. Use for secondary or destructive actions alongside
/// [PrimaryButton]. Pass [width] to constrain; omit for full-width behaviour.
///
/// Requirements: 10.3
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.accent.withValues(alpha: 0.5),
          side: BorderSide(color: AppColors.accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusSmall.r),
          ),
          minimumSize: Size(double.infinity, AppSizes.buttonHeight.h),
        ),
        child: Text(
          label,
          style: AppTextStyles.sectionStyle.copyWith(color: AppColors.accent),
        ),
      ),
    );
  }
}
