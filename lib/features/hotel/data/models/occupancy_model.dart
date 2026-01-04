import 'package:json_annotation/json_annotation.dart';

part 'occupancy_model.g.dart';

/// Occupancy - размещение в номере
@JsonSerializable()
class OccupancyModel {
  const OccupancyModel({
    required this.adults,
    this.childrenAges = const [],
  });

  final int adults;
  final List<int> childrenAges;

  factory OccupancyModel.fromJson(Map<String, dynamic> json) => _$OccupancyModelFromJson(json);

  Map<String, dynamic> toJson() => _$OccupancyModelToJson(this);
}
