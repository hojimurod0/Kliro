// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPaymentRequest _$CheckPaymentRequestFromJson(Map<String, dynamic> json) =>
    CheckPaymentRequest(
      anketaId: (json['anketa_id'] as num).toInt(),
      lan: json['lan'] as String,
    );

Map<String, dynamic> _$CheckPaymentRequestToJson(
        CheckPaymentRequest instance) =>
    <String, dynamic>{
      'anketa_id': instance.anketaId,
      'lan': instance.lan,
    };
