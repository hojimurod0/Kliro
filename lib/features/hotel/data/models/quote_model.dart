import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/hotel_booking.dart';
import 'hotel_model.dart';

part 'quote_model.g.dart';

@JsonSerializable()
class QuoteModel {
  const QuoteModel({
    required this.quoteId,
    required this.hotel,
  });

  final String quoteId;
  final HotelModel hotel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different response formats - API might return snake_case or camelCase
      Map<String, dynamic> data = json;
      
      // Check if response has 'data' wrapper
      if (json.containsKey('data')) {
        if (json['data'] is Map) {
          data = json['data'] as Map<String, dynamic>;
        }
      }
      
      // Normalize keys: quote_id -> quoteId
      final normalizedJson = <String, dynamic>{};
      
      // quote_id -> quoteId
      normalizedJson['quoteId'] = data['quote_id'] ?? 
                                 data['quoteId'] ?? 
                                 data['id'] ?? 
                                 '';
      
      // hotel - can be hotel_info or hotel
      if (data.containsKey('hotel_info') && data['hotel_info'] is Map) {
        normalizedJson['hotel'] = data['hotel_info'];
      } else if (data.containsKey('hotel') && data['hotel'] is Map) {
        normalizedJson['hotel'] = data['hotel'];
      } else {
        // If hotel is not found, use the whole data as hotel info
        normalizedJson['hotel'] = data;
      }
      
      // Use generated fromJson
      return _$QuoteModelFromJson(normalizedJson);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ QuoteModel.fromJson error: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        debugPrint('❌ JSON keys: ${json.keys.toList()}');
      }
      
      // Try to extract at least quote_id
      final data = json['data'] as Map<String, dynamic>? ?? json;
      final quoteId = data['quote_id']?.toString() ?? 
                     data['quoteId']?.toString() ?? 
                     data['id']?.toString() ?? 
                     '';
      
      // Try to get hotel info
      Map<String, dynamic> hotelData;
      if (data.containsKey('hotel_info') && data['hotel_info'] is Map) {
        hotelData = data['hotel_info'] as Map<String, dynamic>;
      } else if (data.containsKey('hotel') && data['hotel'] is Map) {
        hotelData = data['hotel'] as Map<String, dynamic>;
      } else {
        hotelData = data;
      }
      
      // Create minimal QuoteModel
      return QuoteModel(
        quoteId: quoteId,
        hotel: HotelModel.fromApiJson(hotelData),
      );
    }
  }

  Map<String, dynamic> toJson() => _$QuoteModelToJson(this);
}

extension QuoteModelX on QuoteModel {
  HotelQuote toEntity() {
    return HotelQuote(
      quoteId: quoteId,
      hotel: hotel,
    );
  }
}
