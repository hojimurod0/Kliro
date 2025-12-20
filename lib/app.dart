import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/locale/locale_prefs.dart';
import 'core/services/theme/theme_controller.dart';
import 'core/dio/singletons/service_locator.dart';
import 'core/dio/singletons/service_locator_state.dart';
import 'core/utils/logger.dart';
import 'core/widgets/top_snackbar_messenger.dart';
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
  Locale? _currentLocale;
  StreamSubscription<ServiceLocatorState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    // ServiceLocator state ni kuzatish
    _listenToServiceLocatorState();
    // Загружаем и применяем сохраненную локаль после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndApplyLocale();
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  /// ServiceLocator state ni kuzatish - polling o'rniga Stream ishlatish
  void _listenToServiceLocatorState() {
    _stateSubscription = ServiceLocatorStateController.instance.stateStream.listen(
      (state) {
        if (state == ServiceLocatorState.ready && !_isServiceLocatorReady) {
          _isServiceLocatorReady = true;
          if (mounted) {
            setState(() {});
          }
          AppLogger.success('ServiceLocator ready, app can proceed');
        } else if (state == ServiceLocatorState.error) {
          AppLogger.error('ServiceLocator initialization error');
          // Xatolikni ko'rsatish yoki fallback qilish
        }
      },
      onError: (error) {
        AppLogger.error('ServiceLocator state stream error', error);
      },
    );

    // Agar allaqachon ready bo'lsa
    if (ServiceLocatorStateController.instance.currentState ==
        ServiceLocatorState.ready) {
      _isServiceLocatorReady = true;
      if (mounted) {
        setState(() {});
      }
    } else {
      // Timeout - agar 10 soniyadan keyin ready bo'lmasa, xatolik ko'rsatish
      ServiceLocatorStateController.instance.initializationComplete
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning('ServiceLocator initialization timeout');
          if (mounted) {
            setState(() {
              _isServiceLocatorReady = true; // Fallback - app ishlashini davom ettirish
            });
          }
        },
      ).catchError((error) {
        AppLogger.error('ServiceLocator initialization error', error);
        if (mounted) {
          setState(() {
            _isServiceLocatorReady = true; // Fallback
          });
        }
      });
    }
  }

  Future<void> _loadAndApplyLocale() async {
    try {
      final locale = await LocalePrefs.load();
      if (locale != null && mounted) {
        try {
          // Локални текшириш - агар кирилл локали бўлса, тўғри форматда бўлишини текшириш
          final localeToSet = locale;
          AppLogger.debug('Loading locale: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}');
          
          // EasyLocalization файлни юклаш учун локални тўғри форматда бериш керак
          // useOnlyLangCode: false бўлганда, Locale('uz', 'CYR') учун 'uz-CYR.json' файлини ишлатади
          
          // Кирилл локали учун қўшимча вақт бериш
          if (localeToSet.languageCode == 'uz' && localeToSet.countryCode == 'CYR') {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          
          await context.setLocale(localeToSet);
          
          // Локалнинг тўғри ўрнатилганини текшириш
          final currentLocale = context.locale;
          AppLogger.success('Locale set successfully: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}');
          AppLogger.debug('Current locale after set: ${currentLocale.languageCode}_${currentLocale.countryCode ?? 'null'}');
          
          // Таржима файлини текшириш
          try {
            final testTranslation = tr('app_title');
            AppLogger.debug('Translation test: app_title = $testTranslation');
          } catch (e) {
            AppLogger.warning('Translation error', e);
            // Таржима хатоси бўлса ҳам, локал ўрнатилди
          }
          
          // Locale o'zgarishini kuzatish uchun state ni yangilash
          // Bu MaterialApp.router'ni qayta build qilish uchun zarur
          if (mounted) {
            setState(() {
              _currentLocale = currentLocale;
            });
            AppLogger.debug('App: State updated with locale: ${currentLocale.languageCode}_${currentLocale.countryCode ?? 'null'}');
            
            // Кирилл локали учун қўшимча қайта билдириш
            if (currentLocale.languageCode == 'uz' && currentLocale.countryCode == 'CYR') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    // Кирилл локали учун қўшимча қайта билдириш
                    _currentLocale = context.locale;
                  });
                  AppLogger.debug('App: Cyrillic locale forced rebuild: ${_currentLocale?.languageCode}_${_currentLocale?.countryCode ?? 'null'}');
                }
              });
            }
          }
        } catch (e) {
          // Agar locale o'rnatishda xatolik bo'lsa, fallback locale'ni ishlatamiz
          AppLogger.error('Error setting locale', e);
          if (mounted) {
            try {
              // Кирилл локали учун қайта уриниш
              if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
                await Future.delayed(const Duration(milliseconds: 200));
                await context.setLocale(locale);
                AppLogger.success('Cyrillic locale set after retry');
              } else {
                // Бошқа локаллар учун fallback
                await context.setLocale(const Locale('en'));
                AppLogger.info('Fallback to English locale');
              }
            } catch (fallbackError) {
              AppLogger.error('Fallback locale error', fallbackError);
              // Agar fallback ham ishlamasa, e'tiborsiz qoldiramiz
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error loading locale', e);
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
      surfaceTintColor: Colors.transparent,
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
      surfaceTintColor: Colors.transparent,
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
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
              final contextLocale = context.locale;
              
              // _currentLocale ни контекст локали билан синхронизация қилиш
              // Bu orqali MaterialApp har doim to'g'ri locale'ni ishlatadi
              if (_currentLocale == null ||
                  _currentLocale!.languageCode != contextLocale.languageCode ||
                  _currentLocale!.countryCode != contextLocale.countryCode) {
                _currentLocale = contextLocale;
                AppLogger.debug('App: Locale synced from context: ${contextLocale.languageCode}_${contextLocale.countryCode ?? 'null'}');
              }
              
              // Кирилл локали учун қўшимча текшириш
              final localeToUse = _currentLocale ?? contextLocale;
              AppLogger.debug('Current locale in MaterialApp: ${localeToUse.languageCode}_${localeToUse.countryCode ?? 'null'}');
              
              return AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) {
                  return TopSnackbarMessenger(
                    child: MaterialApp.router(
                      // Locale o'zgarganda MaterialApp qayta build bo'lishi uchun key qo'shamiz
                      // Кирилл локали учун қўшимча идентификатор
                      key: ValueKey('material_app_${localeToUse.toString()}'),
                      title: tr('app_title'),
                      debugShowCheckedModeBanner: false,
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: localeToUse,
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
                    ),
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
