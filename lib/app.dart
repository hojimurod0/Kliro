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
    // ✅ App'ni darhol ishga tushirish - qora ekran muammosini hal qilish uchun
    // ServiceLocator lazy loading bo'ladi - kerak bo'lganda resolve qilinadi
    _isServiceLocatorReady = true;
    
    // ServiceLocator state ni keyinroq kuzatish - main thread'ni bloklamaslik uchun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToServiceLocatorState();
      _loadAndApplyLocale();
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  /// ServiceLocator state ni yangilash - optimallashtirilgan setState
  void _updateServiceLocatorState(bool ready) {
    if (mounted && _isServiceLocatorReady != ready) {
      setState(() {
        _isServiceLocatorReady = ready;
      });
    }
  }

  /// ServiceLocator state ni kuzatish - polling o'rniga Stream ishlatish
  void _listenToServiceLocatorState() {
    _stateSubscription = ServiceLocatorStateController.instance.stateStream.listen(
      (state) {
        if (state == ServiceLocatorState.ready && !_isServiceLocatorReady) {
          _updateServiceLocatorState(true);
          AppLogger.success('ServiceLocator ready, app can proceed');
        } else if (state == ServiceLocatorState.error) {
          AppLogger.error('ServiceLocator initialization error');
          // Xatolik bo'lsa ham app ishlashini davom ettirish
          _updateServiceLocatorState(true);
        }
      },
      onError: (error) {
        AppLogger.error('ServiceLocator state stream error', error);
        // Xatolik bo'lsa ham app ishlashini davom ettirish
        _updateServiceLocatorState(true);
      },
    );

    // Agar allaqachon ready bo'lsa
    if (ServiceLocatorStateController.instance.currentState ==
        ServiceLocatorState.ready) {
      _updateServiceLocatorState(true);
    } else {
      // Timeout ni 2 soniyaga qisqartirish - tezroq ishga tushish uchun
      // Va darhol fallback qilish - app ishlashini davom ettirish
      ServiceLocatorStateController.instance.initializationComplete
          .timeout(
        const Duration(seconds: 2), // 3 dan 2 ga qisqartirildi
        onTimeout: () {
          AppLogger.warning('ServiceLocator initialization timeout - continuing anyway');
          _updateServiceLocatorState(true);
        },
      ).catchError((error) {
        AppLogger.error('ServiceLocator initialization error', error);
        _updateServiceLocatorState(true);
      });
      
      // Darhol fallback - 500ms dan keyin app ishga tushadi (tezroq)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isServiceLocatorReady) {
          _updateServiceLocatorState(true);
        }
      });
    }
  }

  Future<void> _loadAndApplyLocale() async {
    try {
      // Locale yuklashni keyinroq qilish - main thread'ni bloklamaslik uchun
      await Future.delayed(const Duration(milliseconds: 50));
      
      final locale = await LocalePrefs.load();
      if (locale != null && mounted) {
        try {
          final localeToSet = locale;
          
          // Кирилл локали учун қўшимча вақт бериш
          if (localeToSet.languageCode == 'uz' && localeToSet.countryCode == 'CYR') {
            await Future.delayed(const Duration(milliseconds: 50));
          }
          
          await context.setLocale(localeToSet);
          
          final currentLocale = context.locale;
          
          // setState'ni keyinroq qilish - main thread'ni bloklamaslik uchun
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentLocale = currentLocale;
                });
                
                // Кирилл локали учун қўшимча қайта билдириш
                if (currentLocale.languageCode == 'uz' && currentLocale.countryCode == 'CYR') {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      setState(() {
                        _currentLocale = context.locale;
                      });
                    }
                  });
                }
              }
            });
          }
        } catch (e) {
          // Agar locale o'rnatishda xatolik bo'lsa, fallback locale'ni ishlatamiz
          if (mounted) {
            try {
              // Кирилл локали учун қайта уриниш
              if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
                await Future.delayed(const Duration(milliseconds: 100));
                await context.setLocale(locale);
              } else {
                // Бошқа локаллар учун fallback
                await context.setLocale(const Locale('en'));
              }
            } catch (fallbackError) {
              // Agar fallback ham ishlamasa, e'tiborsiz qoldiramiz
            }
          }
        }
      }
    } catch (e) {
      // Xatolik bo'lsa ham app ishlashini davom ettirish
    }
  }

  /// Loading screen widget - to'g'ri theme va background color bilan
  /// Endi ishlatilmayapti, chunki app darhol ishga tushadi
  // ignore: unused_element
  Widget _buildLoadingScreen(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  /// Xavfsiz translation - fallback bilan
  String _getAppTitle(BuildContext context) {
    try {
      final title = context.tr('app_title');
      // Agar bo'sh string yoki key not found bo'lsa, fallback qaytarish
      if (title.isEmpty || title == 'app_title') {
        return 'Klero';
      }
      return title;
    } catch (e) {
      // Translation topilmasa, fallback qaytarish
      return 'Klero';
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
    cardTheme: const CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
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
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
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
        // ✅ App'ni darhol ishga tushirish - ServiceLocator lazy loading bo'ladi
        // ServiceLocator init qilinmaguncha loading ko'rsatish (faqat kerak bo'lsa)
        // if (!_isServiceLocatorReady) {
        //   return _buildLoadingScreen(context);
        // }

        return MultiProvider(
          providers: [
            // KASKO Provider - xavfsiz resolve
            ChangeNotifierProvider(
              create: (_) {
                // ✅ ServiceLocator lazy loading - kerak bo'lganda resolve qilish
                // Xatolik bo'lsa ham app ishlashini davom ettirish
                try {
                  // ServiceLocator tayyor bo'lsa resolve qilish
                  if (ServiceLocatorStateController.instance.currentState ==
                      ServiceLocatorState.ready) {
                    return KaskoProvider(ServiceLocator.resolve<KaskoRepository>());
                  } else {
                    // ServiceLocator tayyor bo'lmasa, yana bir bor urinib ko'rish
                    AppLogger.warning('ServiceLocator not ready, trying to resolve anyway');
                    try {
                      return KaskoProvider(ServiceLocator.resolve<KaskoRepository>());
                    } catch (e) {
                      AppLogger.error('ServiceLocator resolve failed: $e');
                      // Xatolik bo'lsa ham app ishlashini davom ettirish
                      // Fallback - null yoki default repository
                      // Bu yerda siz fallback repository yaratishingiz mumkin
                      rethrow;
                    }
                  }
                } catch (e) {
                  AppLogger.error('ServiceLocator resolve error: $e');
                  // Xatolik bo'lsa ham app ishlashini davom ettirish
                  // Fallback - yana bir bor urinib ko'rish
                  try {
                    return KaskoProvider(ServiceLocator.resolve<KaskoRepository>());
                  } catch (e2) {
                    AppLogger.error('ServiceLocator resolve retry failed: $e2');
                    // Oxirgi fallback - null yoki default repository
                    rethrow;
                  }
                }
              },
            ),
            // Boshqa providerlar shu yerga qo'shiladi
          ],
          child: Builder(
            builder: (context) {
              // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
              final contextLocale = context.locale;
              
              // _currentLocale ni faqat o'zgarganda yangilash
              if (_currentLocale == null ||
                  _currentLocale!.languageCode != contextLocale.languageCode ||
                  _currentLocale!.countryCode != contextLocale.countryCode) {
                // setState'ni keyinroq qilish - main thread'ni bloklamaslik uchun
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _currentLocale = contextLocale;
                    });
                  }
                });
              }
              
              final localeToUse = _currentLocale ?? contextLocale;
              
              return AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) {
                  return TopSnackbarMessenger(
                    child: MaterialApp.router(
                      key: ValueKey('material_app_${localeToUse.toString()}'),
                      title: _getAppTitle(context),
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
