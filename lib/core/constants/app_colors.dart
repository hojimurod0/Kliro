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
  static const Color greenBg = Color(0xFFE5F8F1);

  // Qo'shimcha pastel ranglar
  static const Color lilacSurface = Color(0xFFEEF2FF);
  static const Color lilacIcon = Color(0xFF6366F1);
  static const Color pinkSurface = Color(0xFFFDF2F8);
  static const Color pinkAccent = Color(0xFFEC4899);
  static const Color skySurface = Color(0xFFF0F9FF);
  static const Color skyAccent = Color(0xFF0EA5E9);
  static const Color charcoal = Color(0xFF111827);
  static const Color midnight = Color(0xFF1F2937);

  // Auto Credit colors
  static const Color darkText = Color(0xFF212529);
  static const Color mutedText = Color(0xFF6C757D);
  static const Color veryMutedText = Color(0xFFA0A0A0);
  static const Color cardBackground = Colors.white;
  static const Color metricBoxBackground = Color(0xFFF8F9FA);
  static const Color accentGreen = Color(0xFF28A745);
  static const Color accentPurple = Color(0xFF6F42C1);
  static const Color cardTagBackground = Colors.white;

  // Telefon uchun gradient
  static LinearGradient get phoneGradient => LinearGradient(
    colors: [lightBlue, primaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
