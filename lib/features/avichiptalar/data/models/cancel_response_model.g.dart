// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelResponseModel _$CancelResponseModelFromJson(Map<String, dynamic> json) =>
    CancelResponseModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      booking: json['booking'] == null
          ? null
          : BookingModel.fromJson(json['booking'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CancelResponseModelToJson(
        CancelResponseModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'booking': instance.booking,
    };
