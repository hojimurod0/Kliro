import 'package:equatable/equatable.dart';

class Hotel extends Equatable {
  const Hotel({
    required this.id,
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
  });

  final String id;
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

  Hotel copyWith({
    String? id,
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
  }) {
    return Hotel(
      id: id ?? this.id,
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
    );
  }

  @override
  List<Object?> get props => [
        id,
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
      ];
}

