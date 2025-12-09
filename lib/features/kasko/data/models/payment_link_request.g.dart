// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_link_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentLinkRequestImpl _$$PaymentLinkRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentLinkRequestImpl(
      orderId: json['order_id'] as String,
      contractId: json['contract_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      returnUrl: json['return_url'] as String,
      callbackUrl: json['callback_url'] as String,
    );

Map<String, dynamic> _$$PaymentLinkRequestImplToJson(
        _$PaymentLinkRequestImpl instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'contract_id': instance.contractId,
      'amount': instance.amount,
      'return_url': instance.returnUrl,
      'callback_url': instance.callbackUrl,
    };
