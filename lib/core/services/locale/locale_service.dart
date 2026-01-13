import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'locale_prefs.dart';

/// Service for managing app locale configuration
class LocaleService {
  LocaleService._();

  /// Supported locales in the app
  static const List<Locale> supportedLocales = [
    Locale('uz'),
    Locale('uz', 'CYR'),
    Locale('ru'),
    Locale('en'),
  ];

  /// Default locale (used as fallback)
  static const Locale defaultLocale = Locale('uz');

  /// Fallback locale for translations
  static const Locale fallbackLocale = Locale('en');

  /// Load saved locale or return default locale
  static Future<Locale> getStartLocale() async {
    try {
      final savedLocale = await LocalePrefs.load();
      if (savedLocale != null) {
        if (kDebugMode) {
          debugPrint(
            'LocaleService: Loaded saved locale: '
            '${savedLocale.languageCode}_${savedLocale.countryCode ?? 'null'}',
          );
        }
        return savedLocale;
      } else {
        if (kDebugMode) {
          debugPrint('LocaleService: No saved locale found, using default: uz');
        }
        return defaultLocale;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocaleService: Failed to load saved locale: $e, using default: uz');
      }
      return defaultLocale;
    }
  }
}
