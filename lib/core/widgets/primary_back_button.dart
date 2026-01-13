import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class PrimaryBackButton extends StatelessWidget {
  const PrimaryBackButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = AppColors.getBorderColor(isDark);
    final bgColor = AppColors.getCardBg(isDark);
    final iconColor = AppColors.getTextColor(isDark);

    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor),
          color: bgColor,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: iconColor,
          size: 22.sp,
        ),
      ),
    );
  }
}

