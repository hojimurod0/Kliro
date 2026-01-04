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

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);

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
