import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/bank_card.dart';
import '../models/pagination_filter.dart';

class CardService {
  CardService(this._client);

  final ApiClient _client;

  Future<List<BankCard>> fetchCards({
    PaginationFilter? pagination,
    String? bank,
    String? cardType,
    String? search,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/cards/new',
      queryParameters: {
        ...?pagination?.toQuery(),
        if (bank != null) 'bank': bank,
        if (cardType != null) 'card_type': cardType,
        if (search != null) 'search': search,
      },
    );

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => BankCard.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BankCard>> fetchCreditCards({
    PaginationFilter? pagination,
    String? bank,
    String? search,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/credit-cards/new',
      queryParameters: {
        ...?pagination?.toQuery(),
        if (bank != null) 'bank': bank,
        if (search != null) 'search': search,
      },
    );

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => BankCard.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

