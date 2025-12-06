// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentLinkResponseImpl _$$PaymentLinkResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentLinkResponseImpl(
      paymentUrl: json['payment_url'] as String,
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$PaymentLinkResponseImplToJson(
        _$PaymentLinkResponseImpl instance) =>
    <String, dynamic>{
      'payment_url': instance.paymentUrl,
      'order_id': instance.orderId,
      'amount': instance.amount,
    };
