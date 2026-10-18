import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../theme/text_styles.dart';

/// A single row displaying a label–value pair for the Account screen.
///
/// Layout: label on the left (captionStyle), value on the right (bodyStyle),
/// separated by a [Spacer]. A thin [Divider] sits at the bottom.
///
/// Requirements: 10.4
class AccountTile extends StatelessWidget {
  final String label;
  final String value;

  const AccountTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.paddingSmall.h,
            horizontal: AppSizes.defaultPadding.w,
          ),
          child: Row(
            children: [
              Text(label, style: AppTextStyles.captionStyle),
              const Spacer(),
              Text(value, style: AppTextStyles.bodyStyle),
            ],
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
