// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyModel _$CurrencyModelFromJson(Map<String, dynamic> json) =>
    CurrencyModel(
      id: (json['id'] as num).toInt(),
      bankName: json['bank_name'] as String,
      currencyCode: json['currency_code'] as String,
      currencyName: json['currency_name'] as String,
      buyRate: (json['buy_rate'] as num).toDouble(),
      sellRate: (json['sell_rate'] as num).toDouble(),
      location: json['location'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      schedule: json['schedule'] as String?,
      isOnline: json['is_online'] as bool?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$CurrencyModelToJson(CurrencyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'currency_code': instance.currencyCode,
      'currency_name': instance.currencyName,
      'buy_rate': instance.buyRate,
      'sell_rate': instance.sellRate,
      'location': instance.location,
      'rating': instance.rating,
      'schedule': instance.schedule,
      'is_online': instance.isOnline,
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };
