import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ht_bot/core/constants/app_colors.dart';
import 'package:ht_bot/core/constants/app_strings.dart';
import 'package:ht_bot/core/enums/app_enums.dart';

/// A pill-shaped badge indicating the current [ConnectionStatus].
///
/// The background color and label text change with the supplied [status]:
/// - `connected`    → green  / "Live"
/// - `connecting`   → gold   / "Connecting"
/// - `disconnected` → orange / "Offline"
/// - `error`        → red    / "Error"
///
/// Requirements: 3.10, 10.8
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status});

  final ConnectionStatus status;

  Color get _color => switch (status) {
        ConnectionStatus.connected => AppColors.success,
        ConnectionStatus.connecting => AppColors.accent,
        ConnectionStatus.disconnected => AppColors.disconnected,
        ConnectionStatus.error => AppColors.error,
      };

  String get _label => switch (status) {
        ConnectionStatus.connected => AppStrings.badgeLive,
        ConnectionStatus.connecting => AppStrings.badgeConnecting,
        ConnectionStatus.disconnected => AppStrings.badgeOffline,
        ConnectionStatus.error => AppStrings.badgeError,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
