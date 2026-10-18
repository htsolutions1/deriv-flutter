import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/enums/app_enums.dart';

/// A compact status indicator for the bot's operational state.
///
/// Renders a small coloured dot alongside a text label in a [Row]:
/// - `idle`    → gray dot    / "Idle"
/// - `running` → green dot   / "Running"
/// - `stopped` → orange dot  / "Stopped"
/// - `error`   → red dot     / "Error"
///
/// Requirements: 10.9
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final BotStatus status;

  Color get _dotColor => switch (status) {
        BotStatus.idle => AppColors.secondaryText,
        BotStatus.running => AppColors.success,
        BotStatus.stopped => AppColors.disconnected,
        BotStatus.error => AppColors.error,
      };

  String get _label => switch (status) {
        BotStatus.idle => 'Idle',
        BotStatus.running => 'Running',
        BotStatus.stopped => 'Stopped',
        BotStatus.error => 'Error',
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: _dotColor,
            shape: BoxShape.circle,
          ),
        ),
        Gap(6.w),
        Text(
          _label,
          style: TextStyle(
            color: _dotColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
