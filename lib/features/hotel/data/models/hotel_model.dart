import '../../domain/entities/hotel.dart';

class HotelModel extends Hotel {
  const HotelModel({
    required super.id,
    required super.hotelId,
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
    super.options,
    super.stars,
  });

  /// Parse Hotelios API response format
  /// Format: {"hotel_id": 130, "options": [...]}
  factory HotelModel.fromApiJson(
    Map<String, dynamic> json, {
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int guests = 1,
  }) {
    final hotelId = json['hotel_id'] as int? ?? 0;
    final optionsData = json['options'] as List<dynamic>? ?? [];
    
    // Parse options
    final options = optionsData
        .map((opt) {
          try {
            final optMap = opt as Map<String, dynamic>;
            return HotelOption(
              optionRefId: optMap['option_ref_id'] as String? ?? '',
              roomTypeId: optMap['room_type_id'] as int?,
              ratePlanId: optMap['rate_plan_id'] as int?,
              price: (optMap['price'] as num?)?.toDouble(),
              currency: optMap['currency'] as String?,
              priceBreakdown: optMap['price_breakdown'] as Map<String, dynamic>?,
              cancellationPolicy: optMap['cancellation_policy'] as Map<String, dynamic>?,
              includedMealOptions: optMap['included_meal_options'] != null
                  ? (optMap['included_meal_options'] as List<dynamic>)
                        .map((e) => e.toString())
                        .toList()
                  : null,
            );
          } catch (e) {
            return null;
          }
        })
        .whereType<HotelOption>()
        .toList();

    // Eng arzon option'ni tanlash (yoki birinchi option)
    final bestOption = options.isNotEmpty
        ? options.reduce((a, b) => (a.price ?? double.infinity) < (b.price ?? double.infinity) ? a : b)
        : null;

    // Hotel ma'lumotlari (agar mavjud bo'lsa)
    final hotelInfo = json['hotel_info'] as Map<String, dynamic>?;
    final name = hotelInfo?['name'] as String? ?? 
                json['name'] as String? ?? 
                'Hotel #$hotelId';
    final address = hotelInfo?['address'] as String? ?? 
                   json['address'] as String? ?? 
                   '';
    final city = hotelInfo?['city'] as String? ?? 
                json['city'] as String? ?? 
                '';
    final stars = hotelInfo?['stars'] as int? ?? 
                 json['stars'] as int?;
    final imageUrl = hotelInfo?['image_url'] as String? ?? 
                    json['image_url'] as String? ??
                    json['imageUrl'] as String?;
    final description = hotelInfo?['description'] as String? ?? 
                       json['description'] as String?;
    final amenities = hotelInfo?['amenities'] != null
        ? (hotelInfo!['amenities'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
        : json['amenities'] != null
        ? (json['amenities'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
        : null;

    return HotelModel(
      id: hotelId.toString(),
      hotelId: hotelId,
      name: name,
      city: city,
      address: address,
      checkInDate: checkInDate ?? DateTime.now(),
      checkOutDate: checkOutDate ?? DateTime.now().add(const Duration(days: 1)),
      guests: guests,
      price: bestOption?.price,
      rating: stars?.toDouble(), // Stars ni rating sifatida ishlatamiz
      imageUrl: imageUrl,
      description: description,
      amenities: amenities,
      options: options.isNotEmpty ? options : null,
      stars: stars,
    );
  }

  /// Legacy format support
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final hotelId = json['hotel_id'] as int? ?? 
                   (json['id'] != null ? int.tryParse(json['id'].toString()) : null) ?? 
                   0;
    
    return HotelModel(
      id: json['id'] as String? ?? hotelId.toString(),
      hotelId: hotelId,
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
      stars: json['stars'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
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
      if (stars != null) 'stars': stars,
    };
  }
}
