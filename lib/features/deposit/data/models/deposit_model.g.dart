// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositModel _$DepositModelFromJson(Map<String, dynamic> json) => DepositModel(
      id: _intFromJson(json['id']),
      bankName: _toString(json['bank_name']),
      description: _toString(json['description']),
      rate: _toString(json['rate']),
      term: _toString(json['term']),
      amount: _toString(json['amount']),
      currency: _toStringOrNull(json['currency']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DepositModelToJson(DepositModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'description': instance.description,
      'rate': instance.rate,
      'term': instance.term,
      'amount': instance.amount,
      'currency': instance.currency,
      'created_at': instance.createdAt?.toIso8601String(),
    };
