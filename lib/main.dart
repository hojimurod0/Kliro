import 'package:flutter/material.dart';
import 'app.dart';
import 'core/dio/singletons/service_locator.dart';
import 'core/services/locale/root_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/services/locale/locale_prefs.dart';
import 'core/services/theme/theme_controller.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ServiceLocator.init();
  await RootService().init();
  await ThemeController.instance.init();
  final startLocale = await LocalePrefs.load() ?? const Locale('en');
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('uz'),
        Locale('uz', 'CYR'),
        Locale('ru'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      startLocale: startLocale,
      child: const App(),
    ),
  );
}
