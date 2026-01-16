import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../utils/logger.dart';
import '../../constants/constants.dart';
import '../../navigation/app_router.dart';

/// Handler for Hotel Payment callback deeplinks
class HotelPaymentDeeplinkHandler {
  HotelPaymentDeeplinkHandler._();
  static final HotelPaymentDeeplinkHandler instance =
      HotelPaymentDeeplinkHandler._();

  /// Handle Hotel Payment callback URL
  /// Expected format: https://api.kliro.uz/payment/callback/success?booking_id=...&status=...
  /// Yoki: https://api.kliro.uz/hotel/payment/callback?booking_id=...&status=...
  Future<void> handleCallback(
    BuildContext context,
    Uri uri,
  ) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('🔗 Handling Hotel Payment callback: $uri');
        AppLogger.debug('   Host: ${uri.host}');
        AppLogger.debug('   Path: ${uri.path}');
        AppLogger.debug('   Query: ${uri.queryParameters}');
      }

      // Extract query parameters
      final queryParams = uri.queryParameters;
      final bookingId = queryParams['booking_id'] ??
          queryParams['bookingId'] ??
          queryParams['booking'];
      final status = queryParams['status'] ?? queryParams['payment_status'];
      final error = queryParams['error'];

      // Handle error case
      if (error != null) {
        AppLogger.error(
          'Hotel Payment error',
          error,
          StackTrace.current,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hotel to\'lov xatosi: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Handle success case with bookingId
      if (bookingId != null && bookingId.isNotEmpty) {
        if (kDebugMode) {
          AppLogger.debug('✅ Booking ID received: $bookingId');
          AppLogger.debug('   Payment status: $status');
        }

        if (context.mounted) {
          if (kDebugMode) {
            AppLogger.debug(
                '✅ Booking ID qabul qilindi, booking holatini yangilaymiz');
          }

          // User feedback
          if (status == 'success' || status == 'paid' || status == 'confirmed') {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('To\'lov muvaffaqiyatli amalga oshirildi'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }

          // Navigate to Home (clear stack) so user lands on main page after payment
          try {
            AutoRouter.of(context).replaceAll([HomeRoute()]);
          } catch (_) {
            // Fallback for contexts without AutoRoute scope
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else {
          AppLogger.error(
            'Cannot handle Hotel Payment callback',
            'Context not mounted',
            StackTrace.current,
          );
        }
        return;
      }

      // No valid parameters found
      if (kDebugMode) {
        AppLogger.warning(
          '⚠️ Hotel Payment callback xatolik:\n'
          '   URI: $uri\n'
          '   Query params: ${uri.queryParameters}\n'
          '   Booking ID topilmadi.',
        );
      }

      // Show user-friendly message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('To\'lov ma\'lumotlari topilmadi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error handling Hotel Payment callback',
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

  /// Check if URI is a Hotel Payment callback
  bool isHotelPaymentCallback(Uri uri) {
    // Check common hotel payment callback patterns
    final isPaymentCallback = uri.path.contains('/payment/callback') ||
        uri.path.contains('/hotel/payment/callback') ||
        uri.path.contains('/hotel/payment/success');

    // Also check host matches API base URL
    final baseUrl = Uri.parse(ApiConstants.effectiveBaseUrl);
    final isCorrectHost = uri.host == baseUrl.host;

    final isCallback = isPaymentCallback && isCorrectHost;

    if (kDebugMode) {
      AppLogger.debug(
        '🔍 Checking if URI is Hotel Payment callback:\n'
        '   URI: $uri\n'
        '   Host: ${uri.host}\n'
        '   Path: ${uri.path}\n'
        '   Expected host: ${baseUrl.host}\n'
        '   Is payment callback: $isPaymentCallback\n'
        '   Is correct host: $isCorrectHost\n'
        '   Is callback: $isCallback',
      );
    }

    return isCallback;
  }
}
