import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../theme/text_styles.dart';

/// A versatile settings row that supports three modes:
///
/// - **Switch mode** (`isSwitch: true`): label on the left, [CupertinoSwitch] on the right.
/// - **Sensitive mode** (`isSensitive: true`): text mode but the value is obscured
///   with bullets by default; an eye icon toggles visibility.
/// - **Text mode** (default): label on the left, value + chevron on the right, tappable.
///
/// Requirements: 10.4, 7.6
class SettingsTile extends StatefulWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool isSensitive;
  final bool switchValue;
  final ValueChanged<bool>? onChanged;

  const SettingsTile({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.isSwitch = false,
    this.isSensitive = false,
    this.switchValue = false,
    this.onChanged,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  bool _revealed = false;

  String get _displayValue {
    if (widget.value == null) return '--';
    if (widget.isSensitive && !_revealed) {
      return '•' * widget.value!.length.clamp(6, 12);
    }
    return widget.value!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: widget.isSwitch ? null : widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusSmall.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.paddingSmall.h,
              horizontal: AppSizes.defaultPadding.w,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.label, style: AppTextStyles.bodyStyle),
                ),
                if (widget.isSwitch) ...[
                  CupertinoSwitch(
                    value: widget.switchValue,
                    activeTrackColor: AppColors.accent,
                    onChanged: widget.onChanged,
                  ),
                ] else ...[
                  if (widget.value != null) ...[
                    Flexible(
                      child: Text(
                        _displayValue,
                        style: AppTextStyles.captionStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Gap(4.w),
                  ],
                  if (widget.isSensitive) ...[
                    IconButton(
                      icon: Icon(
                        _revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: AppSizes.iconSmall,
                        color: AppColors.secondaryText,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: AppSizes.iconMedium.w,
                        minHeight: AppSizes.iconMedium.h,
                      ),
                      onPressed: () => setState(() => _revealed = !_revealed),
                    ),
                  ] else ...[
                    Icon(
                      Icons.chevron_right,
                      size: AppSizes.iconMedium,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.border,
          indent: AppSizes.defaultPadding.w,
          endIndent: AppSizes.defaultPadding.w,
        ),
      ],
    );
  }
}
