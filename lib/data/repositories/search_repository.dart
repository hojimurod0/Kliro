import '../api/api_exceptions.dart';
import '../models/pagination_filter.dart';
import '../models/search_result.dart';
import '../services/search_service.dart';
import 'repository_exception.dart';

class SearchRepository {
  SearchRepository(this._service);

  final SearchService _service;

  Future<List<SearchResultItem>> searchAcrossDirections({
    required String query,
    PaginationFilter? pagination,
  }) async {
    try {
      return await _service.searchAllDirections(
        query: query,
        pagination: pagination,
      );
    } on ApiException catch (error, stackTrace) {
      throw RepositoryException(
        error.message ?? 'Ошибка глобального поиска',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

