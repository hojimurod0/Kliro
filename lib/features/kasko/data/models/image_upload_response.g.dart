// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageUploadResponseImpl _$$ImageUploadResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ImageUploadResponseImpl(
      imageUrl: json['image_url'] as String,
      orderId: json['order_id'] as String,
      imageType: json['image_type'] as String,
    );

Map<String, dynamic> _$$ImageUploadResponseImplToJson(
        _$ImageUploadResponseImpl instance) =>
    <String, dynamic>{
      'image_url': instance.imageUrl,
      'order_id': instance.orderId,
      'image_type': instance.imageType,
    };
