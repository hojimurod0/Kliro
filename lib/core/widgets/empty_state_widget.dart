import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? message;
  final String? messageKey;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.messageKey,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: theme.iconTheme.color ?? 
                  (isDark ? AppColors.gray500 : AppColors.grayText),
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? (messageKey != null ? tr(messageKey!) : 'common.empty'.tr()),
              style: AppTypography.bodyPrimary(context).copyWith(
                fontSize: 16.sp,
                color: theme.textTheme.bodyMedium?.color ?? 
                    (isDark ? AppColors.gray500 : AppColors.grayText),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

