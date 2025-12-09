// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentLinkResponseImpl _$$PaymentLinkResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentLinkResponseImpl(
      clickUrl: json['click'] as String?,
      paymeUrl: json['payme'] as String?,
      url: json['url'] as String?,
      paymeUrlOld: json['payme_url'] as String?,
      paymentUrl: json['payment_url'] as String?,
      orderId: _intToString(json['order_id']),
      contractId: _intToString(json['contract_id']),
      amount: _toDouble(json['amount']),
      amountUzs: _toDouble(json['amount_uzs']),
    );

Map<String, dynamic> _$$PaymentLinkResponseImplToJson(
        _$PaymentLinkResponseImpl instance) =>
    <String, dynamic>{
      'click': instance.clickUrl,
      'payme': instance.paymeUrl,
      'url': instance.url,
      'payme_url': instance.paymeUrlOld,
      'payment_url': instance.paymentUrl,
      'order_id': instance.orderId,
      'contract_id': instance.contractId,
      'amount': instance.amount,
      'amount_uzs': instance.amountUzs,
    };
