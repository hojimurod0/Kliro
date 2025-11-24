import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextStyle get headingXL => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static TextStyle get headingL => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static TextStyle get bodyPrimary =>
      TextStyle(fontSize: 13.sp, color: AppColors.grayText, height: 1.4);

  static TextStyle get bodySecondary =>
      TextStyle(fontSize: 12.sp, color: AppColors.gray500);

  static TextStyle get labelSmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.gray500,
  );

  static TextStyle get chip =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600);

  static TextStyle get buttonPrimary => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get buttonLink => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
    decoration: TextDecoration.underline,
  );

  static TextStyle get divider =>
      TextStyle(fontSize: 12.sp, color: AppColors.grayText);

  static TextStyle get googleButton => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static TextStyle get caption =>
      TextStyle(fontSize: 11.sp, color: AppColors.gray500);
}
