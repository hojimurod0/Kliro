import '../../constants/constants.dart';

class ApiConfigService {
  const ApiConfigService._();

  static void configureBaseUrl() {
    // Prefer runtime configuration via --dart-define.
    // Example (local backend):
    // flutter run --dart-define=API_BASE_URL=http://localhost:8080
    //
    // Fallback: keep default production base URL from ApiConstants.baseUrl.
    const apiBaseUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    const legacyHotelBaseUrl =
        String.fromEnvironment('HOTEL_BASE_URL', defaultValue: '');

    final configured =
        apiBaseUrl.isNotEmpty ? apiBaseUrl : legacyHotelBaseUrl;

    // Only override if explicitly provided; otherwise don't force prod and
    // allow ApiConstants.baseUrl default to be used.
    ApiConstants.setCustomBaseUrl(configured.isNotEmpty ? configured : null);
  }
}

