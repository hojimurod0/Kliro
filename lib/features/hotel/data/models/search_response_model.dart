import '../../domain/entities/hotel_search_result.dart';
import 'hotel_model.dart';

class SearchResponseModel {
  const SearchResponseModel({
    required this.hotels,
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
  });

  final List<HotelModel> hotels;
  final int total;
  final int page;
  final int pageSize;

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final hotelsData = json['hotels'] as List<dynamic>? ?? 
                       json['data'] as List<dynamic>? ?? 
                       json['results'] as List<dynamic>? ?? [];
    final hotels = hotelsData
        .map((item) => HotelModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchResponseModel(
      hotels: hotels,
      total: json['total'] as int? ?? json['total_count'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? json['pageSize'] as int? ?? 10,
    );
  }

  HotelSearchResult toEntity() {
    return HotelSearchResult(
      hotels: hotels,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }
}

