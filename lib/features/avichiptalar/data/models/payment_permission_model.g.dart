// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentPermissionModel _$PaymentPermissionModelFromJson(
        Map<String, dynamic> json) =>
    PaymentPermissionModel(
      allowed: json['allowed'] as bool?,
      reason: json['reason'] as String?,
      canPay: json['can_pay'] as bool?,
      paymentAllowed: json['payment_allowed'] as bool?,
    );

Map<String, dynamic> _$PaymentPermissionModelToJson(
        PaymentPermissionModel instance) =>
    <String, dynamic>{
      'allowed': instance.allowed,
      'reason': instance.reason,
      'can_pay': instance.canPay,
      'payment_allowed': instance.paymentAllowed,
    };
