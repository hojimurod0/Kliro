import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePrefs {
  static const _key = 'selected_locale';

  static Future<void> save(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    // Регистрни текшириш - countryCode'ни катта ҳарфга ўзгартириш
    final countryCode = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? locale.countryCode!.toUpperCase()
        : null;
    final code = countryCode == null
        ? locale.languageCode.toLowerCase()
        : '${locale.languageCode.toLowerCase()}_$countryCode';
    await prefs.setString(_key, code);
    debugPrint('LocalePrefs.save: Locale(${locale.languageCode}, ${locale.countryCode ?? 'null'}) -> saved as: $code');
  }

  static Future<Locale?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == null || code.isEmpty) {
      debugPrint('LocalePrefs.load: No saved locale found');
      return null;
    }
    debugPrint('LocalePrefs.load: Loading locale from preferences: $code');
    
    if (code.contains('_')) {
      final parts = code.split('_');
      if (parts.length != 2) {
        debugPrint('LocalePrefs.load: Invalid locale format: $code');
        return null;
      }
      
      // Эски uz_UZ локалини uz_CYR локалига ўзгартириш
      if (parts[0].toLowerCase() == 'uz' && parts[1].toUpperCase() == 'UZ') {
        // uz_UZ локалини uz_CYR локалига ўзгартириш ва сақлаш
        final correctedLocale = Locale(parts[0], 'CYR');
        await save(correctedLocale);
        debugPrint('LocalePrefs.load: Corrected uz_UZ to uz_CYR');
        return correctedLocale;
      }
      
      // Регистрни текшириш - countryCode'ни катта ҳарфга ўзгартириш
      final languageCode = parts[0].toLowerCase();
      final countryCode = parts[1].toUpperCase();
      final loadedLocale = Locale(languageCode, countryCode);
      debugPrint('LocalePrefs.load: Loaded locale: Locale($languageCode, $countryCode)');
      return loadedLocale;
    }
    
    // Фақат language code бўлса
    final languageCode = code.toLowerCase();
    final loadedLocale = Locale(languageCode);
    debugPrint('LocalePrefs.load: Loaded locale (no country): Locale($languageCode)');
    return loadedLocale;
  }
}
