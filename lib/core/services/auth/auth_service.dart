import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger.dart';

class AuthUser {
  const AuthUser({
    required this.firstName,
    required this.lastName,
    required this.contact,
    required this.password,
    this.region,
    this.email,
    this.phone,
  });

  final String firstName;
  final String lastName;
  final String contact;
  final String password;
  final String? region;
  final String? email;
  final String? phone;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0] : '';
    return (firstInitial + lastInitial).isEmpty
        ? (contact.isNotEmpty ? contact[0] : '?')
        : (firstInitial + lastInitial).toUpperCase();
  }
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyFirstName = 'auth_first_name';
  static const _keyLastName = 'auth_last_name';
  static const _keyContact = 'auth_contact';
  static const _keyPassword = 'auth_password';
  static const _keyRegion = 'auth_region';
  static const _keyEmail = 'auth_email';
  static const _keyPhone = 'auth_phone';
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// SharedPreferences ni tashqaridan olish - performance optimizatsiyasi uchun
  /// Bu metod SharedPreferences ni bir marta yuklab, ikkala service'ga pass qilish uchun ishlatiladi
  Future<void> initWithPrefs(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  SharedPreferences get _preferences {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('AuthService not initialized');
    }
    return prefs;
  }

  static String normalizeContact(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d+]'), '');

    if (digitsOnly.startsWith('+')) {
      final cleaned = digitsOnly.replaceAll(RegExp(r'[^\d]'), '');
      return '+$cleaned';
    }

    final onlyDigits = trimmed.replaceAll(RegExp(r'[^\d]'), '');

    if (onlyDigits.isEmpty) return '';

    if (onlyDigits.startsWith('998')) {
      return '+$onlyDigits';
    }

    if (onlyDigits.startsWith('00') && onlyDigits.length > 2) {
      return '+${onlyDigits.substring(2)}';
    }

    return '+998$onlyDigits';
  }

  Future<void> saveProfile(AuthUser user) async {
    final prefs = _preferences;

    AppLogger.debug('💾 AUTH_SERVICE: Saving profile to SharedPreferences');
    AppLogger.debug('💾 AUTH_SERVICE: user.email: ${user.email ?? "null"}');
    AppLogger.debug('💾 AUTH_SERVICE: user.phone: ${user.phone ?? "null"}');
    AppLogger.debug('💾 AUTH_SERVICE: user.contact: ${user.contact}');
    AppLogger.debug('💾 AUTH_SERVICE: user.firstName: ${user.firstName}');
    AppLogger.debug('💾 AUTH_SERVICE: user.lastName: ${user.lastName}');

    await prefs.setString(_keyFirstName, user.firstName);
    await prefs.setString(_keyLastName, user.lastName);
    await prefs.setString(_keyContact, user.contact);
    await prefs.setString(_keyPassword, user.password);

    // Email va telefon alohida saqlash
    if (user.email != null && user.email!.isNotEmpty) {
      await prefs.setString(_keyEmail, user.email!);
      AppLogger.debug('💾 AUTH_SERVICE: Email saved to SharedPreferences: ${user.email}');
    } else {
      await prefs.remove(_keyEmail);
      AppLogger.debug('💾 AUTH_SERVICE: Email removed from SharedPreferences (was null or empty)');
    }
    
    if (user.phone != null && user.phone!.isNotEmpty) {
      await prefs.setString(_keyPhone, user.phone!);
      AppLogger.debug('💾 AUTH_SERVICE: Phone saved to SharedPreferences: ${user.phone}');
    } else {
      await prefs.remove(_keyPhone);
      AppLogger.debug('💾 AUTH_SERVICE: Phone removed from SharedPreferences (was null or empty)');
    }
    
    if (user.region != null) {
      await prefs.setString(_keyRegion, user.region!);
    } else {
      await prefs.remove(_keyRegion);
    }
    await prefs.setBool(_keyLoggedIn, true);
    AppLogger.debug('💾 AUTH_SERVICE: Profile saved successfully');
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = _preferences;
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setBool(_keyLoggedIn, true);
  }

  Future<String?> getAccessToken() async {
    final prefs = _preferences;
    return prefs.getString(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = _preferences;
    return prefs.getString(_keyRefreshToken);
  }

  Future<bool> validateCredentials({
    required String contact,
    required String password,
  }) async {
    final prefs = _preferences;
    final storedContact = prefs.getString(_keyContact);
    final storedPassword = prefs.getString(_keyPassword);
    if (storedContact == null || storedPassword == null) {
      return false;
    }
    return storedContact == contact && storedPassword == password;
  }

  Future<void> markLoggedIn() async {
    await _preferences.setBool(_keyLoggedIn, true);
  }

  Future<void> logout() async {
    final prefs = _preferences;
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyFirstName);
    await prefs.remove(_keyLastName);
    await prefs.remove(_keyContact);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyRegion);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
  }

  Future<void> clearSession() => logout();

  Future<AuthUser?> fetchActiveUser() async {
    final prefs = _preferences;
    final isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (!isLoggedIn) {
      AppLogger.debug('👤 AUTH_SERVICE: fetchActiveUser - User not logged in');
      return null;
    }
    final user = _readUserFromPrefs(prefs);
    AppLogger.debug('👤 AUTH_SERVICE: fetchActiveUser - User loaded');
    if (user != null) {
      AppLogger.debug('👤 AUTH_SERVICE: fetchActiveUser - user.email: ${user.email ?? "null"}');
      AppLogger.debug('👤 AUTH_SERVICE: fetchActiveUser - user.phone: ${user.phone ?? "null"}');
      AppLogger.debug('👤 AUTH_SERVICE: fetchActiveUser - user.contact: ${user.contact}');
    }
    return user;
  }

  Future<AuthUser?> getStoredUser() async {
    final prefs = _preferences;
    final user = _readUserFromPrefs(prefs);
    AppLogger.debug('👤 AUTH_SERVICE: getStoredUser - User loaded');
    if (user != null) {
      AppLogger.debug('👤 AUTH_SERVICE: getStoredUser - user.email: ${user.email ?? "null"}');
      AppLogger.debug('👤 AUTH_SERVICE: getStoredUser - user.phone: ${user.phone ?? "null"}');
      AppLogger.debug('👤 AUTH_SERVICE: getStoredUser - user.contact: ${user.contact}');
    } else {
      AppLogger.debug('👤 AUTH_SERVICE: getStoredUser - No user found in SharedPreferences');
    }
    return user;
  }

  AuthUser? _readUserFromPrefs(SharedPreferences prefs) {
    final firstName = prefs.getString(_keyFirstName);
    final lastName = prefs.getString(_keyLastName);
    final contact = prefs.getString(_keyContact);
    final password = prefs.getString(_keyPassword);

    if (firstName == null ||
        lastName == null ||
        contact == null ||
        password == null) {
      AppLogger.debug('👤 AUTH_SERVICE: _readUserFromPrefs - Missing required fields');
      return null;
    }

    final region = prefs.getString(_keyRegion);
    final email = prefs.getString(_keyEmail);
    final phone = prefs.getString(_keyPhone);

    AppLogger.debug('👤 AUTH_SERVICE: _readUserFromPrefs - Reading from SharedPreferences');
    AppLogger.debug('👤 AUTH_SERVICE: _readUserFromPrefs - email from prefs: ${email ?? "null"}');
    AppLogger.debug('👤 AUTH_SERVICE: _readUserFromPrefs - phone from prefs: ${phone ?? "null"}');
    AppLogger.debug('👤 AUTH_SERVICE: _readUserFromPrefs - contact from prefs: $contact');

    return AuthUser(
      firstName: firstName,
      lastName: lastName,
      contact: contact,
      password: password,
      region: region,
      email: email,
      phone: phone,
    );
  }
}
