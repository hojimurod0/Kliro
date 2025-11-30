import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/micro_credit.dart';
import '../models/pagination_filter.dart';
import '../models/sorting.dart';

class MicroCreditService {
  MicroCreditService(this._client);

  final ApiClient _client;

  Future<List<MicroCredit>> fetchMicroCredits({
    PaginationFilter? pagination,
    Sorting? sorting,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/microcredits/new',
      queryParameters: {
        ...?pagination?.toQuery(),
        ...?sorting?.toQuery(),
        if (bank != null) 'bank': bank,
        if (rateFrom != null) 'rate_from': rateFrom,
        if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
        if (amountFrom != null) 'amount_from': amountFrom,
        if (opening != null) 'opening': opening,
        if (search != null) 'search': search,
      },
    );

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map(
          (json) => MicroCredit.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}

