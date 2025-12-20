import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_model.g.dart';

@JsonSerializable()
class HealthModel extends Equatable {
  final String? status;
  final String? version;
  final Map<String, dynamic>? services;
  @JsonKey(name: 'uptime')
  final int? uptimeSeconds;

  const HealthModel({
    this.status,
    this.version,
    this.services,
    this.uptimeSeconds,
  });

  factory HealthModel.fromJson(Map<String, dynamic> json) =>
      _$HealthModelFromJson(json);

  Map<String, dynamic> toJson() => _$HealthModelToJson(this);

  @override
  List<Object?> get props => [status, version, services, uptimeSeconds];
}

