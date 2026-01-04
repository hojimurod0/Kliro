import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/constants/constants.dart';

import '../../domain/entities/hotel.dart';
import '../../domain/entities/reference_data.dart';

part 'hotel_model.g.dart';

@JsonSerializable()
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
    super.discount,
    super.photos,
  });

  /// Copy with method that returns HotelModel
  HotelModel copyWith({
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
    return HotelModel(
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

  /// Parse Hotelios API response format
  /// Format: {"hotel_id": 130, "options": [...]}
  factory HotelModel.fromApiJson(
    Map<String, dynamic> json, {
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int guests = 1,
  }) {
    // Helper for safe parsing
    int safeInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      if (val is double) return val.toInt();
      return 0;
    }

    double? safeDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    final hotelId = safeInt(json['hotel_id'] ?? json['id']);
    final optionsData = json['options'] as List<dynamic>? ?? [];

    // Debug: Log API response structure
    debugPrint('🔍 HotelModel.fromApiJson: hotelId = $hotelId');
    debugPrint('🔍 HotelModel.fromApiJson: json keys = ${json.keys.toList()}');
    if (json['hotel_info'] != null) {
      debugPrint(
          '🔍 HotelModel.fromApiJson: hotel_info type = ${json['hotel_info'].runtimeType}');
      if (json['hotel_info'] is Map) {
        debugPrint(
            '🔍 HotelModel.fromApiJson: hotel_info keys = ${(json['hotel_info'] as Map).keys.toList()}');
      }
    }

    // Parse options
    final options = optionsData
        .map((opt) {
          try {
            final optMap = opt as Map<String, dynamic>;
            final percent = safeInt(optMap['discount'] ??
                optMap['discount_percent'] ??
                optMap['savings']);
            final originalPrice = safeDouble(optMap['price']);

            // Percentage markup calculation
            // Price = Price + (Price * Percent / 100)
            final newPrice = originalPrice != null && percent > 0
                ? originalPrice + (originalPrice * percent / 100)
                : originalPrice;

            return HotelOption(
              optionRefId: optMap['option_ref_id'] as String? ?? '',
              roomTypeId: safeInt(optMap['room_type_id']),
              ratePlanId: safeInt(optMap['rate_plan_id']),
              price: newPrice,
              currency: optMap['currency'] as String?,
              priceBreakdown:
                  optMap['price_breakdown'] as Map<String, dynamic>?,
              cancellationPolicy:
                  optMap['cancellation_policy'] as Map<String, dynamic>?,
              includedMealOptions: optMap['included_meal_options'] != null
                  ? (optMap['included_meal_options'] as List<dynamic>)
                      .map((e) => e.toString())
                      .toList()
                  : null,
              discount: percent,
            );
          } catch (e) {
            return null;
          }
        })
        .whereType<HotelOption>()
        .toList();

    // Eng arzon option'ni tanlash (yoki birinchi option)
    final bestOption = options.isNotEmpty
        ? options.reduce((a, b) =>
            (a.price ?? double.infinity) < (b.price ?? double.infinity) ? a : b)
        : null;

    // Hotel ma'lumotlari - safe parsing
    Map<String, dynamic>? hotelInfo;
    if (json['hotel_info'] != null) {
      final hotelInfoValue = json['hotel_info'];
      if (hotelInfoValue is Map<String, dynamic>) {
        hotelInfo = hotelInfoValue;
      } else if (hotelInfoValue is List && hotelInfoValue.isNotEmpty) {
        // If hotel_info is a List, try to get first element
        final firstElement = hotelInfoValue[0];
        if (firstElement is Map<String, dynamic>) {
          hotelInfo = firstElement;
        }
      }
    }

    // Name handling - safe parsing
    String name = '';

    // Helper to get string from dynamic
    // Helper to get string from dynamic
    String? getString(dynamic v) {
      if (v is String) return v;
      if (v is num) return v.toString();
      if (v is Map) {
        return v['name']?.toString() ??
            v['uz']?.toString() ??
            v['en']?.toString() ??
            v['ru']?.toString();
      }
      if (v is List && v.isNotEmpty) {
        final first = v[0];
        if (first is Map) {
          return first['name']?.toString() ??
              first['uz']?.toString() ??
              first['en']?.toString() ??
              first['ru']?.toString();
        }
        return first.toString();
      }
      return null;
    }

    // Check 'name' field
    name = getString(hotelInfo?['name']) ?? getString(json['name']) ?? '';

    // Check 'names' map if name is empty
    if (name.isEmpty) {
      dynamic namesData = hotelInfo?['names'] ?? json['names'];
      Map<String, dynamic>? namesMap;

      if (namesData != null) {
        if (namesData is List) {
          namesMap = {};
          for (var item in namesData) {
            if (item is Map) {
              final locale = item['locale']?.toString();
              final value = item['value']?.toString();
              if (locale != null && value != null) {
                namesMap[locale] = value;
              }
            }
          }
          debugPrint('🔍 HotelModel: Parsed names from List: $namesMap');
        } else if (namesData is Map) {
          try {
            namesMap = Map<String, dynamic>.from(namesData);
          } catch (e) {
            debugPrint('⚠️ HotelModel: cast error for names: $e');
            try {
              namesMap = {};
              namesData.forEach((k, v) => namesMap![k.toString()] = v);
            } catch (_) {}
          }
        }
      }

      if (namesMap != null) {
        debugPrint(
            '🔍 HotelModel: Found names map with keys = ${namesMap.keys.toList()}');
        // Try preferred languages
        name = namesMap['uz']?.toString() ??
            namesMap['ru']?.toString() ??
            namesMap['en']?.toString() ??
            '';

        // If still empty, take ANY value
        if (name.isEmpty && namesMap.isNotEmpty) {
          name = namesMap.values.first.toString();
        }
      } else if (namesData != null) {
        debugPrint(
            '⚠️ HotelModel: names field exists but is not a Map! Type: ${namesData.runtimeType}, Value: $namesData');
      }
    }

    if (name.isEmpty) {
      debugPrint(
          '⚠️ HotelModel: Name is empty for hotelId=$hotelId, using fallback');
      name = 'Hotel #$hotelId';
    } else {
      debugPrint('✅ HotelModel: Parsed name = "$name" for hotelId=$hotelId');
    }

    // Safe parsing for address
    String address =
        getString(hotelInfo?['address']) ?? getString(json['address']) ?? '';

    // Safe parsing for city
    String city =
        getString(hotelInfo?['city']) ?? getString(json['city']) ?? '';

    // Infer city from address if missing
    if (city.isEmpty && address.isNotEmpty) {
      // Address format: "Street, City, Country" or "City, Country" or just "City"
      final parts = address
          .split(',')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        // Take the last part if it's likely a city (not too long, not a country name)
        final lastPart = parts.last;
        // Simple heuristic: if last part is short (< 30 chars) and not a known country, use it
        if (lastPart.length < 30 &&
            !lastPart.toLowerCase().contains('uzbekistan') &&
            !lastPart.toLowerCase().contains('o\'zbekiston')) {
          city = lastPart;
        } else if (parts.length >= 2) {
          // Try second to last part
          city = parts[parts.length - 2];
        }
      }
    }
    final stars = safeInt(hotelInfo?['stars'] ?? json['stars']);

    // Safe parsing for imageUrl - check multiple possible keys and formats
    String? imageUrl;

    // Helper function to extract URL from various formats
    String? extractImageUrl(dynamic value) {
      if (value == null) return null;

      String? rawUrl;

      if (value is String && value.isNotEmpty) {
        rawUrl = value;
      } else if (value is List && value.isNotEmpty) {
        final firstItem = value[0];
        if (firstItem is String && firstItem.isNotEmpty) {
          rawUrl = firstItem;
        } else if (firstItem is Map) {
          // Try to extract URL from map - check 'link' field first (as per API)
          rawUrl = extractImageUrl(firstItem['link'] ??
              firstItem['url'] ??
              firstItem['image_url'] ??
              firstItem['photo_url']);
        }
      } else if (value is Map) {
        // Check 'link' field first (as per API response structure)
        rawUrl = extractImageUrl(value['link'] ??
            value['url'] ??
            value['image_url'] ??
            value['photo_url']);
      }

      if (rawUrl == null || rawUrl.isEmpty) return null;

      // Validate and normalize URL format
      // Skip data URIs (base64 images)
      if (rawUrl.startsWith('data:')) return null;

      // Full URL
      if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
        return rawUrl;
      }

      // Protocol-relative URL
      if (rawUrl.startsWith('//')) {
        return 'https:$rawUrl';
      }

      // Relative URL - prepend base URL
      if (rawUrl.startsWith('/')) {
        final baseUrl = ApiConstants.effectiveBaseUrl;
        // Remove trailing slash from baseUrl if present
        final cleanBaseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
        return '$cleanBaseUrl$rawUrl';
      }

      // If it doesn't look like a URL, return null
      if (!rawUrl.contains('.') || rawUrl.contains(' ')) {
        return null;
      }

      // Try to construct URL from what we have
      return rawUrl;
    }

    // Try hotelInfo first
    if (hotelInfo != null) {
      debugPrint(
          '🔍 HotelModel: Checking hotelInfo for image, keys = ${hotelInfo.keys.toList()}');
      // Check all possible image fields - 'link' first (as per API)
      imageUrl = extractImageUrl(hotelInfo['link']) ??
          extractImageUrl(hotelInfo['image_url']) ??
          extractImageUrl(hotelInfo['imageUrl']) ??
          extractImageUrl(hotelInfo['photo_url']) ??
          extractImageUrl(hotelInfo['photos']) ??
          extractImageUrl(hotelInfo['image']) ??
          extractImageUrl(hotelInfo['photo']) ??
          extractImageUrl(hotelInfo['thumbnail']) ??
          extractImageUrl(hotelInfo['thumbnail_url']) ??
          extractImageUrl(hotelInfo['main_image']) ??
          extractImageUrl(hotelInfo['main_photo']);
    }

    // Try json directly if not found
    if (imageUrl == null || imageUrl.isEmpty) {
      debugPrint(
          '🔍 HotelModel: Checking json directly for image, keys = ${json.keys.toList()}');
      // Check all possible image fields in json - 'link' first (as per API)
      imageUrl = extractImageUrl(json['link']) ??
          extractImageUrl(json['image_url']) ??
          extractImageUrl(json['imageUrl']) ??
          extractImageUrl(json['photo_url']) ??
          extractImageUrl(json['photos']) ??
          extractImageUrl(json['image']) ??
          extractImageUrl(json['photo']) ??
          extractImageUrl(json['thumbnail']) ??
          extractImageUrl(json['thumbnail_url']) ??
          extractImageUrl(json['main_image']) ??
          extractImageUrl(json['main_photo']);
    }

    // If still not found, try to find any field that might contain image URL
    if (imageUrl == null || imageUrl.isEmpty) {
      debugPrint('🔍 HotelModel: Searching all fields for image URL...');
      final allData = hotelInfo ?? json;
      for (final entry in allData.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('image') ||
            key.contains('photo') ||
            key.contains('picture') ||
            key.contains('img')) {
          final foundUrl = extractImageUrl(entry.value);
          if (foundUrl != null && foundUrl.isNotEmpty) {
            imageUrl = foundUrl;
            debugPrint(
                '✅ HotelModel: Found image in field "${entry.key}": $imageUrl');
            break;
          }
        }
      }
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      debugPrint(
          '✅ HotelModel: Found imageUrl = "$imageUrl" for hotelId=$hotelId');
    } else {
      debugPrint('⚠️ HotelModel: No imageUrl found for hotelId=$hotelId');
    }

    // Safe parsing for description - similar to name parsing
    String? description;

    // Helper function to get description from various formats
    // Note: We store Map as JSON string to allow locale-based selection in UI
    String? getDescription(dynamic descValue) {
      if (descValue == null) return null;

      // If it's a String, check if it's already a JSON string
      if (descValue is String && descValue.isNotEmpty) {
        // If it looks like JSON, return as is (UI will parse it)
        if (descValue.trim().startsWith('{') ||
            descValue.trim().startsWith('[')) {
          return descValue;
        }
        // Otherwise return as plain string
        return descValue;
      }

      // If it's a Map (multi-language format like {"uz": "...", "ru": "...", "en": "...", "uz_CYR": "..."})
      // Store as JSON string so UI can parse it and select based on locale
      if (descValue is Map) {
        try {
          final descMap = Map<String, dynamic>.from(descValue);
          // Convert Map to JSON string to preserve multi-language data
          return jsonEncode(descMap);
        } catch (e) {
          debugPrint(
              '⚠️ HotelModel: Error encoding description Map to JSON: $e');
          // Fallback: try to get a single value
          try {
            final descMap = Map<String, dynamic>.from(descValue);
            return descMap['uz']?.toString() ??
                descMap['ru']?.toString() ??
                descMap['en']?.toString() ??
                (descMap.isNotEmpty ? descMap.values.first.toString() : null);
          } catch (e2) {
            debugPrint('⚠️ HotelModel: Error parsing description Map: $e2');
          }
        }
      }

      // If it's a List
      if (descValue is List && descValue.isNotEmpty) {
        final firstItem = descValue[0];
        // If first item is a Map, convert to JSON string
        if (firstItem is Map) {
          try {
            return jsonEncode(firstItem);
          } catch (e) {
            return getDescription(firstItem);
          }
        }
        // If first item is a String, return it
        if (firstItem is String) {
          return firstItem;
        }
        // Otherwise convert to string
        return firstItem.toString();
      }

      return null;
    }

    // Try hotelInfo first
    if (hotelInfo != null && hotelInfo['description'] != null) {
      description = getDescription(hotelInfo['description']);
    }

    // Try json directly if not found
    if ((description == null || description.isEmpty) &&
        json['description'] != null) {
      description = getDescription(json['description']);
    }

    // Try 'descriptions' (plural) field
    if ((description == null || description.isEmpty)) {
      dynamic descriptionsData =
          hotelInfo?['descriptions'] ?? json['descriptions'];
      if (descriptionsData != null) {
        description = getDescription(descriptionsData);
      }
    }

    // Debug log
    if (description != null && description.isNotEmpty) {
      debugPrint(
          '✅ HotelModel: Parsed description for hotelId=$hotelId: ${description.length} chars');
    } else {
      debugPrint('⚠️ HotelModel: No description found for hotelId=$hotelId');
    }

    final amenities = hotelInfo?['amenities'] != null
        ? (hotelInfo!['amenities'] as List<dynamic>)
            .map((e) => e.toString())
            .toList()
        : json['amenities'] != null
            ? (json['amenities'] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
            : null;

    // Parse photos if available
    List<HotelPhoto>? photos;
    final photosList = hotelInfo?['photos'] ?? json['photos'];
    if (photosList is List) {
      photos = photosList
          .map((photo) {
            try {
              if (photo is Map<String, dynamic>) {
                return HotelPhoto(
                  id: safeInt(photo['id']),
                  url: extractImageUrl(photo['url'] ??
                          photo['link'] ??
                          photo['image_url']) ??
                      '',
                  thumbnailUrl: extractImageUrl(
                      photo['thumbnail_url'] ?? photo['thumbnail']),
                  description: photo['description'] as String?,
                  category: photo['category'] as String?,
                  isDefault: photo['is_default'] == true,
                );
              } else if (photo is String) {
                // Handle simple string URLs
                final url = extractImageUrl(photo);
                if (url != null) {
                  return HotelPhoto(
                    id: 0,
                    url: url,
                  );
                }
              }
              return null;
            } catch (e) {
              return null;
            }
          })
          .whereType<HotelPhoto>()
          .toList();
    }

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
      rating: stars.toDouble(),
      imageUrl: imageUrl,
      description: description,
      amenities: amenities,
      options: options.isNotEmpty ? options : null,
      stars: stars,
      discount: bestOption?.discount ??
          safeInt(hotelInfo?['discount'] ??
              json['discount'] ??
              hotelInfo?['discount_percent'] ??
              json['discount_percent']),
      photos: photos,
    );
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) =>
      _$HotelModelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelModelToJson(this);
}
