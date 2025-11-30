import '../api/api_exceptions.dart';
import '../models/auto_credit.dart';
import '../models/pagination_filter.dart';
import '../services/auto_credit_service.dart';
import 'repository_exception.dart';

class AutoCreditRepository {
  AutoCreditRepository(this._service);

  final AutoCreditService _service;

  Future<List<AutoCredit>> getAutoCredits({
    PaginationFilter? pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
  }) async {
    try {
      return await _service.fetchAutoCredits(
        pagination: pagination,
        bank: bank,
        rateFrom: rateFrom,
        termMonthsFrom: termMonthsFrom,
        amountFrom: amountFrom,
        opening: opening,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки автокредитов',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

