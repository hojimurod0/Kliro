import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primaryBlue,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: AppTypography.bodyMedium(context).copyWith(
                color: theme.textTheme.bodyMedium?.color ??
                    (isDark ? AppColors.white : AppColors.darkTextAutoCredit),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
