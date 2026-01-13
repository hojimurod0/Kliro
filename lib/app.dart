import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/locale/locale_prefs.dart';
import 'core/services/theme/theme_controller.dart';
import 'core/services/deeplink/deeplink_service.dart';
import 'core/services/deeplink/google_oauth_deeplink_handler.dart';
import 'core/services/deeplink/hotel_payment_deeplink_handler.dart';
import 'core/dio/singletons/service_locator.dart';
import 'core/utils/logger.dart';
import 'core/widgets/top_snackbar_messenger.dart';
import 'features/kasko/presentation/providers/kasko_provider.dart';
import 'features/kasko/domain/repositories/kasko_repository.dart';
import 'features/register/presentation/bloc/register_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  static final AppRouter _appRouter = AppRouter();
  bool _localeLoaded = false;
  KaskoProvider? _kaskoProvider;
  ValueKey<String>? _materialAppKey;
  // Context stored for deeplink handling - always check mounted before use
  BuildContext? _appContext;

  @override
  void initState() {
    super.initState();
    // Platform brightness o'zgarishlarini kuzatish
    WidgetsBinding.instance.addObserver(this);
    // ServiceLocator allaqachon tayyor (runApp dan oldin init qilingan)
    // Locale ni asinxron yuklash
    _loadLocaleAsync();
    // KaskoProvider ni lazy yaratish
    _initKaskoProvider();
    // Deeplink service ni initialize qilish
    _initDeeplinkService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _kaskoProvider?.dispose();
    DeeplinkService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Platform brightness o'zgarganda, agar system mode tanlangan bo'lsa, UI ni yangilash
    if (ThemeController.instance.mode == ThemeMode.system && mounted) {
      setState(() {
        // UI ni yangilash - ThemeController.instance.mode system bo'lsa,
        // MaterialApp avtomatik platform brightness ga moslashadi
      });
    }
  }

  /// Deeplink service ni initialize qilish
  void _initDeeplinkService() {
    Future.microtask(() async {
      if (!mounted) return;

      // Deeplink handler ni set qilish
      DeeplinkService.instance.onLinkReceived = (Uri uri) {
        _handleDeeplink(uri);
      };

      // Deeplink service ni initialize qilish
      await DeeplinkService.instance.initialize();
    });
  }

  /// Deeplink'ni handle qilish
  void _handleDeeplink(Uri uri) {
    if (!mounted) return;

    try {
      if (kDebugMode) {
        AppLogger.debug('🔗 _handleDeeplink called with: $uri');
      }

      // App context topish
      final context = _appContext;
      if (context == null || !context.mounted) {
        if (kDebugMode) {
          AppLogger.warning('⚠️ Context not found, will retry...');
        }
        // Context topilmasa, keyinroq qayta urinish
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleDeeplink(uri);
          }
        });
        return;
      }

      // Google OAuth callback ekanligini tekshirish
      final oauthHandler = GoogleOAuthDeeplinkHandler.instance;
      if (oauthHandler.isGoogleOAuthCallback(uri)) {
        if (kDebugMode) {
          AppLogger.debug('✅ Google OAuth callback detected!');
        }
        oauthHandler.handleCallback(context, uri);
        return;
      }

      // Hotel Payment callback ekanligini tekshirish
      final hotelPaymentHandler = HotelPaymentDeeplinkHandler.instance;
      if (hotelPaymentHandler.isHotelPaymentCallback(uri)) {
        if (kDebugMode) {
          AppLogger.debug('✅ Hotel Payment callback detected!');
        }
        hotelPaymentHandler.handleCallback(context, uri);
        return;
      }

      // Boshqa deeplink'lar uchun
      if (kDebugMode) {
        AppLogger.debug('⚠️ URI is not a recognized callback: $uri');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling deeplink',
        e.toString(),
        stackTrace,
      );
    }
  }

  /// KaskoProvider ni lazy yaratish - faqat bir marta
  void _initKaskoProvider() {
    Future.microtask(() {
      if (!mounted) return;
      try {
        final repository = ServiceLocator.resolve<KaskoRepository>();
        _kaskoProvider = KaskoProvider(repository);
      } catch (e) {
        AppLogger.error('KaskoProvider init failed: $e');
      }
    });
  }

  /// MaterialApp key ni yangilash - faqat locale o'zgarganda
  ValueKey<String> _getMaterialAppKey(Locale locale) {
    final keyString = 'material_app_${locale.toString()}';
    if (_materialAppKey?.value != keyString) {
      _materialAppKey = ValueKey(keyString);
    }
    return _materialAppKey ?? ValueKey(keyString);
  }

  /// Locale ni asinxron yuklash - main thread'ni bloklamaslik uchun
  void _loadLocaleAsync() {
    // Locale ni keyinroq yuklash - UI render bo'lishini kutmaymiz
    Future.microtask(() async {
      if (!mounted || _localeLoaded) return;

      try {
        final locale = await LocalePrefs.load();
        if (locale != null && mounted && !_localeLoaded) {
          _localeLoaded = true;
          // setLocale ni keyinroq qilish - main thread'ni bloklamaslik uchun
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            try {
              await context.setLocale(locale);
              // EasyLocalization will trigger rebuild automatically
            } catch (e) {
              AppLogger.warning('Locale set failed: $e');
            }
          });
        }
      } catch (e) {
        AppLogger.warning('Locale load failed: $e');
      }
    });
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
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
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2),
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
        scaffoldBackgroundColor: AppColors.darkScaffoldBg,
        primaryColor: AppColors.primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.lightBlue,
          surface: AppColors.darkCardBg,
          background: AppColors.darkScaffoldBg,
          error: AppColors.dangerRed,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.white,
          onBackground: AppColors.white,
          onError: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkCardBg,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.darkCardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCardBg,
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
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2),
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

        // KaskoProvider ni lazy yaratish - faqat kerak bo'lganda
        final kaskoProvider = _kaskoProvider;

        return ChangeNotifierProvider<KaskoProvider?>.value(
          value: kaskoProvider,
          child: Builder(
            builder: (context) {
              // EasyLocalization automatically handles locale changes
              // No need for manual state management
              final localeToUse = context.locale;
              final appKey = _getMaterialAppKey(localeToUse);

              return AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) {
                  return TopSnackbarMessenger(
                    child: BlocProvider<RegisterBloc>(
                      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
                      child: Builder(
                        builder: (materialAppContext) {
                          // Store context for deeplink handling
                          // Note: Context is stored in builder callback where it's safe
                          // Always check context.mounted before using
                          _appContext = materialAppContext;

                          return MaterialApp.router(
                            key: appKey,
                            title: _getAppTitle(context),
                            debugShowCheckedModeBanner: false,
                            localizationsDelegates:
                                context.localizationDelegates,
                            supportedLocales: context.supportedLocales,
                            locale: localeToUse,
                            theme: _lightTheme,
                            darkTheme: _darkTheme,
                            themeMode: ThemeController.instance.mode,
                            routerConfig: _appRouter.config(),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(textScaleFactor: 1.0),
                                child: child ?? const SizedBox(),
                              );
                            },
                          );
                        },
                      ),
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
