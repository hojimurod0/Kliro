// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_offers_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchOffersRequestModel _$SearchOffersRequestModelFromJson(
        Map<String, dynamic> json) =>
    SearchOffersRequestModel(
      adults: (json['adults'] as num).toInt(),
      children: (json['children'] as num?)?.toInt() ?? 0,
      infants: (json['infants'] as num?)?.toInt() ?? 0,
      infantsWithSeat: (json['infants_with_seat'] as num?)?.toInt() ?? 0,
      serviceClass: json['service_class'] as String,
      directions: (json['directions'] as List<dynamic>)
          .map((e) => DirectionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchOffersRequestModelToJson(
        SearchOffersRequestModel instance) =>
    <String, dynamic>{
      'adults': instance.adults,
      'children': instance.children,
      'infants': instance.infants,
      'infants_with_seat': instance.infantsWithSeat,
      'service_class': instance.serviceClass,
      'directions': instance.directions,
    };

DirectionModel _$DirectionModelFromJson(Map<String, dynamic> json) =>
    DirectionModel(
      departureAirport: json['departure_airport'] as String,
      arrivalAirport: json['arrival_airport'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$DirectionModelToJson(DirectionModel instance) =>
    <String, dynamic>{
      'departure_airport': instance.departureAirport,
      'arrival_airport': instance.arrivalAirport,
      'date': instance.date,
    };
