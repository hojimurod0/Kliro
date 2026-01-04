import 'package:equatable/equatable.dart';

/// Occupancy - размещение в номере
class Occupancy extends Equatable {
  const Occupancy({
    required this.adults,
    this.childrenAges = const [],
  });

  final int adults;
  final List<int> childrenAges;

  @override
  List<Object?> get props => [adults, childrenAges];

  Map<String, dynamic> toJson() {
    return {
      'adults': adults,
      'children_ages': childrenAges,
    };
  }
}

class HotelFilter extends Equatable {
  const HotelFilter({
    this.cityId,
    this.hotelIds,
    this.checkInDate,
    this.checkOutDate,
    this.occupancies,
    this.currency = 'uzs',
    this.nationality = 'uz',
    this.residence = 'uz',
    this.isResident = false,
    this.hotelTypes,
    this.stars,
    this.facilities,
    this.equipments,
    this.cancellationType,
    this.mealPlans,
    this.minPrice,
    this.maxPrice,
    this.minStars,
    this.maxStars,
    // Legacy support
    this.city,
    this.guests = 1,
    this.rooms = 1,
    this.rating,
    this.amenities,
  });

  /// ID города (обязательно, если не указан hotelIds)
  final int? cityId;
  
  /// Массив ID отелей (альтернатива cityId)
  final List<int>? hotelIds;
  
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  
  /// Массив размещений (occupancies)
  final List<Occupancy>? occupancies;
  
  /// Валюта (uzs, usd, eur)
  final String currency;
  
  /// Национальность (uz, us, ru)
  final String nationality;
  
  /// Резидентство (uz, us, ru)
  final String residence;
  
  /// Цены для резидентов Узбекистана
  final bool isResident;
  
  /// Типы отелей [1,2,3,4,5,10,11]
  final List<int>? hotelTypes;
  
  /// Звездность [1,2,3,4,5]
  final List<int>? stars;
  
  /// Удобства (facilities)
  final List<int>? facilities;
  
  /// Оборудование (equipments)
  final List<int>? equipments;
  
  /// Тип отмены: 'rf' (возвратный), 'nrf' (невозвратный), 'all'
  final String? cancellationType;
  
  /// Планы питания: ["RO", "BB", "HB", "FB", "AI", etc.]
  final List<String>? mealPlans;
  
  final double? minPrice;
  final double? maxPrice;
  final int? minStars;
  final int? maxStars;

  // Legacy fields (для обратной совместимости)
  final String? city;
  final int guests;
  final int rooms;
  final double? rating;
  final List<String>? amenities;

  static const HotelFilter empty = HotelFilter();

  HotelFilter copyWith({
    int? cityId,
    List<int>? hotelIds,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    List<Occupancy>? occupancies,
    String? currency,
    String? nationality,
    String? residence,
    bool? isResident,
    List<int>? hotelTypes,
    List<int>? stars,
    List<int>? facilities,
    List<int>? equipments,
    String? cancellationType,
    List<String>? mealPlans,
    double? minPrice,
    double? maxPrice,
    int? minStars,
    int? maxStars,
    String? city,
    int? guests,
    int? rooms,
    double? rating,
    List<String>? amenities,
  }) {
    return HotelFilter(
      cityId: cityId ?? this.cityId,
      hotelIds: hotelIds ?? this.hotelIds,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      occupancies: occupancies ?? this.occupancies,
      currency: currency ?? this.currency,
      nationality: nationality ?? this.nationality,
      residence: residence ?? this.residence,
      isResident: isResident ?? this.isResident,
      hotelTypes: hotelTypes ?? this.hotelTypes,
      stars: stars ?? this.stars,
      facilities: facilities ?? this.facilities,
      equipments: equipments ?? this.equipments,
      cancellationType: cancellationType ?? this.cancellationType,
      mealPlans: mealPlans ?? this.mealPlans,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minStars: minStars ?? this.minStars,
      maxStars: maxStars ?? this.maxStars,
      city: city ?? this.city,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      rating: rating ?? this.rating,
      amenities: amenities ?? this.amenities,
    );
  }

  @override
  List<Object?> get props => [
        cityId,
        hotelIds,
        checkInDate,
        checkOutDate,
        occupancies,
        currency,
        nationality,
        residence,
        isResident,
        hotelTypes,
        stars,
        facilities,
        equipments,
        cancellationType,
        mealPlans,
        minPrice,
        maxPrice,
        minStars,
        maxStars,
        city,
        guests,
        rooms,
        rating,
        amenities,
      ];
}

