// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyDataModel _$CurrencyDataModelFromJson(Map<String, dynamic> json) =>
    CurrencyDataModel(
      buySorted: (json['buy_sorted'] as List<dynamic>)
          .map((e) => CurrencyRateItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sellSorted: (json['sell_sorted'] as List<dynamic>)
          .map((e) => CurrencyRateItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CurrencyDataModelToJson(CurrencyDataModel instance) =>
    <String, dynamic>{
      'buy_sorted': instance.buySorted,
      'sell_sorted': instance.sellSorted,
    };
