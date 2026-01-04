// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteModel _$QuoteModelFromJson(Map<String, dynamic> json) => QuoteModel(
      quoteId: json['quoteId'] as String,
      hotel: HotelModel.fromJson(json['hotel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuoteModelToJson(QuoteModel instance) =>
    <String, dynamic>{
      'quoteId': instance.quoteId,
      'hotel': instance.hotel,
    };
