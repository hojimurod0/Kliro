import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Asosiy ranglar
  static const Color primaryBlue = Color(0xFF0095EB); // To'q ko'k
  static const Color lightBlue = Color(0xFF049FEF); // Och ko'k
  static const Color secondaryBlue = Color(0xFFE5F2FF); // Yengil ko'k fon
  static const Color accentCyan = Color(0xFF00CFFF);
  static const Color white = Color(0xFFFFFFFF); // Oq
  static const Color black = Color(0xFF000000); // Qora
  static const Color dangerRed = Color(0xFFE53935);
  static const Color orangeWarning = Color(0xFFFF9800); // Warning orange

  // Qo'shimcha ranglar
  static const Color grayText = Color(0xFF9CA3AF);
  static const Color grayLight = Color(0xFFF3F4F6);
  static const Color grayBackground = Color(0xFFF9FAFB);
  static const Color grayBorder = Color(0xFFE5E7EB);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color background = Color(0xFFF4F6FB);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color inputBorder = Color(0xFFF0F0F0);
  static const Color border = Color(0xFFD1D1D6);
  static const Color labelText = Color(0xFF8E8E93);
  static const Color bodyText = Color(0xFF4A4A4A);
  static const Color linkText = Color(0xFF000000);
  static const Color iconMuted = Color(0xFF8E8E93);

  // Maxsus ikonka ranglari
  static const Color purpleIcon = Color(0xFF7B61FF);
  static const Color purpleBg = Color(0xFFF2ECFF);
  static const Color pinkIcon = Color(0xFFFF4D8D);
  static const Color pinkBg = Color(0xFFFFEEF4);
  static const Color greenIcon = Color(0xFF1ABC9C);
  static Color greenBg = Color(0xFF1ABC9C).withValues(alpha: 0.15);

  // Qo'shimcha pastel ranglar
  static Color lilacSurface = Color(0xFF6366F1).withValues(alpha: 0.15);
  static const Color lilacIcon = Color(0xFF6366F1);
  static Color pinkSurface = Color(0xFFEC4899).withValues(alpha: 0.15);
  static const Color pinkAccent = Color(0xFFEC4899);
  static Color skySurface = Color(0xFF0EA5E9).withValues(alpha: 0.15);
  static const Color skyAccent = Color(0xFF0EA5E9);
  static const Color charcoal = Color(0xFF111827);
  static const Color midnight = Color(0xFF1F2937);

  // Auto Credit colors
  static const Color darkTextAutoCredit = Color(0xFF212529);
  static const Color mutedText = Color(0xFF6C757D);
  static const Color veryMutedText = Color(0xFFA0A0A0);
  // Theme-aware colors - use getCardBg(isDark) instead
  static Color getCardBackground(bool isDark) => isDark ? darkCardBg : lightCardBg;
  static const Color metricBoxBackground = Color(0xFFF8F9FA);
  static const Color accentGreen = Color(0xFF28A745);
  static const Color accentPurple = Color(0xFF6F42C1);
  // Theme-aware colors - use getCardBg(isDark) instead
  static Color getCardTagBackground(bool isDark) => isDark ? darkCardBg : lightCardBg;

  // Telefon uchun gradient
  static LinearGradient get phoneGradient => LinearGradient(
    colors: [lightBlue, primaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // KASKO colors
  static const Color kaskoPrimaryBlue = Color(0xFF1976D2);

  // Dark theme colors
  static const Color darkScaffoldBg = Color(0xFF121212);
  static const Color darkCardBg = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSubtitle = Color(0xFFB3B3B3);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkPlaceholder = Color(0xFF757575);

  // Light theme colors
  static const Color lightScaffoldBg = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightTextColor = Color(0xFF212121);
  static const Color lightSubtitle = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightPlaceholder = Color(0xFF9E9E9E);

  // Helper methods for theme-aware colors
  static Color getScaffoldBg(bool isDark) =>
      isDark ? darkScaffoldBg : lightScaffoldBg;
  static Color getCardBg(bool isDark) => isDark ? darkCardBg : lightCardBg;
  static Color getTextColor(bool isDark) =>
      isDark ? darkTextColor : lightTextColor;
  static Color getSubtitleColor(bool isDark) =>
      isDark ? darkSubtitle : lightSubtitle;
  static Color getBorderColor(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getPlaceholderColor(bool isDark) =>
      isDark ? darkPlaceholder : lightPlaceholder;
}
