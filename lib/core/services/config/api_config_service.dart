import '../../constants/constants.dart';

class ApiConfigService {
  const ApiConfigService._();

  static void configureBaseUrl() {
    ApiConstants.setCustomBaseUrl('https://api.kliro.uz');
  }
}

