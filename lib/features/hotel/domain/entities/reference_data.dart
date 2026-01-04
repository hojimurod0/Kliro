import 'package:equatable/equatable.dart';

/// Helper function to get locale variants for lookup
/// Returns list of possible locale keys to try in order
List<String> _getLocaleVariants(String locale) {
  final variants = <String>[];
  final localeLower = locale.toLowerCase();
  
  // Add exact match first (preserve original case)
  variants.add(locale);
  
  // Handle Cyrillic Uzbek - try all possible formats
  // context.locale.toString() returns 'uz_CYR' (with underscore and uppercase)
  if (localeLower == 'uz_cyr' || localeLower == 'uz-cyr') {
    // Try all possible formats for Cyrillic
    variants.add('uz_CYR');  // Most common in API
    variants.add('uz-CYR');  // Alternative format
    variants.add('uz_cyr');  // Lowercase variant
    variants.add('uz-cyr'); // Lowercase with dash
  }
  
  // Normalize locale (remove country code) - only if not Cyrillic
  if (localeLower != 'uz_cyr' && localeLower != 'uz-cyr') {
    if (locale.contains('-') || locale.contains('_')) {
      final normalized = locale.split(RegExp(r'[-_]')).first.toLowerCase();
      if (normalized != localeLower && normalized.isNotEmpty) {
        variants.add(normalized);
      }
    }
  }
  
  return variants;
}

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
      // Try all locale variants
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      
      // Fallback to common locales
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
    this.isDefault = false,
  });

  final int id;
  final String url;
  final String? thumbnailUrl;
  final String? description;
  final String? category; // exterior, interior, room, etc.
  final bool isDefault; // Is this the default/main photo for the hotel

  @override
  List<Object?> get props => [id, url, thumbnailUrl, description, category, isDefault];
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
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
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names, icon];
}

