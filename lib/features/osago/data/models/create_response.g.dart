// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentUrlsImpl _$$PaymentUrlsImplFromJson(Map<String, dynamic> json) =>
    _$PaymentUrlsImpl(
      click: json['click'] as String?,
      payme: json['payme'] as String?,
    );

Map<String, dynamic> _$$PaymentUrlsImplToJson(_$PaymentUrlsImpl instance) =>
    <String, dynamic>{
      'click': instance.click,
      'payme': instance.payme,
    };

_$CreateResponseImpl _$$CreateResponseImplFromJson(Map<String, dynamic> json) =>
    _$CreateResponseImpl(
      sessionId: json['session_id'] as String,
      policyNumber: json['policy_number'] as String?,
      paymentUrl: json['payment_url'] as String?,
      pay: json['pay'] == null
          ? null
          : PaymentUrls.fromJson(json['pay'] as Map<String, dynamic>),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$$CreateResponseImplToJson(
        _$CreateResponseImpl instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'policy_number': instance.policyNumber,
      'payment_url': instance.paymentUrl,
      'pay': instance.pay,
      'amount': instance.amount,
      'currency': instance.currency,
    };
