import '../api/api_exceptions.dart';
import '../models/pagination_filter.dart';
import '../models/transfer.dart';
import '../services/transfer_service.dart';
import 'repository_exception.dart';

class TransferRepository {
  TransferRepository(this._service);

  final TransferService _service;

  Future<List<TransferServiceInfo>> getTransfers({
    PaginationFilter? pagination,
    String? app,
    double? commissionFrom,
    String? search,
  }) async {
    try {
      return await _service.fetchTransfers(
        pagination: pagination,
        app: app,
        commissionFrom: commissionFrom,
        search: search,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка загрузки переводов',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

