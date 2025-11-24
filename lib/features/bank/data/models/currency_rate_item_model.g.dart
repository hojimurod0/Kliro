// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyRateItemModel _$CurrencyRateItemModelFromJson(
        Map<String, dynamic> json) =>
    CurrencyRateItemModel(
      bank: json['bank'] as String,
      id: CurrencyRateItemModel._idFromJson(json['id']),
      rate: json['rate'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$CurrencyRateItemModelToJson(
        CurrencyRateItemModel instance) =>
    <String, dynamic>{
      'bank': instance.bank,
      'id': instance.id,
      'rate': instance.rate,
      'updated_at': instance.updatedAt,
    };
