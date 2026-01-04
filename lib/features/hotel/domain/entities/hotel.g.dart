// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotelOption _$HotelOptionFromJson(Map<String, dynamic> json) => HotelOption(
      optionRefId: json['optionRefId'] as String,
      roomTypeId: (json['roomTypeId'] as num?)?.toInt(),
      ratePlanId: (json['ratePlanId'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      priceBreakdown: json['priceBreakdown'] as Map<String, dynamic>?,
      cancellationPolicy: json['cancellationPolicy'] as Map<String, dynamic>?,
      includedMealOptions: (json['includedMealOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HotelOptionToJson(HotelOption instance) =>
    <String, dynamic>{
      'optionRefId': instance.optionRefId,
      'roomTypeId': instance.roomTypeId,
      'ratePlanId': instance.ratePlanId,
      'price': instance.price,
      'currency': instance.currency,
      'priceBreakdown': instance.priceBreakdown,
      'cancellationPolicy': instance.cancellationPolicy,
      'includedMealOptions': instance.includedMealOptions,
    };
