import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'save_policy_response_model.g.dart';

/// Модель ответа сохранения полиса
@JsonSerializable()
class SavePolicyResponseModel extends Equatable {
  final String? policyId;
  final String? policyNumber;
  final Map<String, dynamic>? data;

  const SavePolicyResponseModel({
    this.policyId,
    this.policyNumber,
    this.data,
  });

  factory SavePolicyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SavePolicyResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SavePolicyResponseModelToJson(this);

  @override
  List<Object?> get props => [policyId, policyNumber, data];
}

