import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'reference_data.dart';

part 'hotel.g.dart';

/// Hotel option - вариант бронирования
/// Note: JSON serialization is included here because HotelOption is used directly in generated code
@JsonSerializable()
class HotelOption extends Equatable {
  const HotelOption({
    required this.optionRefId,
    this.roomTypeId,
    this.ratePlanId,
    this.price,
    this.currency,
    this.priceBreakdown,
    this.cancellationPolicy,
    this.includedMealOptions,
    this.discount,
  });

  factory HotelOption.fromJson(Map<String, dynamic> json) =>
      _$HotelOptionFromJson(json);

  Map<String, dynamic> toJson() => _$HotelOptionToJson(this);

  final String optionRefId;
  final int? roomTypeId;
  final int? ratePlanId;
  final double? price;
  final String? currency;
  final Map<String, dynamic>? priceBreakdown;
  final Map<String, dynamic>? cancellationPolicy;
  final List<String>? includedMealOptions;
  final int? discount;

  @override
  List<Object?> get props => [
        optionRefId,
        roomTypeId,
        ratePlanId,
        price,
        currency,
        priceBreakdown,
        cancellationPolicy,
        includedMealOptions,
        discount,
      ];
}

class Hotel extends Equatable {
  const Hotel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.city,
    required this.address,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    this.price,
    this.rating,
    this.imageUrl,
    this.description,
    this.amenities,
    this.options,
    this.stars,
    this.discount,
    this.photos,
  });

  /// String ID (legacy support)
  final String id;
  
  /// Integer hotel_id из API
  final int hotelId;
  
  final String name;
  final String city;
  final String address;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final double? price;
  final double? rating;
  final String? imageUrl;
  final String? description;
  final List<String>? amenities;
  
  /// Варианты бронирования
  final List<HotelOption>? options;
  
  /// Количество звезд
  final int? stars;

  /// Chegirma foizi (masalan, 30)
  final int? discount;

  /// Фотографии отеля
  final List<HotelPhoto>? photos;

  Hotel copyWith({
    String? id,
    int? hotelId,
    String? name,
    String? city,
    String? address,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    double? price,
    double? rating,
    String? imageUrl,
    String? description,
    List<String>? amenities,
    List<HotelOption>? options,
    int? stars,
    int? discount,
    List<HotelPhoto>? photos,
  }) {
    return Hotel(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      options: options ?? this.options,
      stars: stars ?? this.stars,
      discount: discount ?? this.discount,
      photos: photos ?? this.photos,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hotelId,
        name,
        city,
        address,
        checkInDate,
        checkOutDate,
        guests,
        price,
        rating,
        imageUrl,
        description,
        amenities,
        options,
        stars,
        discount,
        photos,
      ];
}

