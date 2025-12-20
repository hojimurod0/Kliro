// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalanceResponseModel _$BalanceResponseModelFromJson(
        Map<String, dynamic> json) =>
    BalanceResponseModel(
      balance: (json['balance'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$BalanceResponseModelToJson(
        BalanceResponseModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'currency': instance.currency,
    };
