import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

import '../../utils/logger.dart';

/// Web OAuth client ID (Play Console / Firebase'dan olingan).
/// Build vaqtida --dart-define=GOOGLE_WEB_CLIENT_ID=... bilan uzating.
const String _googleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '',
);

class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignInService instance = GoogleSignInService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Server client ID - Web OAuth Client ID (backend server auth uchun).
    serverClientId: _googleWebClientId.isNotEmpty ? _googleWebClientId : null,
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null && _googleWebClientId.isEmpty) {
        AppLogger.warning(
          'Google sign-in cancelled or failed. '
          'GOOGLE_WEB_CLIENT_ID dart-define berilganini tekshiring.',
        );
      }
      return account;
    } on PlatformException catch (e, st) {
      String errorMessage = 'Google sign-in failed';
      if (e.code == 'sign_in_failed') {
        if (e.message?.contains('10') == true) {
          errorMessage = 'Google sign-in xatosi (Code 10). '
              'SHA-1 fingerprint Firebase Consolda yo\'q yoki google-services.json noto\'g\'ri. '
              'Yechim: android/README_GOOGLE_AUTH.md faylini o\'qing va ko\'rsatmalarni bajaring.';
        } else {
          errorMessage = 'Google sign-in xatolik: ${e.message ?? e.code}';
        }
      }
      AppLogger.error(
        errorMessage,
        e.message ?? e.toString(),
        st,
      );
      return null;
    } catch (e, st) {
      AppLogger.error('Google sign-in failed', e, st);
      return null;
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account;
    } on PlatformException catch (e, st) {
      AppLogger.error(
        'Google silent sign-in failed (PlatformException: ${e.code})',
        e.message ?? e.toString(),
        st,
      );
      return null;
    } catch (e, st) {
      AppLogger.error('Google silent sign-in failed', e, st);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;
}

