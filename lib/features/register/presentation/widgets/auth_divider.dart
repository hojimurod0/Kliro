import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.gray500 : AppColors.grayBorder.withOpacity(0.5);
    
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 0.5.h,
            height: 1.h,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            text,
            style: AppTypography.divider.copyWith(
              color: isDark ? AppColors.grayText : AppColors.grayText,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 0.5.h,
            height: 1.h,
          ),
        ),
      ],
    );
  }
}

