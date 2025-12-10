import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'region_model.g.dart';

@JsonSerializable()
class RegionModel extends Equatable {
  final int id;
  final String name;

  const RegionModel({
    required this.id,
    required this.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegionModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}

