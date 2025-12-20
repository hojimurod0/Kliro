// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_amounts_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefundAmountsModel _$RefundAmountsModelFromJson(Map<String, dynamic> json) =>
    RefundAmountsModel(
      refundAmount: json['refund_amount'] as String?,
      penaltyAmount: json['penalty_amount'] as String?,
      currency: json['currency'] as String?,
      totalRefund: json['total_refund'] as String?,
    );

Map<String, dynamic> _$RefundAmountsModelToJson(RefundAmountsModel instance) =>
    <String, dynamic>{
      'refund_amount': instance.refundAmount,
      'penalty_amount': instance.penaltyAmount,
      'currency': instance.currency,
      'total_refund': instance.totalRefund,
    };
