import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/mortgage_entity.dart';

part 'mortgage_model.g.dart';

@JsonSerializable()
class MortgageModel {
  MortgageModel({
    required this.id,
    required this.bankName,
    required this.description,
    required this.interestRate,
    required this.term,
    required this.maxSum,
    required this.downPayment,
    this.currency,
    this.rating,
    this.advantages,
    this.propertyType,
    this.createdAt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int id;

  @JsonKey(name: 'bank_name', fromJson: _toString)
  final String bankName;

  @JsonKey(fromJson: _toString)
  final String description;

  @JsonKey(name: 'interest_rate', fromJson: _toString)
  final String interestRate;

  @JsonKey(fromJson: _toString)
  final String term;

  @JsonKey(name: 'max_sum', fromJson: _toString)
  final String maxSum;

  @JsonKey(name: 'down_payment', fromJson: _toString)
  final String downPayment;

  @JsonKey(fromJson: _toStringOrNull)
  final String? currency;

  @JsonKey(fromJson: _doubleFromJsonOrNull)
  final double? rating;

  @JsonKey(fromJson: _listStringFromJsonOrNull)
  final List<String>? advantages;

  @JsonKey(name: 'property_type', fromJson: _toStringOrNull)
  final String? propertyType;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory MortgageModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    final rawInterest = normalized['interest_rate'];
    if (rawInterest == null ||
        (rawInterest is String && rawInterest.trim().isEmpty)) {
      final fallback = json['rate'] ?? json['percent'];
      if (fallback != null) {
        normalized['interest_rate'] = fallback;
      }
    }

    final rawMaxSum = normalized['max_sum'];
    if (rawMaxSum == null ||
        (rawMaxSum is String && rawMaxSum.trim().isEmpty)) {
      final fallback =
          json['amount'] ??
          json['loan_amount'] ??
          json['maxSum'] ??
          json['max_amount'];
      if (fallback != null) {
        normalized['max_sum'] = fallback;
      }
    }

    final rawDownPayment = normalized['down_payment'];
    if (rawDownPayment == null ||
        (rawDownPayment is String && rawDownPayment.trim().isEmpty)) {
      final fallback =
          json['initial_payment'] ??
          json['downPayment'] ??
          json['initialPayment'] ??
          json['opening'];
      if (fallback != null) {
        normalized['down_payment'] = fallback;
      }
    }

    final rawPropertyType = normalized['property_type'];
    if (rawPropertyType == null ||
        (rawPropertyType is String && rawPropertyType.trim().isEmpty)) {
      final fallback = json['propertyType'] ?? json['property'];
      if (fallback != null) {
        normalized['property_type'] = fallback;
      }
    }

    return _$MortgageModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$MortgageModelToJson(this);
}

extension MortgageModelX on MortgageModel {
  MortgageEntity toEntity() => MortgageEntity(
        id: id,
        bankName: bankName,
        description: description,
        interestRate: interestRate,
        term: term,
        maxSum: maxSum,
        downPayment: downPayment,
        currency: currency,
        rating: rating,
        advantages: advantages,
        propertyType: propertyType,
        createdAt: createdAt,
      );
}

String _toString(Object? value) => value?.toString() ?? '';

String? _toStringOrNull(Object? value) {
  if (value == null) return null;
  return value.toString().isEmpty ? null : value.toString();
}

double? _doubleFromJsonOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return null;
}

List<String>? _listStringFromJsonOrNull(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return null;
}

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
