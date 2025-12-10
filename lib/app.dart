import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/locale/locale_prefs.dart';
import 'core/services/theme/theme_controller.dart';
import 'core/dio/singletons/service_locator.dart';
import 'features/kasko/presentation/providers/kasko_provider.dart';
import 'features/kasko/domain/repositories/kasko_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static final AppRouter _appRouter = AppRouter();
  bool _isServiceLocatorReady = false;

  @override
  void initState() {
    super.initState();
    // ServiceLocator init qilinishini kutish
    _waitForServiceLocator();
    // Загружаем и применяем сохраненную локаль после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndApplyLocale();
    });
  }

  Future<void> _waitForServiceLocator() async {
    // ServiceLocator init qilinmaguncha kutish
    while (!_isServiceLocatorReady) {
      try {
        // KaskoRepository mavjudligini tekshirish
        ServiceLocator.resolve<KaskoRepository>();
        _isServiceLocatorReady = true;
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        // Hali init qilinmagan, kichik kechikish bilan qayta urinish
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<void> _loadAndApplyLocale() async {
    try {
      final locale = await LocalePrefs.load();
      if (locale != null && mounted) {
        await context.setLocale(locale);
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  static ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryBlue,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.lightBlue,
      surface: AppColors.white,
      background: AppColors.background,
      error: AppColors.dangerRed,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.black,
      onBackground: AppColors.black,
      onError: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.black),
      displayMedium: TextStyle(color: AppColors.black),
      displaySmall: TextStyle(color: AppColors.black),
      headlineLarge: TextStyle(color: AppColors.black),
      headlineMedium: TextStyle(color: AppColors.black),
      headlineSmall: TextStyle(color: AppColors.black),
      titleLarge: TextStyle(color: AppColors.black),
      titleMedium: TextStyle(color: AppColors.black),
      titleSmall: TextStyle(color: AppColors.black),
      bodyLarge: TextStyle(color: AppColors.bodyText),
      bodyMedium: TextStyle(color: AppColors.bodyText),
      bodySmall: TextStyle(color: AppColors.labelText),
      labelLarge: TextStyle(color: AppColors.labelText),
      labelMedium: TextStyle(color: AppColors.labelText),
      labelSmall: TextStyle(color: AppColors.labelText),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconMuted),
    dividerColor: AppColors.divider,
  );

  static ThemeData get _darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: AppColors.primaryBlue,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.lightBlue,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: AppColors.dangerRed,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onBackground: AppColors.white,
      onError: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(color: AppColors.white),
      displayMedium: const TextStyle(color: AppColors.white),
      displaySmall: const TextStyle(color: AppColors.white),
      headlineLarge: const TextStyle(color: AppColors.white),
      headlineMedium: const TextStyle(color: AppColors.white),
      headlineSmall: const TextStyle(color: AppColors.white),
      titleLarge: const TextStyle(color: AppColors.white),
      titleMedium: const TextStyle(color: AppColors.white),
      titleSmall: const TextStyle(color: AppColors.white),
      bodyLarge: const TextStyle(color: AppColors.white),
      bodyMedium: const TextStyle(color: AppColors.white),
      bodySmall: TextStyle(color: AppColors.grayText.withOpacity(0.8)),
      labelLarge: const TextStyle(color: AppColors.grayText),
      labelMedium: const TextStyle(color: AppColors.grayText),
      labelSmall: const TextStyle(color: AppColors.grayText),
    ),
    iconTheme: const IconThemeData(color: AppColors.white),
    dividerColor: AppColors.gray500,
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // ServiceLocator init qilinmaguncha loading ko'rsatish
        if (!_isServiceLocatorReady) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MultiProvider(
          providers: [
            // KASKO Provider
            ChangeNotifierProvider(
              create: (_) =>
                  KaskoProvider(ServiceLocator.resolve<KaskoRepository>()),
            ),
            // Boshqa providerlar shu yerga qo'shiladi
          ],
          child: Builder(
            builder: (context) {
              // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
              // EasyLocalization o'z-o'zidan rebuild bo'ladi, shuning uchun context.locale o'zgarganda bu builder ham rebuild bo'ladi
              final currentLocale = context.locale;
              return AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) {
                  return MaterialApp.router(
                    // Key olib tashlandi - theme o'zgarganda navigation state saqlanadi
                    title: tr('app_title'),
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: currentLocale,
                    theme: _lightTheme,
                    darkTheme: _darkTheme,
                    themeMode: ThemeController.instance.mode,
                    routerConfig: _appRouter.config(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaleFactor: 1.0),
                        child: child ?? const SizedBox(),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
