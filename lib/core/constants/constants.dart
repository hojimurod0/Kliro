class ApiConstants {
  ApiConstants._();

  // Production server base URL
  static String get baseUrl => 'https://api.kliro.uz';

  // Agar real server IP manzilini ishlatmoqchi bo'lsangiz, quyidagilardan birini ishlating:
  // static const String baseUrl = 'http://192.168.1.100:8080'; // Kompyuteringizning IP manzili
  // static const String baseUrl = 'https://your-api-domain.com'; // Production server

  // Timeout'lar - server sekin bo'lsa, bu qiymatlarni oshirishingiz mumkin
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(
    seconds: 60,
  ); // OTP yuborish uchun ko'proq vaqt

  // API adresini ko'rsatish uchun
  static String get currentBaseUrl => baseUrl;

  // API adresini o'zgartirish uchun (debug/testing)
  static String? _customBaseUrl;
  static void setCustomBaseUrl(String? url) {
    _customBaseUrl = url;
  }

  static String get effectiveBaseUrl => _customBaseUrl ?? baseUrl;
}

class ApiPaths {
  ApiPaths._();

  // Authentication
  static const String registerSendOtp = '/auth/register';
  static const String confirmOtp = '/auth/confirm-otp';
  static const String finalizeRegistration = '/auth/set-region-password-final';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Google OAuth
  static const String googleLogin = '/auth/google';
  static const String googleComplete = '/auth/google/complete';

  // User profile
  static const String getProfile = '/user/profile';
  static const String updateProfile = '/user/update-profile';
  static const String changeRegion = '/user/change-region';
  static const String changePassword = '/user/change-password';
  static const String updateContact = '/user/update-contact';
  static const String confirmUpdateContact = '/user/confirm-update-contact';
  static const String logout = '/user/logout';

  // Bank services
  static const String getCurrencies = '/bank/currencies/new';
  static const String searchBankServices = '/bank/search';
  static const String getMicrocredits = '/bank/microcredits/new';
}
