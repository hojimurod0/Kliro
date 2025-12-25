import 'package:equatable/equatable.dart';

/// Country Entity
class Country extends Equatable {
  const Country({
    required this.id,
    required this.name,
    this.names,
    this.code,
  });

  final int id;
  final String name;
  final Map<String, String>? names; // Multi-language names
  final String? code; // Country code (UZ, US, etc.)

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, code];
}

/// Region Entity
class Region extends Equatable {
  const Region({
    required this.id,
    required this.name,
    this.names,
    this.countryId,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final int? countryId;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, countryId];
}

/// Hotel Type Entity
class HotelType extends Equatable {
  const HotelType({
    required this.id,
    required this.name,
    this.names,
  });

  final int id;
  final String name;
  final Map<String, String>? names;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names];
}

/// Facility Entity
class Facility extends Equatable {
  const Facility({
    required this.id,
    required this.name,
    this.names,
    this.icon,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final String? icon; // Icon name or URL

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, icon];
}

/// Equipment Entity
class Equipment extends Equatable {
  const Equipment({
    required this.id,
    required this.name,
    this.names,
    this.icon,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final String? icon;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, icon];
}

/// Currency Entity
class Currency extends Equatable {
  const Currency({
    required this.code,
    required this.name,
    this.symbol,
    this.rate,
  });

  final String code; // USD, UZS, EUR
  final String name;
  final String? symbol; // $, so'm, €
  final double? rate; // Exchange rate

  @override
  List<Object?> get props => [code, name, symbol, rate];
}

/// Star Entity
class Star extends Equatable {
  const Star({
    required this.value,
    this.name,
  });

  final int value; // 1-5
  final String? name;

  @override
  List<Object?> get props => [value, name];
}

/// Hotel Photo Entity
class HotelPhoto extends Equatable {
  const HotelPhoto({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.description,
    this.category,
  });

  final int id;
  final String url;
  final String? thumbnailUrl;
  final String? description;
  final String? category; // exterior, interior, room, etc.

  @override
  List<Object?> get props => [id, url, thumbnailUrl, description, category];
}

/// Room Type Entity
class RoomType extends Equatable {
  const RoomType({
    required this.id,
    required this.name,
    this.names,
    this.hotelId,
    this.maxOccupancy,
    this.description,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final int? hotelId;
  final int? maxOccupancy; // Максимальная вместимость
  final String? description;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, hotelId, maxOccupancy, description];
}

/// Price Range Entity
class PriceRange extends Equatable {
  const PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    this.priceRanges,
  });

  final double minPrice;
  final double maxPrice;
  final String currency;
  final List<PriceRangeItem>? priceRanges;

  @override
  List<Object?> get props => [minPrice, maxPrice, currency, priceRanges];
}

/// Price Range Item
class PriceRangeItem extends Equatable {
  const PriceRangeItem({
    required this.min,
    required this.max,
    this.label,
  });

  final double min;
  final double max;
  final String? label;

  @override
  List<Object?> get props => [min, max, label];
}

/// Nearby Place Type Entity
class NearbyPlaceType extends Equatable {
  const NearbyPlaceType({
    required this.id,
    required this.name,
    this.names,
    this.icon,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final String? icon;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, icon];
}

/// Nearby Place Entity
class NearbyPlace extends Equatable {
  const NearbyPlace({
    required this.id,
    required this.name,
    this.names,
    this.hotelId,
    this.typeId,
    this.distance,
    this.coordinates,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final int? hotelId;
  final int? typeId; // ID типа места
  final double? distance; // Расстояние в метрах
  final Map<String, double>? coordinates; // lat, lng

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, hotelId, typeId, distance, coordinates];
}

/// Service In Room Entity
class ServiceInRoom extends Equatable {
  const ServiceInRoom({
    required this.id,
    required this.name,
    this.names,
    this.icon,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final String? icon;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, icon];
}

/// Bed Type Entity
class BedType extends Equatable {
  const BedType({
    required this.id,
    required this.name,
    this.names,
    this.icon,
  });

  final int id;
  final String name;
  final Map<String, String>? names;
  final String? icon;

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, icon];
}

