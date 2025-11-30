import '../api/api_exceptions.dart';
import '../models/mortgage.dart';
import '../models/pagination_filter.dart';
import '../services/mortgage_service.dart';
import 'repository_exception.dart';

class MortgageRepository {
  MortgageRepository(this._service);

  final MortgageService _service;

  Future<List<Mortgage>> getMortgages({
    PaginationFilter? pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? search,
  }) async {
    try {
      return await _service.fetchMortgages(
        pagination: pagination,
        bank: bank,
        rateFrom: rateFrom,
        termMonthsFrom: termMonthsFrom,
        amountFrom: amountFrom,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки ипотек',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

