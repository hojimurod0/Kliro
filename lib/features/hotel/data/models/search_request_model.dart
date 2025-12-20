import '../../domain/entities/hotel_filter.dart';

class SearchRequestModel {
  const SearchRequestModel({
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

  factory SearchRequestModel.fromFilter(HotelFilter filter) {
    return SearchRequestModel(
      city: filter.city,
      checkInDate: filter.checkInDate,
      checkOutDate: filter.checkOutDate,
      guests: filter.guests,
      rooms: filter.rooms,
      maxPrice: filter.maxPrice,
      minPrice: filter.minPrice,
      rating: filter.rating,
      amenities: filter.amenities,
      sortBy: filter.sortBy,
      sortDirection: filter.sortDirection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (city != null) 'city': city,
      if (checkInDate != null) 'check_in_date': checkInDate!.toIso8601String(),
      if (checkOutDate != null) 'check_out_date': checkOutDate!.toIso8601String(),
      'guests': guests,
      'rooms': rooms,
      if (maxPrice != null) 'max_price': maxPrice,
      if (minPrice != null) 'min_price': minPrice,
      if (rating != null) 'rating': rating,
      if (amenities != null) 'amenities': amenities,
      if (sortBy != null) 'sort_by': sortBy,
      if (sortDirection != null) 'sort_direction': sortDirection,
    };
  }
}

