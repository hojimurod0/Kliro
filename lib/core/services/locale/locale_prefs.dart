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
    var code = prefs.getString(_key);
    if (code == null || code.isEmpty) {
      debugPrint('LocalePrefs.load: No saved locale found');
      return null;
    }

    // Normalize possible formats: "uz-UZ" -> "uz_UZ"
    code = code.replaceAll('-', '_');
    debugPrint('LocalePrefs.load: Loading locale from preferences: $code');
    
    if (code.contains('_')) {
      final parts = code.split('_');
      if (parts.length != 2) {
        debugPrint('LocalePrefs.load: Invalid locale format: $code');
        return null;
      }
      
      // If an old Uzbek locale was saved as uz_UZ, treat it as Uzbek (Latin).
      // (We do NOT force Cyrillic; Cyrillic is explicitly uz_CYR in this app.)
      if (parts[0].toLowerCase() == 'uz' && parts[1].toUpperCase() == 'UZ') {
        final correctedLocale = const Locale('uz');
        await save(correctedLocale);
        debugPrint('LocalePrefs.load: Corrected uz_UZ to uz');
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
