import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_filter.dart';
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

  /// Parse Hotelios API response format
  /// Format: {"success": true, "data": {"hotels": [...]}}
  factory SearchResponseModel.fromApiJson(
    Map<String, dynamic> json, {
    HotelFilter? filter,
  }) {
    // API response format: {"success": true, "data": {...}}
    final success = json['success'] as bool? ?? false;
    if (!success) {
      final message = json['message'] as String?;
      throw ValidationException(message ?? 'Qidiruv muvaffaqiyatsiz');
    }

    final data = json['data'] as Map<String, dynamic>? ?? json;
    final hotelsData = data['hotels'] as List<dynamic>? ?? [];
    
    // Extract dates and guests from filter
    final checkInDate = filter?.checkInDate;
    final checkOutDate = filter?.checkOutDate;
    final guests = (filter?.occupancies != null && filter!.occupancies!.isNotEmpty)
        ? filter.occupancies!.first.adults
        : filter?.guests ?? 1;

    final hotels = hotelsData
        .map((item) {
          try {
            final hotelMap = item as Map<String, dynamic>;
            return HotelModel.fromApiJson(
              hotelMap,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              guests: guests,
            );
          } catch (e) {
            return null;
          }
        })
        .whereType<HotelModel>()
        .toList();

    return SearchResponseModel(
      hotels: hotels,
      total: data['total'] as int? ?? 
             data['total_count'] as int? ?? 
             hotels.length,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? 
                data['pageSize'] as int? ?? 
                10,
    );
  }

  /// Legacy format support
  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final hotelsData = json['hotels'] as List<dynamic>? ?? 
                       json['data'] as List<dynamic>? ?? 
                       json['results'] as List<dynamic>? ?? [];
    final hotels = hotelsData
        .map((item) {
          try {
            return HotelModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            return null;
          }
        })
        .whereType<HotelModel>()
        .toList();

    return SearchResponseModel(
      hotels: hotels,
      total: json['total'] as int? ?? json['total_count'] as int? ?? hotels.length,
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

