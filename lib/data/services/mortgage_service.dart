import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/mortgage.dart';
import '../models/pagination_filter.dart';

class MortgageService {
  MortgageService(this._client);

  final ApiClient _client;

  Future<List<Mortgage>> fetchMortgages({
    PaginationFilter? pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? search,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/mortgages/new',
      queryParameters: {
        ...?pagination?.toQuery(),
        if (bank != null) 'bank': bank,
        if (rateFrom != null) 'rate_from': rateFrom,
        if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
        if (amountFrom != null) 'amount_from': amountFrom,
        if (search != null) 'search': search,
      },
    );

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => Mortgage.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

