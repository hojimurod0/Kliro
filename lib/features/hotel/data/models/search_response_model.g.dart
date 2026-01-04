// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseModel _$SearchResponseModelFromJson(Map<String, dynamic> json) =>
    SearchResponseModel(
      hotels: (json['hotels'] as List<dynamic>)
          .map((e) => HotelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$SearchResponseModelToJson(
        SearchResponseModel instance) =>
    <String, dynamic>{
      'hotels': instance.hotels,
      'total': instance.total,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };
