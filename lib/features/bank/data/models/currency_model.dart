import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/currency_entity.dart';

part 'currency_model.g.dart';

/// Data model for currency exchange rates from API.
@JsonSerializable(fieldRename: FieldRename.snake)
class CurrencyModel extends CurrencyEntity {
  const CurrencyModel({
    required super.id,
    required super.bankName,
    required super.currencyCode,
    required super.currencyName,
    required super.buyRate,
    required super.sellRate,
    super.location,
    super.rating,
    super.schedule,
    super.isOnline,
    super.lastUpdated,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyModelToJson(this);
}
