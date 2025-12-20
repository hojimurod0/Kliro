// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferModel _$OfferModelFromJson(Map<String, dynamic> json) => OfferModel(
      id: json['id'] as String?,
      price: json['price'] as String?,
      currency: json['currency'] as String?,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => SegmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      airline: json['airline'] as String?,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$OfferModelToJson(OfferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'currency': instance.currency,
      'segments': instance.segments,
      'airline': instance.airline,
      'duration': instance.duration,
    };

SegmentModel _$SegmentModelFromJson(Map<String, dynamic> json) => SegmentModel(
      departureAirport: json['departureAirport'] as String?,
      arrivalAirport: json['arrivalAirport'] as String?,
      departureAirportName: json['departureAirportName'] as String?,
      arrivalAirportName: json['arrivalAirportName'] as String?,
      departureTerminal: json['departureTerminal'] as String?,
      arrivalTerminal: json['arrivalTerminal'] as String?,
      aircraft: json['aircraft'] as String?,
      cabinClass: json['cabinClass'] as String?,
      baggage: json['baggage'] as String?,
      handBaggage: json['handBaggage'] as String?,
      departureTime: json['departureTime'] as String?,
      arrivalTime: json['arrivalTime'] as String?,
      flightNumber: json['flightNumber'] as String?,
      airline: json['airline'] as String?,
    );

Map<String, dynamic> _$SegmentModelToJson(SegmentModel instance) =>
    <String, dynamic>{
      'departureAirport': instance.departureAirport,
      'arrivalAirport': instance.arrivalAirport,
      'departureAirportName': instance.departureAirportName,
      'arrivalAirportName': instance.arrivalAirportName,
      'departureTerminal': instance.departureTerminal,
      'arrivalTerminal': instance.arrivalTerminal,
      'aircraft': instance.aircraft,
      'cabinClass': instance.cabinClass,
      'baggage': instance.baggage,
      'handBaggage': instance.handBaggage,
      'departureTime': instance.departureTime,
      'arrivalTime': instance.arrivalTime,
      'flightNumber': instance.flightNumber,
      'airline': instance.airline,
    };

OffersResponseModel _$OffersResponseModelFromJson(Map<String, dynamic> json) =>
    OffersResponseModel(
      offers: (json['offers'] as List<dynamic>?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OffersResponseModelToJson(
        OffersResponseModel instance) =>
    <String, dynamic>{
      'offers': instance.offers,
      'total': instance.total,
    };
