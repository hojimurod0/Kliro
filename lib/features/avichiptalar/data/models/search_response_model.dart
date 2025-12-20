import '../../domain/entities/avichipta_search_result.dart';
import 'avichipta_model.dart';

class SearchResponseModel {
  const SearchResponseModel({
    required this.flights,
    this.totalCount,
    this.minPrice,
    this.maxPrice,
  });

  final List<AvichiptaModel> flights;
  final int? totalCount;
  final double? minPrice;
  final double? maxPrice;

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final flightsData = json['flights'] as List<dynamic>? ?? [];
    final flights = flightsData
        .map((item) => AvichiptaModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchResponseModel(
      flights: flights,
      totalCount: json['total_count'] as int? ?? json['totalCount'] as int?,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? (json['maxPrice'] as num?)?.toDouble(),
    );
  }

  AvichiptaSearchResult toEntity() {
    return AvichiptaSearchResult(
      flights: flights,
      totalCount: totalCount,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}

