// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mortgage_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MortgageModel _$MortgageModelFromJson(Map<String, dynamic> json) =>
    MortgageModel(
      id: _intFromJson(json['id']),
      bankName: _toString(json['bank_name']),
      description: _toString(json['description']),
      interestRate: _toString(json['interest_rate']),
      term: _toString(json['term']),
      maxSum: _toString(json['max_sum']),
      downPayment: _toString(json['down_payment']),
      currency: _toStringOrNull(json['currency']),
      rating: _doubleFromJsonOrNull(json['rating']),
      advantages: _listStringFromJsonOrNull(json['advantages']),
      propertyType: _toStringOrNull(json['property_type']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MortgageModelToJson(MortgageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'description': instance.description,
      'interest_rate': instance.interestRate,
      'term': instance.term,
      'max_sum': instance.maxSum,
      'down_payment': instance.downPayment,
      'currency': instance.currency,
      'rating': instance.rating,
      'advantages': instance.advantages,
      'property_type': instance.propertyType,
      'created_at': instance.createdAt?.toIso8601String(),
    };
