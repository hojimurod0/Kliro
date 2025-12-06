// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckPaymentRequestImpl _$$CheckPaymentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CheckPaymentRequestImpl(
      orderId: json['order_id'] as String,
      transactionId: json['transaction_id'] as String,
    );

Map<String, dynamic> _$$CheckPaymentRequestImplToJson(
        _$CheckPaymentRequestImpl instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'transaction_id': instance.transactionId,
    };
