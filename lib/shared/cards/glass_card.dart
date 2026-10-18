import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../widgets/web_safe_blur.dart';

/// Foundation frosted-glass card used by all card variants.
///
/// Wraps [child] in a [ClipRRect] → [BackdropFilter] → [Container] stack that
/// produces the glassmorphism effect consistent with the HT BOT design system.
///
/// Requirements: 10.1
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppSizes.cardRadius,
    this.blurSigma = 10,
    this.opacity = 0.55,
    this.padding,
    this.width,
    this.height,
  });

  /// The widget to display inside the card.
  final Widget child;

  /// Corner radius in logical pixels (scaled via `.r` at build time).
  ///
  /// Defaults to [AppSizes.cardRadius] (16).
  final double borderRadius;

  /// Blur sigma applied to the backdrop in both X and Y directions.
  ///
  /// Defaults to `10`.
  final double blurSigma;

  /// Alpha opacity of the frosted surface overlay (0.0 – 1.0).
  ///
  /// Defaults to `0.55`.
  final double opacity;

  /// Inner padding. Defaults to `EdgeInsets.all(AppSizes.defaultPadding.w)`.
  final EdgeInsetsGeometry? padding;

  /// Optional fixed width for the card.
  final double? width;

  /// Optional fixed height for the card.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: WebSafeBlur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.all(AppSizes.defaultPadding.w),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
