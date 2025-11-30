import '../api/api_exceptions.dart';
import '../models/currency_rate.dart';
import '../services/currency_service.dart';
import 'repository_exception.dart';

class CurrencyRepository {
  CurrencyRepository(this._service);

  final CurrencyService _service;

  Future<List<CurrencyRate>> getCurrentRates() async {
    try {
      return await _service.fetchCurrentRates();
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки курсов',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<CurrencyRate>> getRatesByDate(String date) async {
    try {
      return await _service.fetchRatesByDate(date: date);
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки курсов по дате',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

