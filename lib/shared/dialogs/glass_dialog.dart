import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ht_bot/core/constants/app_sizes.dart';
import 'package:ht_bot/shared/cards/glass_card.dart';
import 'package:ht_bot/theme/text_styles.dart';

/// A glassmorphic dialog used throughout HT BOT for confirmations, error
/// messages, and informational prompts.
///
/// Use [GlassDialog.show] to present the dialog imperatively, or instantiate
/// [GlassDialog] directly when embedding in a widget tree.
///
/// Requirements: 10.5
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  /// Dialog heading displayed in [AppTextStyles.titleStyle].
  final String title;

  /// Main body widget rendered below the divider.
  final Widget content;

  /// Optional action buttons displayed in a right-aligned [Row] at the bottom.
  ///
  /// When `null` or empty no action row is rendered.
  final List<Widget>? actions;

  // ---------------------------------------------------------------------------
  // Static helper
  // ---------------------------------------------------------------------------

  /// Presents a [GlassDialog] using [showDialog].
  ///
  /// The barrier is semi-transparent black (`Colors.black26`) and dismissible
  /// by tapping outside the dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (_) => GlassDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasActions = actions != null && actions!.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: EdgeInsets.all(AppSizes.defaultPadding.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(title, style: AppTextStyles.titleStyle),
            Gap(8.h),
            const Divider(),
            // Body content
            content,
            // Actions row
            if (hasActions) ...[
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
