import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/shared/widgets/web_safe_blur.dart';

/// A glassmorphic modal bottom sheet used throughout HT BOT.
///
/// Use [GlassBottomSheet.show] to present the sheet imperatively, or
/// instantiate [GlassBottomSheet] directly when embedding in a widget tree.
///
/// Requirements: 10.5
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
  });

  /// Content rendered below the drag handle.
  final Widget child;

  // ---------------------------------------------------------------------------
  // Static helper
  // ---------------------------------------------------------------------------

  /// Presents a [GlassBottomSheet] using [showModalBottomSheet].
  ///
  /// The background is transparent, the sheet is scroll-controlled, and the
  /// barrier uses `Colors.black26`.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black26,
      builder: (_) => GlassBottomSheet(child: child),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebSafeBlur(
        sigmaX: 10,
        sigmaY: 10,
        child: Container(
          padding: EdgeInsets.all(AppSizes.defaultPadding.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryText,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(8.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
