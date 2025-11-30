import 'dart:ui';

import 'package:dio/dio.dart';

import '../../services/locale/locale_prefs.dart';

/// Interceptor для добавления заголовка Accept-Language в API запросы
/// Автоматически добавляет текущий выбранный язык в каждый запрос
/// Поддерживает 4 языка: uz, uz-CYR, ru, en
/// LocalePrefs синхронизирован с EasyLocalization, поэтому используем его
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor();

  /// Преобразует Locale в формат Accept-Language заголовка
  /// Например: Locale('uz', 'CYR') -> 'uz-CYR', Locale('ru') -> 'ru'
  /// Поддерживает 4 языка: uz, uz-CYR, ru, en
  String _localeToLanguageTag(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }
    return locale.languageCode;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Получаем сохраненную локаль из SharedPreferences
      // LocalePrefs синхронизирован с EasyLocalization, поэтому используем его
      final locale = await LocalePrefs.load();
      
      if (locale != null) {
        // Преобразуем локаль в формат Accept-Language
        // Поддерживаем 4 языка: uz, uz-CYR, ru, en
        final languageTag = _localeToLanguageTag(locale);
        options.headers['Accept-Language'] = languageTag;
      } else {
        // Если локаль не сохранена, используем дефолтную (en)
        options.headers['Accept-Language'] = 'en';
      }
    } catch (e) {
      // В случае ошибки используем дефолтный язык
      options.headers['Accept-Language'] = 'en';
    }
    
    handler.next(options);
  }
}

