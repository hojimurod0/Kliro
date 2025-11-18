import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePrefs {
  static const _key = 'selected_locale';

  static Future<void> save(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final code = locale.countryCode == null || locale.countryCode!.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    await prefs.setString(_key, code);
  }

  static Future<Locale?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == null || code.isEmpty) return null;
    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }
}
