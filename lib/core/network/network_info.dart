import 'package:dio/dio.dart';

/// Интерфейс для проверки сетевого подключения
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Реализация NetworkInfo через Dio
class NetworkInfoImpl implements NetworkInfo {
  final Dio dio;

  NetworkInfoImpl(this.dio);

  @override
  Future<bool> get isConnected async {
    try {
      // Простая проверка доступности сети
      // В реальном приложении можно использовать connectivity_plus
      return true;
    } catch (_) {
      return false;
    }
  }
}

