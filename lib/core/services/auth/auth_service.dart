import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  const AuthUser({
    required this.firstName,
    required this.lastName,
    required this.contact,
    required this.password,
    this.region,
  });

  final String firstName;
  final String lastName;
  final String contact;
  final String password;
  final String? region;

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
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
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

    await prefs.setString(_keyFirstName, user.firstName);
    await prefs.setString(_keyLastName, user.lastName);
    await prefs.setString(_keyContact, user.contact);
    await prefs.setString(_keyPassword, user.password);
    if (user.region != null) {
      await prefs.setString(_keyRegion, user.region!);
    } else {
      await prefs.remove(_keyRegion);
    }
    await prefs.setBool(_keyLoggedIn, true);
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
  }

  Future<void> clearSession() => logout();

  Future<AuthUser?> fetchActiveUser() async {
    final prefs = _preferences;
    final isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    return _readUserFromPrefs(prefs);
  }

  Future<AuthUser?> getStoredUser() async {
    final prefs = _preferences;
    return _readUserFromPrefs(prefs);
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
      return null;
    }

    final region = prefs.getString(_keyRegion);

    return AuthUser(
      firstName: firstName,
      lastName: lastName,
      contact: contact,
      password: password,
      region: region,
    );
  }
}
