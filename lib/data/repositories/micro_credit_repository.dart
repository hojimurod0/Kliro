import '../api/api_exceptions.dart';
import '../models/micro_credit.dart';
import '../models/pagination_filter.dart';
import '../models/sorting.dart';
import '../services/micro_credit_service.dart';
import 'repository_exception.dart';

class MicroCreditRepository {
  MicroCreditRepository(this._service);

  final MicroCreditService _service;

  Future<List<MicroCredit>> getMicroCredits({
    PaginationFilter? pagination,
    Sorting? sorting,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
  }) async {
    try {
      return await _service.fetchMicroCredits(
        pagination: pagination,
        sorting: sorting,
        bank: bank,
        rateFrom: rateFrom,
        termMonthsFrom: termMonthsFrom,
        amountFrom: amountFrom,
        opening: opening,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки микрокредитов',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

