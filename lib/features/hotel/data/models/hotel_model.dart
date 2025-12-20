import '../../domain/entities/hotel.dart';

class HotelModel extends Hotel {
  const HotelModel({
    required super.id,
    required super.name,
    required super.city,
    required super.address,
    required super.checkInDate,
    required super.checkOutDate,
    required super.guests,
    super.price,
    super.rating,
    super.imageUrl,
    super.description,
    super.amenities,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      checkInDate: json['check_in_date'] != null
          ? DateTime.parse(json['check_in_date'] as String)
          : json['checkInDate'] != null
          ? DateTime.parse(json['checkInDate'] as String)
          : DateTime.now(),
      checkOutDate: json['check_out_date'] != null
          ? DateTime.parse(json['check_out_date'] as String)
          : json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'] as String)
          : DateTime.now(),
      guests: json['guests'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      description: json['description'] as String?,
      amenities: json['amenities'] != null
          ? (json['amenities'] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'guests': guests,
      if (price != null) 'price': price,
      if (rating != null) 'rating': rating,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (amenities != null) 'amenities': amenities,
    };
  }
}
