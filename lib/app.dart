import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/services/theme/theme_controller.dart';
import 'features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: tr('app_title'),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeController.instance.mode,
          home: const SplashPage(),
        );
      },
    );
  }
}
