import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../services/locale/locale_service.dart';

/// App locale configuration for EasyLocalization
class AppLocaleConfig {
  AppLocaleConfig._();

  /// Create EasyLocalization widget with configured settings
  static Widget createLocalizedApp({
    required Widget child,
    Locale? startLocale,
  }) {
    return EasyLocalization(
      supportedLocales: LocaleService.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: LocaleService.fallbackLocale,
      saveLocale: true,
      startLocale: startLocale ?? LocaleService.defaultLocale,
      useOnlyLangCode: false,
      useFallbackTranslations: true,
      child: child,
    );
  }
}
