// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occupancy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OccupancyModel _$OccupancyModelFromJson(Map<String, dynamic> json) =>
    OccupancyModel(
      adults: (json['adults'] as num).toInt(),
      childrenAges: (json['childrenAges'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OccupancyModelToJson(OccupancyModel instance) =>
    <String, dynamic>{
      'adults': instance.adults,
      'childrenAges': instance.childrenAges,
    };
