import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/pagination_filter.dart';
import '../models/search_result.dart';

class SearchService {
  SearchService(this._client);

  final ApiClient _client;

  Future<List<SearchResultItem>> searchAllDirections({
    required String query,
    PaginationFilter? pagination,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/search',
      queryParameters: {
        'search': query,
        ...?pagination?.toQuery(),
      },
    );

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => SearchResultItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

