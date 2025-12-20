import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_class_model.g.dart';

@JsonSerializable()
class ServiceClassModel extends Equatable {
  final String? code;
  final String? name;
  final String? description;
  @JsonKey(name: 'name_intl')
  final Map<String, String>? nameIntl;

  const ServiceClassModel({
    this.code,
    this.name,
    this.description,
    this.nameIntl,
  });

  factory ServiceClassModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceClassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceClassModelToJson(this);

  @override
  List<Object?> get props => [code, name, description, nameIntl];
}

