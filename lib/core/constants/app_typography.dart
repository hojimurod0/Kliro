import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  // Base styles without color (for theme-aware usage)
  static TextStyle _baseHeadingXL() => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle _baseHeadingL() => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle _baseHeadingM() => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle _baseHeadingS() => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle _baseTitleLarge() => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle _baseBodyLarge() => TextStyle(
        fontSize: 16.sp,
      );

  static TextStyle _baseBodyMedium() => TextStyle(
        fontSize: 14.sp,
      );

  static TextStyle _baseBodyPrimary() => TextStyle(
        fontSize: 13.sp,
        height: 1.4,
      );

  static TextStyle _baseBodySecondary() => TextStyle(
        fontSize: 12.sp,
      );

  static TextStyle _baseLabelSmall() => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle _baseChip() => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle _baseButtonPrimary() => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle _baseButtonLink() => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      );

  static TextStyle _baseDivider() => TextStyle(
        fontSize: 12.sp,
      );

  static TextStyle _baseGoogleButton() => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle _baseCaption() => TextStyle(
        fontSize: 11.sp,
      );

  static TextStyle _baseSubtitle() => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle _basePriceLarge() => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle _baseButtonLarge() => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );

  // Theme-aware methods (recommended - always use these)
  static TextStyle headingXL(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseHeadingXL().copyWith(
      color: theme.textTheme.headlineLarge?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle headingL(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseHeadingL().copyWith(
      color: theme.textTheme.headlineMedium?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle headingM(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseHeadingM().copyWith(
      color: theme.textTheme.headlineSmall?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle headingS(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseHeadingS().copyWith(
      color: theme.textTheme.titleLarge?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseTitleLarge().copyWith(
      color: theme.textTheme.titleLarge?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    final theme = Theme.of(context);
    return _baseBodyLarge().copyWith(
      color: theme.textTheme.bodyLarge?.color ?? AppColors.bodyText,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    final theme = Theme.of(context);
    return _baseBodyMedium().copyWith(
      color: theme.textTheme.bodyMedium?.color ?? AppColors.bodyText,
    );
  }

  static TextStyle bodyPrimary(BuildContext context) {
    final theme = Theme.of(context);
    return _baseBodyPrimary().copyWith(
      color: theme.textTheme.bodyMedium?.color ?? AppColors.grayText,
    );
  }

  static TextStyle bodySecondary(BuildContext context) {
    final theme = Theme.of(context);
    return _baseBodySecondary().copyWith(
      color: theme.textTheme.bodySmall?.color ?? AppColors.gray500,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    final theme = Theme.of(context);
    return _baseLabelSmall().copyWith(
      color: theme.textTheme.labelSmall?.color ?? AppColors.gray500,
    );
  }

  static TextStyle chip(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseChip().copyWith(
      color: theme.textTheme.bodyMedium?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle buttonPrimary(BuildContext context) {
    return _baseButtonPrimary().copyWith(
      color: AppColors.white, // Button text is always white
    );
  }

  static TextStyle buttonLink(BuildContext context) {
    return _baseButtonLink().copyWith(
      color: AppColors.primaryBlue, // Link color is always primary blue
    );
  }

  static TextStyle divider(BuildContext context) {
    final theme = Theme.of(context);
    return _baseDivider().copyWith(
      color: theme.textTheme.bodySmall?.color ?? AppColors.grayText,
    );
  }

  static TextStyle googleButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _baseGoogleButton().copyWith(
      color: theme.textTheme.bodyLarge?.color ??
          (isDark ? AppColors.white : AppColors.black),
    );
  }

  static TextStyle caption(BuildContext context) {
    final theme = Theme.of(context);
    return _baseCaption().copyWith(
      color: theme.textTheme.bodySmall?.color ?? AppColors.gray500,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    final theme = Theme.of(context);
    return _baseSubtitle().copyWith(
      color: theme.textTheme.bodyMedium?.color ?? AppColors.labelText,
    );
  }

  static TextStyle priceLarge(BuildContext context) {
    return _basePriceLarge().copyWith(
      color: AppColors.orangeWarning, // Price color is always orange
    );
  }

  static TextStyle buttonLarge(BuildContext context) {
    return _baseButtonLarge().copyWith(
      color: AppColors.white, // Button text is always white
    );
  }
}
