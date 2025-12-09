// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseModel<T> _$ApiResponseModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponseModel<T>(
      result: _$nullableGenericFromJson(json['result'], fromJsonT),
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      message: json['message'] as String?,
      success: json['success'] as bool?,
    );

Map<String, dynamic> _$ApiResponseModelToJson<T>(
  ApiResponseModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'result': _$nullableGenericToJson(instance.result, toJsonT),
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'message': instance.message,
      'success': instance.success,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
