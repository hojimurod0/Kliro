import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/logger.dart';
import '../../constants/constants.dart';
import '../../navigation/app_router.dart';

/// Handler for Google OAuth callback deeplinks
class GoogleOAuthDeeplinkHandler {
  GoogleOAuthDeeplinkHandler._();
  static final GoogleOAuthDeeplinkHandler instance =
      GoogleOAuthDeeplinkHandler._();

  /// Handle Google OAuth callback URL
  /// Expected format: https://api.kliro.uz/auth/google/callback?code=...&state=...&session_id=...
  /// Yoki: https://api.kliro.uz/auth/google/callback?session_id=...
  Future<void> handleCallback(
    BuildContext context,
    Uri uri,
  ) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('🔗 Handling Google OAuth callback: $uri');
        AppLogger.debug('   Host: ${uri.host}');
        AppLogger.debug('   Path: ${uri.path}');
        AppLogger.debug('   Query: ${uri.queryParameters}');
      }

      // Extract query parameters
      final queryParams = uri.queryParameters;
      final sessionId = queryParams['session_id'] ??
          queryParams['sessionId'] ??
          queryParams['session'];
      final code = queryParams['code'];
      final error = queryParams['error'];

      // Handle error case
      if (error != null) {
        AppLogger.error(
          'Google OAuth error',
          error,
          StackTrace.current,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google OAuth xatosi: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Handle success case with sessionId
      if (sessionId != null && sessionId.isNotEmpty) {
        if (kDebugMode) {
          AppLogger.debug('✅ Session ID received: $sessionId');
        }

        if (context.mounted) {
          if (kDebugMode) {
            AppLogger.debug(
                '✅ Session ID qabul qilindi, ma\'lumotlar kiritish sahifasiga yo\'naltiramiz');
          }

          // Close GoogleOAuthWebViewPage if it's open (browser sahifasi)
          // Callback URL app'ga qaytayotgan bo'lsa, browser sahifasini yopish kerak
          try {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } catch (e) {
            if (kDebugMode) {
              AppLogger.debug(
                  '⚠️ Navigator pop xatosi (ehtimol sahifa ochilmagan): $e');
            }
          }

          // Ma'lumotlar kiritish sahifasiga yo'naltirish
          try {
            // AutoRoute extension ishlatish
            context.router.push(GoogleCompleteFormRoute(sessionId: sessionId));

            if (kDebugMode) {
              AppLogger.debug('✅ GoogleCompleteFormRoute ga yo\'naltirildi');
            }
          } catch (e) {
            AppLogger.error(
              'Failed to navigate to GoogleCompleteFormRoute',
              e.toString(),
              StackTrace.current,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigation xatolik: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          AppLogger.error(
            'Cannot navigate to Google Complete Form',
            'Context not mounted',
            StackTrace.current,
          );
        }
        return;
      }

      // Handle case with code (if backend needs code exchange)
      // ⚠️ MUAMMO: Backend callback endpoint'i 404 qaytarmoqda
      // Backend'da `/auth/google/callback` endpoint'i mavjud emas yoki to'g'ri sozlanmagan
      // Bu holda backend code ni session_id ga exchange qilishi kerak
      if (code != null && code.isNotEmpty) {
        if (kDebugMode) {
          AppLogger.debug('🔑 OAuth code received: $code');
          AppLogger.error(
            '❌ Backend callback endpoint 404 qaytarmoqda.\n'
            '   Backend /auth/google/callback endpoint\'i mavjud emas.\n'
            '   Backend developer quyidagi endpoint\'ni qo\'shishi kerak:\n'
            '   GET /auth/google/callback?code=...&state=...\n'
            '   Bu endpoint Google OAuth code ni session_id ga exchange qilishi va app\'ga redirect qilishi kerak.',
          );
        }

        // Foydalanuvchiga aniq dialog ko'rsatish
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('404 - Sahifa topilmadi'),
                ],
              ),
              content: const Text(
                'Backend callback endpoint topilmadi (404).\n\n'
                'Google OAuth code qaytarildi, lekin backend endpoint\'i mavjud emas.\n\n'
                'Backend developer quyidagi endpoint\'ni qo\'shishi kerak:\n'
                'GET /auth/google/callback\n\n'
                'Bu endpoint Google OAuth code ni session_id ga exchange qilishi va app\'ga redirect qilishi kerak.\n\n'
                'BACKEND_GOOGLE_OAUTH_ENDPOINT.md faylida batafsil qo\'llanma mavjud.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tushundim'),
                ),
              ],
            ),
          );
        }

        return;
      }

      // No valid parameters found
      // ⚠️ MUAMMO: Backend callback endpoint'i 404 qaytarmoqda
      // Bu holda callback URL'ga qaytganda parametrlar bo'lmasligi mumkin
      // Yoki backend 404 page qaytarmoqda
      if (kDebugMode) {
        AppLogger.error(
          '❌ Google OAuth callback xatolik:\n'
          '   URI: $uri\n'
          '   Query params: ${uri.queryParameters}\n'
          '   ⚠️ Backend callback endpoint 404 qaytarmoqda.\n'
          '   Backend /auth/google/callback endpoint\'i mavjud emas yoki to\'g\'ri sozlanmagan.',
        );
      }

      // Foydalanuvchiga aniq va tushunarli xabar beramiz
      if (context.mounted) {
        // Dialog ko'rsatish (SnackBar o'rniga)
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text('404 - Sahifa topilmadi'),
              ],
            ),
            content: const Text(
              'Backend callback endpoint topilmadi (404).\n\n'
              'Bu muammo backend developer tomonidan hal qilinishi kerak.\n\n'
              'Backend\'da quyidagi endpoint qo\'shilishi kerak:\n'
              'GET /auth/google/callback\n\n'
              'Bu endpoint Google OAuth code ni session_id ga exchange qilishi va app\'ga redirect qilishi kerak.\n\n'
              'BACKEND_GOOGLE_OAUTH_ENDPOINT.md faylida batafsil qo\'llanma mavjud.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tushundim'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling Google OAuth callback',
        e.toString(),
        stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Check if URI is a Google OAuth callback
  bool isGoogleOAuthCallback(Uri uri) {
    // Callback URL'ni constant'dan olish
    final callbackUrl = Uri.parse(ApiPaths.googleCallbackUrl);

    final isCallback =
        uri.host == callbackUrl.host && uri.path == callbackUrl.path;

    if (kDebugMode) {
      AppLogger.debug(
        '🔍 Checking if URI is Google OAuth callback:\n'
        '   URI: $uri\n'
        '   Host: ${uri.host}\n'
        '   Path: ${uri.path}\n'
        '   Expected host: ${callbackUrl.host}\n'
        '   Expected path: ${callbackUrl.path}\n'
        '   Is callback: $isCallback',
      );
    }

    return isCallback;
  }
}
