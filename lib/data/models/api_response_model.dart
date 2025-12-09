import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

/// Универсальная модель ответа API
@JsonSerializable(genericArgumentFactories: true)
class ApiResponseModel<T> {
  final T? result;
  final T? data;
  final String? message;
  final bool? success;

  ApiResponseModel({
    this.result,
    this.data,
    this.message,
    this.success,
  });

  /// Получить данные (приоритет: result > data)
  T? get responseData => result ?? data;

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseModelToJson(this, toJsonT);
}

