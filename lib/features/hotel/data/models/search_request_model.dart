import '../../domain/entities/hotel_filter.dart';

/// SearchRequestModel для Hotelios API
/// Формат: {"data": {...}}
class SearchRequestModel {
  const SearchRequestModel({
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
  });

  final int? cityId;
  final List<int>? hotelIds;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final List<Occupancy>? occupancies;
  final String currency;
  final String nationality;
  final String residence;
  final bool isResident;
  final List<int>? hotelTypes;
  final List<int>? stars;
  final List<int>? facilities;
  final List<int>? equipments;
  final String? cancellationType;
  final List<String>? mealPlans;
  final double? minPrice;
  final double? maxPrice;
  final int? minStars;
  final int? maxStars;

  factory SearchRequestModel.fromFilter(HotelFilter filter) {
    // Legacy support: agar city string bo'lsa, uni city_id ga o'girish kerak
    // Lekin hozircha city_id ni to'g'ridan-to'g'ri ishlatamiz
    int? cityId = filter.cityId;
    
    // Legacy: agar city string bo'lsa va cityId yo'q bo'lsa
    // Bu yerda city name dan city_id ni topish kerak, lekin hozircha null qoldiramiz
    
    // Occupancies ni tayyorlash
    List<Occupancy>? occupancies = filter.occupancies;
    if (occupancies == null && filter.guests > 0) {
      // Legacy support: guests dan occupancies yaratish
      occupancies = [
        Occupancy(
          adults: filter.guests,
          childrenAges: [],
        ),
      ];
    }

    return SearchRequestModel(
      cityId: cityId,
      hotelIds: filter.hotelIds,
      checkInDate: filter.checkInDate,
      checkOutDate: filter.checkOutDate,
      occupancies: occupancies,
      currency: filter.currency,
      nationality: filter.nationality,
      residence: filter.residence,
      isResident: filter.isResident,
      hotelTypes: filter.hotelTypes,
      stars: filter.stars,
      facilities: filter.facilities,
      equipments: filter.equipments,
      cancellationType: filter.cancellationType,
      mealPlans: filter.mealPlans,
      minPrice: filter.minPrice,
      maxPrice: filter.maxPrice,
      minStars: filter.minStars,
      maxStars: filter.maxStars,
    );
  }

  /// API formatiga mos JSON - {"data": {...}}
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    // Обязательные параметры
    if (cityId != null) {
      data['city_id'] = cityId;
    } else if (hotelIds != null && hotelIds!.isNotEmpty) {
      data['hotel_ids'] = hotelIds;
    }

    if (checkInDate != null) {
      // Формат: "2025/11/25 14:00"
      final dateStr = '${checkInDate!.year}/${checkInDate!.month.toString().padLeft(2, '0')}/${checkInDate!.day.toString().padLeft(2, '0')} 14:00';
      data['check_in'] = dateStr;
    }

    if (checkOutDate != null) {
      // Формат: "2025/11/27 12:00"
      final dateStr = '${checkOutDate!.year}/${checkOutDate!.month.toString().padLeft(2, '0')}/${checkOutDate!.day.toString().padLeft(2, '0')} 12:00';
      data['check_out'] = dateStr;
    }

    if (occupancies != null && occupancies!.isNotEmpty) {
      data['occupancies'] = occupancies!.map((o) => o.toJson()).toList();
    }

    data['currency'] = currency;
    data['nationality'] = nationality;
    data['residence'] = residence;
    data['is_resident'] = isResident;

    // Опциональные фильтры
    if (hotelTypes != null && hotelTypes!.isNotEmpty) {
      data['hotel_types'] = hotelTypes;
    }

    if (stars != null && stars!.isNotEmpty) {
      data['stars'] = stars;
    }

    if (facilities != null && facilities!.isNotEmpty) {
      data['facilities'] = facilities;
    }

    if (equipments != null && equipments!.isNotEmpty) {
      data['equipments'] = equipments;
    }

    if (cancellationType != null) {
      data['cancellation_type'] = cancellationType;
    }

    if (mealPlans != null && mealPlans!.isNotEmpty) {
      data['meal_plans'] = mealPlans;
    }

    if (minPrice != null) {
      data['price_min'] = minPrice!.toInt();
    }

    if (maxPrice != null) {
      data['price_max'] = maxPrice!.toInt();
    }

    if (minStars != null) {
      data['min_stars'] = minStars;
    }

    if (maxStars != null) {
      data['max_stars'] = maxStars;
    }

    return {'data': data};
  }
}

