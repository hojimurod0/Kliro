import 'package:equatable/equatable.dart';

class HotelFilter extends Equatable {
  const HotelFilter({
    this.city,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
    this.rooms = 1,
    this.maxPrice,
    this.minPrice,
    this.rating,
    this.amenities,
    this.sortBy,
    this.sortDirection,
  });

  final String? city;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final int rooms;
  final double? maxPrice;
  final double? minPrice;
  final double? rating;
  final List<String>? amenities;
  final String? sortBy;
  final String? sortDirection;

  static const HotelFilter empty = HotelFilter();

  HotelFilter copyWith({
    String? city,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    int? rooms,
    double? maxPrice,
    double? minPrice,
    double? rating,
    List<String>? amenities,
    String? sortBy,
    String? sortDirection,
  }) {
    return HotelFilter(
      city: city ?? this.city,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      rating: rating ?? this.rating,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  @override
  List<Object?> get props => [
        city,
        checkInDate,
        checkOutDate,
        guests,
        rooms,
        maxPrice,
        minPrice,
        rating,
        amenities,
        sortBy,
        sortDirection,
      ];
}

