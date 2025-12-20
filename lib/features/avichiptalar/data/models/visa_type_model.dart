import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'visa_type_model.g.dart';

@JsonSerializable()
class VisaTypeModel extends Equatable {
  final String? country;
  final String? type;
  final String? name;
  final String? description;
  @JsonKey(name: 'required')
  final bool? isRequired;

  const VisaTypeModel({
    this.country,
    this.type,
    this.name,
    this.description,
    this.isRequired,
  });

  factory VisaTypeModel.fromJson(Map<String, dynamic> json) =>
      _$VisaTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$VisaTypeModelToJson(this);

  @override
  List<Object?> get props => [country, type, name, description, isRequired];
}

