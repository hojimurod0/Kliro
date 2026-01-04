import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppInputDecoration {
  const AppInputDecoration._();

  static InputDecoration outline({
    required String hint,
    IconData? prefixIcon,
    Widget? prefix,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    Color? fillColor,
    Color? borderColor,
    Color? hintColor,
    Color? prefixIconColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: hintColor ?? AppColors.grayText, fontSize: 13.sp),
      prefixIcon: prefix ??
          (prefixIcon != null
              ? Icon(prefixIcon,
                  color: prefixIconColor ?? AppColors.primaryBlue, size: 20.sp)
              : null),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: borderColor ?? AppColors.grayBorder.withOpacity(0.8),
          width: 1.w,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5.w),
      ),
      filled: true,
      fillColor: fillColor ?? AppColors.white,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
    );
  }
}
