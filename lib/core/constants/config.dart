/// Конфигурация приложения для Travel Insurance модуля
class AppConfig {
  /// Базовый URL API
  /// По умолчанию: http://localhost:8080
  /// Можно переопределить через переменные окружения
  static String get baseUrl {
    const String? envUrl = String.fromEnvironment('API_BASE_URL');
    return envUrl ?? 'http://localhost:8080';
  }

  /// Включить логирование HTTP запросов
  static bool get enableLogging {
    const String? envLogging = String.fromEnvironment('ENABLE_LOGGING');
    return envLogging == 'true' || const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
  }

  /// Таймаут подключения в секундах
  static const int connectionTimeout = 30;

  /// Таймаут получения данных в секундах
  static const int receiveTimeout = 30;
}

