// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRequestModel _$SearchRequestModelFromJson(Map<String, dynamic> json) =>
    SearchRequestModel(
      cityId: (json['cityId'] as num?)?.toInt(),
      hotelIds: (json['hotelIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      checkInDate: json['checkInDate'] == null
          ? null
          : DateTime.parse(json['checkInDate'] as String),
      checkOutDate: json['checkOutDate'] == null
          ? null
          : DateTime.parse(json['checkOutDate'] as String),
      occupancies: (json['occupancies'] as List<dynamic>?)
          ?.map((e) => OccupancyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currency: json['currency'] as String? ?? 'uzs',
      nationality: json['nationality'] as String? ?? 'uz',
      residence: json['residence'] as String? ?? 'uz',
      isResident: json['isResident'] as bool? ?? false,
      hotelTypes: (json['hotelTypes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      stars: (json['stars'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      equipments: (json['equipments'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      cancellationType: json['cancellationType'] as String?,
      mealPlans: (json['mealPlans'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minStars: (json['minStars'] as num?)?.toInt(),
      maxStars: (json['maxStars'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SearchRequestModelToJson(SearchRequestModel instance) =>
    <String, dynamic>{
      'cityId': instance.cityId,
      'hotelIds': instance.hotelIds,
      'checkInDate': instance.checkInDate?.toIso8601String(),
      'checkOutDate': instance.checkOutDate?.toIso8601String(),
      'occupancies': instance.occupancies,
      'currency': instance.currency,
      'nationality': instance.nationality,
      'residence': instance.residence,
      'isResident': instance.isResident,
      'hotelTypes': instance.hotelTypes,
      'stars': instance.stars,
      'facilities': instance.facilities,
      'equipments': instance.equipments,
      'cancellationType': instance.cancellationType,
      'mealPlans': instance.mealPlans,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'minStars': instance.minStars,
      'maxStars': instance.maxStars,
    };
