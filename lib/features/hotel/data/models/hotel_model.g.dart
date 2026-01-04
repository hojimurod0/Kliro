// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotelModel _$HotelModelFromJson(Map<String, dynamic> json) => HotelModel(
      id: json['id'] as String,
      hotelId: (json['hotelId'] as num).toInt(),
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      guests: (json['guests'] as num).toInt(),
      price: (json['price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => HotelOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      stars: (json['stars'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HotelModelToJson(HotelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hotelId': instance.hotelId,
      'name': instance.name,
      'city': instance.city,
      'address': instance.address,
      'checkInDate': instance.checkInDate.toIso8601String(),
      'checkOutDate': instance.checkOutDate.toIso8601String(),
      'guests': instance.guests,
      'price': instance.price,
      'rating': instance.rating,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'amenities': instance.amenities,
      'options': instance.options,
      'stars': instance.stars,
    };
