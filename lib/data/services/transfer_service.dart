import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/pagination_filter.dart';
import '../models/transfer.dart';

class TransferService {
  TransferService(this._client);

  final ApiClient _client;

  Future<List<TransferServiceInfo>> fetchTransfers({
    PaginationFilter? pagination,
    String? app,
    double? commissionFrom,
    String? search,
  }) async {
    final Response<dynamic> response = await _client.get(
      '/bank/transfers/new',
      queryParameters: {
        ...?pagination?.toQuery(),
        if (app != null) 'app': app,
        if (commissionFrom != null) 'commission_from': commissionFrom,
        if (search != null) 'search': search,
      },
    );

    final data = response.data as List<dynamic>? ?? [];
    return data
        .map(
          (json) =>
              TransferServiceInfo.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}

