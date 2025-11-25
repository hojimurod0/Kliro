import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/deposit_entity.dart';

part 'deposit_model.g.dart';

@JsonSerializable()
class DepositModel {
  DepositModel({
    required this.id,
    required this.bankName,
    required this.description,
    required this.rate,
    required this.term,
    required this.amount,
    this.currency,
    this.createdAt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int id;

  @JsonKey(name: 'bank_name', fromJson: _toString)
  final String bankName;

  @JsonKey(fromJson: _toString)
  final String description;

  @JsonKey(fromJson: _toString)
  final String rate;

  @JsonKey(readValue: _readTermValue, fromJson: _toString)
  final String term;

  @JsonKey(readValue: _readAmountValue, fromJson: _toString)
  final String amount;

  @JsonKey(fromJson: _toStringOrNull)
  final String? currency;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory DepositModel.fromJson(Map<String, dynamic> json) =>
      _$DepositModelFromJson(json);

  Map<String, dynamic> toJson() => _$DepositModelToJson(this);
}

extension DepositModelX on DepositModel {
  DepositEntity toEntity() => DepositEntity(
    id: id,
    bankName: bankName,
    description: description,
    rate: rate,
    term: term,
    amount: amount,
    currency: currency,
    createdAt: createdAt,
  );
}

String _toString(Object? value) => value?.toString() ?? '';

Object? _readTermValue(Map json, String key) =>
    json['term_years'] ?? json['term_months'] ?? json['term'];

Object? _readAmountValue(Map json, String key) =>
    json['min_amount'] ?? json['amount'];

String? _toStringOrNull(Object? value) {
  if (value == null) return null;
  return value.toString().isEmpty ? null : value.toString();
}

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
