import '../api/api_exceptions.dart';
import '../models/bank_card.dart';
import '../models/pagination_filter.dart';
import '../services/card_service.dart';
import 'repository_exception.dart';

class CardRepository {
  CardRepository(this._service);

  final CardService _service;

  Future<List<BankCard>> getCards({
    PaginationFilter? pagination,
    String? bank,
    String? cardType,
    String? search,
  }) async {
    try {
      return await _service.fetchCards(
        pagination: pagination,
        bank: bank,
        cardType: cardType,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки карт',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<BankCard>> getCreditCards({
    PaginationFilter? pagination,
    String? bank,
    String? search,
  }) async {
    try {
      return await _service.fetchCreditCards(
        pagination: pagination,
        bank: bank,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки кредитных карт',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

