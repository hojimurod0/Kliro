import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'check_response_model.g.dart';

/// Модель ответа проверки сессии
@JsonSerializable()
class CheckResponseModel extends Equatable {
  final String? status;
  final String? policyId;
  final String? policyNumber;
  final Map<String, dynamic>? data;

  const CheckResponseModel({
    this.status,
    this.policyId,
    this.policyNumber,
    this.data,
  });

  factory CheckResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CheckResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckResponseModelToJson(this);

  @override
  List<Object?> get props => [status, policyId, policyNumber, data];
}

