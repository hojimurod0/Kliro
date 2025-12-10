// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_insurance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateInsuranceResponse _$CreateInsuranceResponseFromJson(
        Map<String, dynamic> json) =>
    CreateInsuranceResponse(
      anketaId: (json['anketa_id'] as num).toInt(),
      paymentUrls: PaymentUrlsModel.fromJson(
          json['payment_urls'] as Map<String, dynamic>),
      insurancePremium: (json['insurance_premium'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateInsuranceResponseToJson(
        CreateInsuranceResponse instance) =>
    <String, dynamic>{
      'anketa_id': instance.anketaId,
      'payment_urls': instance.paymentUrls,
      'insurance_premium': instance.insurancePremium,
    };
