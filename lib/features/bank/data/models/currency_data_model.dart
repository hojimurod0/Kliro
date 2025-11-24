import 'package:json_annotation/json_annotation.dart';

import 'currency_rate_item_model.dart';

part 'currency_data_model.g.dart';

/// Model for currency data (buy_sorted and sell_sorted arrays)
@JsonSerializable(fieldRename: FieldRename.snake)
class CurrencyDataModel {
  const CurrencyDataModel({
    required this.buySorted,
    required this.sellSorted,
  });

  @JsonKey(name: 'buy_sorted')
  final List<CurrencyRateItemModel> buySorted;
  
  @JsonKey(name: 'sell_sorted')
  final List<CurrencyRateItemModel> sellSorted;

  factory CurrencyDataModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyDataModelToJson(this);
}

