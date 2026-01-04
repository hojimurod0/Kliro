import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_filter.dart';
import 'hotel_model.dart';

part 'search_response_model.g.dart';

@JsonSerializable()
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

    // Debug log qo'shamiz
    debugPrint(
        '🔍 SearchResponseModel.fromApiJson: hotelsData.length = ${hotelsData.length}');
    debugPrint('🔍 SearchResponseModel: data keys = ${data.keys.toList()}');

    // Extract dates and guests from filter
    final checkInDate = filter?.checkInDate;
    final checkOutDate = filter?.checkOutDate;
    final guests =
        (filter?.occupancies != null && filter!.occupancies!.isNotEmpty)
            ? filter.occupancies!.first.adults
            : filter?.guests ?? 1;

    final hotels = hotelsData
        .map((item) {
          try {
            final hotelMap = item as Map<String, dynamic>;
            debugPrint(
                '🔍 SearchResponseModel: Parsing hotel, keys = ${hotelMap.keys.toList()}');
            final hotel = HotelModel.fromApiJson(
              hotelMap,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              guests: guests,
            );
            debugPrint(
                '🔍 SearchResponseModel: Parsed hotel name="${hotel.name}", imageUrl="${hotel.imageUrl}"');
            return hotel;
          } catch (e, stackTrace) {
            debugPrint('❌ SearchResponseModel: Error parsing hotel: $e');
            debugPrint('❌ StackTrace: $stackTrace');
            return null;
          }
        })
        .whereType<HotelModel>()
        .toList();

    // Debug log qo'shamiz
    debugPrint(
        '🔍 SearchResponseModel.fromApiJson: parsed hotels.length = ${hotels.length}');
    if (hotels.isNotEmpty) {
      debugPrint('🔍 First parsed hotel: ${hotels.first.name}');
    }

    return SearchResponseModel(
      hotels: hotels,
      total:
          data['total'] as int? ?? data['total_count'] as int? ?? hotels.length,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? data['pageSize'] as int? ?? 10,
    );
  }

  /// Standard JSON format support - uses generated fromJson
  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseModelToJson(this);
}

extension SearchResponseModelX on SearchResponseModel {
  HotelSearchResult toEntity() {
    return HotelSearchResult(
      hotels: hotels,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }
}
