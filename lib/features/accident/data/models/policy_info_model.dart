import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'policy_info_model.g.dart';

@JsonSerializable()
class PolicyInfoModel extends Equatable {
  final String? policyNumber;
  final String? issueDate;
  final String? expiryDate;

  const PolicyInfoModel({
    this.policyNumber,
    this.issueDate,
    this.expiryDate,
  });

  factory PolicyInfoModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyInfoModelToJson(this);

  @override
  List<Object?> get props => [policyNumber, issueDate, expiryDate];
}

