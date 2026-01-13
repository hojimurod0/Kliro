import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../../utils/logger.dart';

/// Deeplink service for handling app links (Universal Links on iOS, App Links on Android)
class DeeplinkService {
  DeeplinkService._();
  static final DeeplinkService instance = DeeplinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<Uri>? _initialLinkSubscription;

  /// Callback function that will be called when a deeplink is received
  Function(Uri uri)? onLinkReceived;

  /// Initialize deeplink service and start listening for links
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        AppLogger.debug('🔗 Initializing deeplink service...');
      }
      
      // Handle initial link (when app is opened from a link)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        if (kDebugMode) {
          AppLogger.debug('🔗 Initial deeplink received: $initialLink');
          AppLogger.debug('   Host: ${initialLink.host}');
          AppLogger.debug('   Path: ${initialLink.path}');
          AppLogger.debug('   Query: ${initialLink.queryParameters}');
        }
        onLinkReceived?.call(initialLink);
      } else {
        if (kDebugMode) {
          AppLogger.debug('🔗 No initial deeplink found');
        }
      }

      // Listen for incoming links (when app is already running)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          if (kDebugMode) {
            AppLogger.debug('🔗 Deeplink received (stream): $uri');
            AppLogger.debug('   Host: ${uri.host}');
            AppLogger.debug('   Path: ${uri.path}');
            AppLogger.debug('   Query: ${uri.queryParameters}');
          }
          onLinkReceived?.call(uri);
        },
        onError: (Object err) {
          AppLogger.error(
            'Deeplink stream error',
            err.toString(),
            StackTrace.current,
          );
        },
        cancelOnError: false, // Stream'ni xatolikdan keyin ham davom ettirish
      );

      if (kDebugMode) {
        AppLogger.debug('✅ Deeplink service initialized and listening');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize deeplink service',
        e.toString(),
        stackTrace,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _initialLinkSubscription?.cancel();
    if (kDebugMode) {
      AppLogger.debug('🔄 Deeplink service disposed');
    }
  }
}

