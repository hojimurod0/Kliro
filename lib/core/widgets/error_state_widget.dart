import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final String? messageKey;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    this.message,
    this.messageKey,
    this.onRetry,
    this.icon = Icons.error_outline,
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
              color: isDark ? AppColors.dangerRed : AppColors.dangerRed,
            ),
            SizedBox(height: 16.h),
            Text(
              message ?? (messageKey != null ? tr(messageKey!) : 'error.unknown'.tr()),
              style: AppTypography.bodyPrimary.copyWith(
                fontSize: 16.sp,
                color: theme.textTheme.bodyLarge?.color ?? 
                    (isDark ? AppColors.white : AppColors.darkTextAutoCredit),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: Text(
                  'common.retry'.tr(),
                  style: AppTypography.buttonPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

