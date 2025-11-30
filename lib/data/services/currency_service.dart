import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/currency_rate.dart';

class CurrencyService {
  CurrencyService(this._client);

  final ApiClient _client;

  Future<List<CurrencyRate>> fetchCurrentRates() async {
    final Response<dynamic> response =
        await _client.get('/bank/currencies/new');
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => CurrencyRate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<CurrencyRate>> fetchRatesByDate({
    required String date,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/currencies/by-date',
      queryParameters: {'date': date},
    );
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => CurrencyRate.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

