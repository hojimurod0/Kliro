// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckPaymentResponseImpl _$$CheckPaymentResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CheckPaymentResponseImpl(
      orderId: json['order_id'] as String,
      transactionId: json['transaction_id'] as String?,
      status: json['status'] as String,
      isPaid: json['is_paid'] as bool? ?? false,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CheckPaymentResponseImplToJson(
        _$CheckPaymentResponseImpl instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'transaction_id': instance.transactionId,
      'status': instance.status,
      'is_paid': instance.isPaid,
      'amount': instance.amount,
    };
