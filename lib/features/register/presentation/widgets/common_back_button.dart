import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class CommonBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CommonBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 44.h,
      width: 44.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.grayBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            spreadRadius: 1.r,
            blurRadius: 5.r,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.white : AppColors.black,
          size: 20.sp,
        ),
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}

