class ApiConstants {
  ApiConstants._();

  // Production server base URL (can be overridden by --dart-define=HOTEL_BASE_URL)
  static String get baseUrl {
    const envBase =
        String.fromEnvironment('HOTEL_BASE_URL', defaultValue: '');
    if (envBase.isNotEmpty) return envBase;
    return 'https://api.kliro.uz';
  }

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

/// Trust Insurance API Configuration
/// 
/// Bu config Trust Accident Insurance API uchun credentials va base URL ni boshqaradi.
/// 
/// **MUHIM:** Production'da haqiqiy credentials ishlating!
/// 
/// **Variant 1:** Environment variables (Tavsiya etiladi)
/// ```bash
/// flutter run --dart-define=TRUST_API_BASE_URL=https://api.trust-insurance.uz \
///            --dart-define=TRUST_LOGIN=your_username \
///            --dart-define=TRUST_PASSWORD=your_password
/// ```
/// 
/// **Variant 2:** Bu faylda to'g'ridan-to'g'ri o'zgartiring (pastda)
class TrustInsuranceConfig {
  TrustInsuranceConfig._();

  // Trust Insurance API Base URL
  // Environment variable: TRUST_API_BASE_URL
  static String get baseUrl {
    const envUrl = String.fromEnvironment('TRUST_API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    // Trust Insurance API ham api.kliro.uz da joylashgan
    return 'https://api.kliro.uz';
  }

  // Trust Insurance Basic Auth Username
  // Environment variable: TRUST_LOGIN
  static String get username {
    const envUsername = String.fromEnvironment('TRUST_LOGIN', defaultValue: '');
    if (envUsername.isNotEmpty) {
      return envUsername;
    }
    // ⚠️ BU YERNI HAQIQIY USERNAME BILAN O'ZGARTIRING!
    // Yoki environment variable ishlating: --dart-define=TRUST_LOGIN=username
    return '';
  }

  // Trust Insurance Basic Auth Password
  // Environment variable: TRUST_PASSWORD
  static String get password {
    const envPassword = String.fromEnvironment('TRUST_PASSWORD', defaultValue: '');
    if (envPassword.isNotEmpty) {
      return envPassword;
    }
    // ⚠️ BU YERNI HAQIQIY PASSWORD BILAN O'ZGARTIRING!
    // Yoki environment variable ishlating: --dart-define=TRUST_PASSWORD=password
    return '';
  }

  /// Config to'g'ri sozlanganligini tekshirish
  static bool get isConfigured {
    // Faqat username va password mavjudligini tekshiramiz
    // Base URL default bo'lishi mumkin, lekin credentials bo'lishi kerak
    return baseUrl.isNotEmpty && 
           username.isNotEmpty && 
           password.isNotEmpty;
  }

  /// Config haqida ma'lumot
  static String get configInfo {
    return 'Base URL: $baseUrl\n'
           'Username: ${username.isEmpty ? "NOT SET" : "***"}\n'
           'Password: ${password.isEmpty ? "NOT SET" : "***"}\n'
           'Configured: $isConfigured';
  }
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
  static const String refreshToken = '/auth/refresh';

  // Google OAuth
  static const String googleLogin = '/auth/google';
  static const String googleComplete = '/auth/google/complete';
  static const String googleCallback = '/auth/google/callback';
  
  /// Google OAuth callback URL (to'liq URL)
  /// Backend'ga yuboriladigan redirect URL
  static const String googleOAuthRedirectUrl = 'https://kliro.uz/auth-callback';
  
  /// Google OAuth callback URL (to'liq URL)
  static String get googleCallbackUrl {
    return '${ApiConstants.effectiveBaseUrl}$googleCallback';
  }

  /// Google OAuth direct login URL (KLiRO sayti orqali)
  /// Bu URL to'g'ridan-to'g'ri Google OAuth sahifasiga yo'naltiradi
  /// Backend API chaqiruvsiz, to'g'ridan-to'g'ri Google OAuth flow ni ishga tushiradi
  static const String googleOAuthDirectUrl = 
    'https://accounts.google.com/v3/signin/accountchooser?access_type=offline&client_id=317528081630-iruspj0h9ot377birdgjen3cr82iaaa5.apps.googleusercontent.com&redirect_uri=https%3A%2F%2Fapi.kliro.uz%2Fauth%2Fgoogle%2Fcallback&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile';

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
  static const String getBankServices = '/bank/services';
  static const String getMicrocredits = '/bank/microcredits/new';
  static const String getDeposits = '/bank/deposits/new';
  static const String getMortgages = '/bank/mortgages/new';
  static const String getCards = '/bank/cards/new';
  static const String getCreditCards = '/bank/credit-cards/new';
  static const String getAutoCredits = '/bank/auto-credits/new';
  static const String getTransferApps = '/bank/transfers/new';
  static const String osagoCalc = '/osago/calc';
  static const String osagoCreate = '/osago/create';
  static const String osagoCheck = '/osago/check';

  // KASKO Insurance
  static const String kaskoCars = '/insurance/kasko/cars';
  static const String kaskoCarsMinimal =
      '/insurance/kasko/cars/minimal'; // Faqat brand, model, position uchun
  static const String kaskoRates = '/insurance/kasko/rates';
  static const String kaskoCarPrice = '/insurance/kasko/car-price';
  static const String kaskoCalculate = '/insurance/kasko/calculate';
  static const String kaskoSave = '/insurance/kasko/save';
  static const String kaskoPaymentLink = '/insurance/kasko/payment-link';
  static const String kaskoCheckPayment = '/insurance/kasko/check-payment';
  static const String kaskoImageUpload = '/insurance/kasko/image-upload';

  // Travel Insurance
  static const String travelPurpose = '/travel/purpose';
  static const String travelDetails = '/travel/details';
  static const String travelCalc = '/travel/calculate';
  static const String travelCreate = '/travel/save';
  static const String travelCheck = '/travel/check';
  static const String travelCountry = '/travel/country';
  static const String travelPurposes = '/travel/purposes';
  static const String travelTarifs = '/travel/tarifs';

  // Avichiptalar (Airline Tickets)
  static const String avichiptalarSearch = '/avichiptalar/search';
  static const String avichiptalarDetails = '/avichiptalar/details';
  static const String avichiptalarCities = '/avichiptalar/cities';
}
