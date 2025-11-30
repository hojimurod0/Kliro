import '../api/api_exceptions.dart';
import '../models/deposit.dart';
import '../models/pagination_filter.dart';
import '../services/deposit_service.dart';
import 'repository_exception.dart';

class DepositRepository {
  DepositRepository(this._service);

  final DepositService _service;

  Future<List<Deposit>> getDeposits({
    PaginationFilter? pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? search,
  }) async {
    try {
      return await _service.fetchDeposits(
        pagination: pagination,
        bank: bank,
        rateFrom: rateFrom,
        termMonthsFrom: termMonthsFrom,
        amountFrom: amountFrom,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки депозитов',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

