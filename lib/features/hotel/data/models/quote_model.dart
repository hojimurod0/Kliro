import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/hotel_booking.dart';
import 'hotel_model.dart';

class QuoteModel {
  const QuoteModel({
    required this.quoteId,
    required this.hotel,
  });

  final String quoteId;
  final HotelModel hotel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final quoteId = data['quote_id'] as String? ?? '';
    
    // Parse hotel from quote response
    final hotelData = data['hotel'] as Map<String, dynamic>?;
    if (hotelData == null) {
      throw ValidationException('Hotel ma\'lumotlari topilmadi');
    }

    final hotel = HotelModel.fromApiJson(hotelData);

    return QuoteModel(
      quoteId: quoteId,
      hotel: hotel,
    );
  }

  HotelQuote toEntity() {
    return HotelQuote(
      quoteId: quoteId,
      hotel: hotel,
    );
  }
}

