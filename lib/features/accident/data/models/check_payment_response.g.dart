// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPaymentResponse _$CheckPaymentResponseFromJson(
        Map<String, dynamic> json) =>
    CheckPaymentResponse(
      statusPayment: (json['status_payment'] as num).toInt(),
      statusPolicy: (json['status_policy'] as num).toInt(),
      paymentType: json['payment_type'] as String?,
      policyInfo: json['policy_info'] == null
          ? null
          : PolicyInfoModel.fromJson(
              json['policy_info'] as Map<String, dynamic>),
      downloadUrls: json['download_urls'] == null
          ? null
          : DownloadUrlsModel.fromJson(
              json['download_urls'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheckPaymentResponseToJson(
        CheckPaymentResponse instance) =>
    <String, dynamic>{
      'status_payment': instance.statusPayment,
      'status_policy': instance.statusPolicy,
      'payment_type': instance.paymentType,
      'policy_info': instance.policyInfo,
      'download_urls': instance.downloadUrls,
    };
