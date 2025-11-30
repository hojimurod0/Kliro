import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/auto_credit.dart';
import '../models/pagination_filter.dart';

class AutoCreditService {
  AutoCreditService(this._client);

  final ApiClient _client;

  Future<List<AutoCredit>> fetchAutoCredits({
    PaginationFilter? pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
    String? sort,
    String? direction,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/autocredits/new',
      queryParameters: {
        ...?pagination?.toQuery(),
        if (bank != null) 'bank': bank,
        if (rateFrom != null) 'rate_from': rateFrom,
        if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
        if (amountFrom != null) 'amount_from': amountFrom,
        if (opening != null) 'opening': opening,
        if (search != null) 'search': search,
        if (sort != null) 'sort': sort,
        if (direction != null) 'direction': direction,
      },
    );

    final items = _extractItems(response.data);
    return items
        .map((json) => AutoCredit.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractItems(dynamic data) {
    if (data is List<dynamic>) return data;

    if (data is Map<String, dynamic>) {
      final result = data['result'];
      if (result is List<dynamic>) return result;

      if (result is Map<String, dynamic>) {
        final content = result['content'];
        if (content is List<dynamic>) return content;
      }

      // Some endpoints may return data directly under 'data' key
      final direct = data['data'];
      if (direct is List<dynamic>) return direct;
    }

    return const [];
  }
}

