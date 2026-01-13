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
    super.latitude,
    super.longitude,
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

    // Parse cancellation policy - can be Map or List format
    Map<String, dynamic>? _parseCancellationPolicy(dynamic value) {
      if (value == null) return null;
      
      // Handle List format: [{locale: 'ru', value: '...'}, ...]
      if (value is List) {
        final policyMap = <String, dynamic>{};
        for (var item in value) {
          if (item is Map) {
            final locale = item['locale']?.toString();
            final policyValue = item['value'];
            if (locale != null && policyValue != null) {
              policyMap[locale] = policyValue;
            }
          }
        }
        return policyMap.isNotEmpty ? policyMap : null;
      }
      
      // Handle Map format: {uz: '...', ru: '...', en: '...'}
      if (value is Map) {
        try {
          return Map<String, dynamic>.from(value);
        } catch (_) {
          return null;
        }
      }
      
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

            // Commission calculation (komissiya)
            // Agar API'dan foiz kelsa, uni ishlatish, aks holda 10% qo'shish
            final commissionPercent = percent > 0 ? percent : 10; // Default 10% komissiya
            final newPrice = originalPrice != null
                ? originalPrice + (originalPrice * commissionPercent / 100)
                : originalPrice;
            
            // Debug log
            if (kDebugMode && originalPrice != null) {
              debugPrint('💰 HotelModel: optionRefId=${optMap['option_ref_id']}, originalPrice=$originalPrice, API percent=$percent%, used percent=$commissionPercent%, newPrice=$newPrice');
            }

            return HotelOption(
              optionRefId: optMap['option_ref_id'] as String? ?? '',
              roomTypeId: safeInt(optMap['room_type_id']),
              ratePlanId: safeInt(optMap['rate_plan_id']),
              price: newPrice,
              currency: optMap['currency'] as String?,
              priceBreakdown:
                  optMap['price_breakdown'] as Map<String, dynamic>?,
              cancellationPolicy: _parseCancellationPolicy(optMap['cancellation_policy']),
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

    // Safe parsing for address - check multiple possible field names
    String address = '';
    
    // Try different field names for address
    address = getString(hotelInfo?['address']) ?? 
              getString(hotelInfo?['location']) ??
              getString(hotelInfo?['full_address']) ??
              getString(json['address']) ?? 
              getString(json['location']) ??
              getString(json['full_address']) ?? 
              '';
    
    // If address is still empty, try to get it directly from json (might be a simple string, Map, or List)
    if (address.isEmpty && json['address'] != null) {
      final addressValue = json['address'];
      if (addressValue is String && addressValue.isNotEmpty) {
        address = addressValue;
        debugPrint('✅ HotelModel: Found address as direct string: "$address" for hotelId=$hotelId');
      } else if (addressValue is Map) {
        // Try to extract from map
        final addressFromMap = getString(addressValue);
        if (addressFromMap != null && addressFromMap.isNotEmpty) {
          address = addressFromMap;
          debugPrint('✅ HotelModel: Found address in map: "$address" for hotelId=$hotelId');
        }
      } else if (addressValue is List && addressValue.isNotEmpty) {
        // Address is a List format: [{locale: uz, value: ...}, {locale: ru, value: ...}, ...]
        // Try to extract based on locale preference
        for (var item in addressValue) {
          if (item is Map) {
            final locale = item['locale']?.toString();
            final value = item['value']?.toString();
            if (value != null && value.isNotEmpty) {
              // Prefer uz locale, then ru, then en
              if (locale == 'uz' || (address.isEmpty && locale == 'ru') || (address.isEmpty && locale == 'en')) {
                address = value;
                if (locale == 'uz') {
                  debugPrint('✅ HotelModel: Found address from List with uz locale: "$address" for hotelId=$hotelId');
                  break; // Prefer uz, so break after finding it
                }
              }
            }
          }
        }
        // If still empty, take first available value
        if (address.isEmpty) {
          for (var item in addressValue) {
            if (item is Map) {
              final value = item['value']?.toString();
              if (value != null && value.isNotEmpty) {
                address = value;
                debugPrint('✅ HotelModel: Found address from List (first available): "$address" for hotelId=$hotelId');
                break;
              }
            }
          }
        }
      }
    }
    
    // Debug log for address
    if (address.isEmpty) {
      debugPrint('⚠️ HotelModel: Address is empty for hotelId=$hotelId');
      if (hotelInfo != null) {
        debugPrint('🔍 HotelModel: hotelInfo keys for address check = ${hotelInfo.keys.toList()}');
        // Try to find any field that might contain address
        for (var key in hotelInfo.keys) {
          if (key.toString().toLowerCase().contains('address') || 
              key.toString().toLowerCase().contains('location') ||
              key.toString().toLowerCase().contains('street')) {
            debugPrint('🔍 HotelModel: Found potential address field: $key = ${hotelInfo[key]}');
          }
        }
      }
      debugPrint('🔍 HotelModel: json keys for address check = ${json.keys.toList()}');
      // Log the actual address value from json
      if (json['address'] != null) {
        debugPrint('🔍 HotelModel: json[address] value = ${json['address']} (type: ${json['address'].runtimeType})');
      }
    } else {
      debugPrint('✅ HotelModel: Parsed address = "$address" for hotelId=$hotelId');
    }

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
    
    // Safe parsing for stars - check multiple possible field names
    int stars = 0;
    
    // Helper to safely get int from multiple sources (returns 0 if invalid)
    int tryGetStars(dynamic value) {
      if (value == null) return 0;
      final result = safeInt(value);
      return result > 0 ? result : 0;
    }
    
    // Try different field names for stars
    final starsFromHotelInfo = tryGetStars(hotelInfo?['stars']);
    if (starsFromHotelInfo > 0) {
      stars = starsFromHotelInfo;
    } else {
      final starsFromStar = tryGetStars(hotelInfo?['star']);
      if (starsFromStar > 0) {
        stars = starsFromStar;
      } else {
        final starsFromStarRating = tryGetStars(hotelInfo?['star_rating']);
        if (starsFromStarRating > 0) {
          stars = starsFromStarRating;
        } else {
          final starsFromRatingStars = tryGetStars(hotelInfo?['rating_stars']);
          if (starsFromRatingStars > 0) {
            stars = starsFromRatingStars;
          } else {
            // Try from json directly
            stars = tryGetStars(json['stars']);
            if (stars == 0) {
              stars = tryGetStars(json['star']);
              if (stars == 0) {
                stars = tryGetStars(json['star_rating']);
                if (stars == 0) {
                  stars = tryGetStars(json['rating_stars']);
                  if (stars == 0) {
                    // Try star_id - API returns star_id which might be the star rating (1-5)
                    final starId = tryGetStars(json['star_id']);
                    if (starId > 0 && starId <= 5) {
                      stars = starId;
                      debugPrint('✅ HotelModel: Using star_id as stars: $stars for hotelId=$hotelId');
                    } else if (starId > 0) {
                      // If star_id is > 5, it might be an ID, not the rating
                      // But we'll try to use it anyway if it's reasonable (1-10)
                      if (starId <= 10) {
                        stars = starId;
                        debugPrint('✅ HotelModel: Using star_id as stars (unusual value): $stars for hotelId=$hotelId');
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    
    // Debug log for stars
    if (stars == 0) {
      debugPrint('⚠️ HotelModel: Stars is 0 for hotelId=$hotelId');
      if (hotelInfo != null) {
        debugPrint('🔍 HotelModel: hotelInfo keys for stars check = ${hotelInfo.keys.toList()}');
        // Try to find any field that might contain stars
        for (var key in hotelInfo.keys) {
          if (key.toString().toLowerCase().contains('star') || 
              key.toString().toLowerCase().contains('rating')) {
            debugPrint('🔍 HotelModel: Found potential stars field: $key = ${hotelInfo[key]} (type: ${hotelInfo[key].runtimeType})');
          }
        }
      }
      debugPrint('🔍 HotelModel: json keys for stars check = ${json.keys.toList()}');
      // Try to find any field that might contain stars in json
      for (var key in json.keys) {
        if (key.toString().toLowerCase().contains('star') || 
            key.toString().toLowerCase().contains('rating')) {
          debugPrint('🔍 HotelModel: Found potential stars field in json: $key = ${json[key]} (type: ${json[key].runtimeType})');
        }
      }
    } else {
      debugPrint('✅ HotelModel: Parsed stars = $stars for hotelId=$hotelId');
    }
    
    // Parse latitude and longitude
    double? latitude;
    double? longitude;
    
    // Try to get coordinates from hotelInfo or json
    if (hotelInfo != null) {
      latitude = safeDouble(hotelInfo['latitude']);
      longitude = safeDouble(hotelInfo['longitude']);
    }
    
    if (latitude == null || longitude == null) {
      latitude = safeDouble(json['latitude']);
      longitude = safeDouble(json['longitude']);
    }
    
    if (latitude != null && longitude != null) {
      debugPrint('✅ HotelModel: Parsed coordinates: lat=$latitude, lng=$longitude for hotelId=$hotelId');
    } else {
      debugPrint('⚠️ HotelModel: No coordinates found for hotelId=$hotelId');
    }

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
      
      // Helper to recursively search for image URLs in nested structures
      String? searchNestedForImage(dynamic value, int depth) {
        if (depth > 3) return null; // Limit recursion depth
        
        if (value == null) return null;
        
        // If it's a string, try to extract URL
        if (value is String && value.isNotEmpty) {
          final url = extractImageUrl(value);
          if (url != null && url.isNotEmpty) return url;
        }
        
        // If it's a Map, search all values
        if (value is Map) {
          for (final entry in value.entries) {
            final key = entry.key.toString().toLowerCase();
            // Check if key suggests it's an image field
            if (key.contains('image') ||
                key.contains('photo') ||
                key.contains('picture') ||
                key.contains('img') ||
                key.contains('link') ||
                key == 'url') {
              final foundUrl = extractImageUrl(entry.value);
              if (foundUrl != null && foundUrl.isNotEmpty) {
                return foundUrl;
              }
            }
            // Recursively search nested structures
            final nestedUrl = searchNestedForImage(entry.value, depth + 1);
            if (nestedUrl != null && nestedUrl.isNotEmpty) {
              return nestedUrl;
            }
          }
        }
        
        // If it's a List, search first few items
        if (value is List && value.isNotEmpty) {
          for (int i = 0; i < value.length && i < 5; i++) {
            final itemUrl = searchNestedForImage(value[i], depth + 1);
            if (itemUrl != null && itemUrl.isNotEmpty) {
              return itemUrl;
            }
          }
        }
        
        return null;
      }
      
      // Search all fields
      for (final entry in allData.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('image') ||
            key.contains('photo') ||
            key.contains('picture') ||
            key.contains('img') ||
            key.contains('link')) {
          final foundUrl = extractImageUrl(entry.value);
          if (foundUrl != null && foundUrl.isNotEmpty) {
            imageUrl = foundUrl;
            debugPrint(
                '✅ HotelModel: Found image in field "${entry.key}": $imageUrl');
            break;
          }
        }
      }
      
      // If still not found, do a deep recursive search
      if (imageUrl == null || imageUrl.isEmpty) {
        final deepFoundUrl = searchNestedForImage(allData, 0);
        if (deepFoundUrl != null && deepFoundUrl.isNotEmpty) {
          imageUrl = deepFoundUrl;
          debugPrint('✅ HotelModel: Found image in nested structure: $imageUrl');
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

    // Parse amenities - handle multiple formats and field names
    List<String>? amenities;
    
    // Helper function to extract amenity names from various formats
    List<String> extractAmenities(dynamic value) {
      if (value == null) return [];
      
      if (value is List) {
        return value.map((e) {
          if (e is String) {
            return e;
          } else if (e is Map) {
            // Try to get name from map (could be {"id": 1, "name": "WiFi", "name_uz": "...", etc.})
            return e['name']?.toString() ?? 
                   e['name_uz']?.toString() ?? 
                   e['name_ru']?.toString() ?? 
                   e['name_en']?.toString() ??
                   e['title']?.toString() ??
                   e['label']?.toString() ??
                   e.toString();
          } else {
            return e.toString();
          }
        }).where((name) => name.isNotEmpty).toList();
      } else if (value is String) {
        // If it's a single string, try to parse as JSON array
        try {
          final parsed = jsonDecode(value);
          if (parsed is List) {
            return extractAmenities(parsed);
          }
        } catch (_) {
          // If not JSON, return as single item
          return [value];
        }
      }
      
      return [];
    }
    
    // Try hotelInfo first
    if (hotelInfo != null) {
      // Check 'amenities' field
      if (hotelInfo['amenities'] != null) {
        debugPrint('🔍 HotelModel: Found amenities in hotelInfo, type: ${hotelInfo['amenities'].runtimeType}');
        amenities = extractAmenities(hotelInfo['amenities']);
        if (amenities.isNotEmpty) {
          debugPrint('✅ HotelModel: Parsed ${amenities.length} amenities from hotelInfo.amenities');
        }
      }
      
      // Also check 'facilities' field (alternative name)
      if ((amenities == null || amenities.isEmpty) && hotelInfo['facilities'] != null) {
        debugPrint('🔍 HotelModel: Found facilities in hotelInfo, type: ${hotelInfo['facilities'].runtimeType}');
        amenities = extractAmenities(hotelInfo['facilities']);
        if (amenities.isNotEmpty) {
          debugPrint('✅ HotelModel: Parsed ${amenities.length} amenities from hotelInfo.facilities');
        }
      }
      
      // Check 'features' field (another alternative)
      if ((amenities == null || amenities.isEmpty) && hotelInfo['features'] != null) {
        debugPrint('🔍 HotelModel: Found features in hotelInfo, type: ${hotelInfo['features'].runtimeType}');
        amenities = extractAmenities(hotelInfo['features']);
        if (amenities.isNotEmpty) {
          debugPrint('✅ HotelModel: Parsed ${amenities.length} amenities from hotelInfo.features');
        }
      }
    }
    
    // Try json directly if not found
    if (amenities == null || amenities.isEmpty) {
      if (json['amenities'] != null) {
        debugPrint('🔍 HotelModel: Found amenities in json, type: ${json['amenities'].runtimeType}');
        amenities = extractAmenities(json['amenities']);
        if (amenities.isNotEmpty) {
          debugPrint('✅ HotelModel: Parsed ${amenities.length} amenities from json.amenities');
        }
      }
      
      // Also check 'facilities' field in json
      if ((amenities == null || amenities.isEmpty) && json['facilities'] != null) {
        debugPrint('🔍 HotelModel: Found facilities in json, type: ${json['facilities'].runtimeType}');
        amenities = extractAmenities(json['facilities']);
        if (amenities.isNotEmpty) {
          debugPrint('✅ HotelModel: Parsed ${amenities.length} amenities from json.facilities');
        }
      }
      
      // Check 'features' field in json
      if ((amenities == null || amenities.isEmpty) && json['features'] != null) {
        debugPrint('🔍 HotelModel: Found features in json, type: ${json['features'].runtimeType}');
        amenities = extractAmenities(json['features']);
        if (amenities.isNotEmpty) {
          debugPrint('✅ HotelModel: Parsed ${amenities.length} amenities from json.features');
        }
      }
      
      // Check 'hotel_facilities' field in json (this is the actual field from API)
      // Note: hotel_facilities contains only facility_id, not full facility details
      // So we skip parsing it here - full details will come from getHotelFacilities API
      if ((amenities == null || amenities.isEmpty) && json['hotel_facilities'] != null) {
        debugPrint('🔍 HotelModel: Found hotel_facilities in json, type: ${json['hotel_facilities'].runtimeType}');
        debugPrint('🔍 HotelModel: hotel_facilities value: ${json['hotel_facilities']}');
        // hotel_facilities contains only facility_id, not full details
        // Skip parsing - full details will come from getHotelFacilities API
        // This prevents showing incorrect facility names/ids
        debugPrint('ℹ️ HotelModel: Skipping hotel_facilities parse - will use getHotelFacilities API for full details');
      }
    }
    
    // Debug final result
    if (amenities != null && amenities.isNotEmpty) {
      debugPrint('✅ HotelModel: Final amenities count = ${amenities.length} for hotelId=$hotelId');
      debugPrint('🔍 HotelModel: First few amenities: ${amenities.take(3).toList()}');
    } else {
      debugPrint('⚠️ HotelModel: No amenities found for hotelId=$hotelId');
      // Log all keys to help debug
      if (hotelInfo != null) {
        debugPrint('🔍 HotelModel: hotelInfo keys = ${hotelInfo.keys.toList()}');
      }
      debugPrint('🔍 HotelModel: json keys = ${json.keys.toList()}');
    }
    
    // Convert to nullable list
    amenities = amenities?.isEmpty == true ? null : amenities;

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

    // If imageUrl is still not found, try to use first photo from photos array
    if ((imageUrl == null || imageUrl.isEmpty) && photos != null && photos.isNotEmpty) {
      // Try to find default photo first
      HotelPhoto? defaultPhoto;
      try {
        defaultPhoto = photos.firstWhere(
          (p) => p.isDefault && p.url.isNotEmpty,
        );
      } catch (e) {
        // No default photo found, try to find any photo with URL
        try {
          defaultPhoto = photos.firstWhere(
            (p) => p.url.isNotEmpty,
          );
        } catch (e2) {
          // No photo with URL found, use first photo
          defaultPhoto = photos.isNotEmpty ? photos.first : null;
        }
      }
      
      if (defaultPhoto != null && defaultPhoto.url.isNotEmpty) {
        imageUrl = defaultPhoto.url;
        debugPrint('✅ HotelModel: Using first photo as imageUrl for hotelId=$hotelId: $imageUrl');
      }
    }

    // Final fallback placeholder to avoid empty images
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = 'https://placehold.co/400x250?text=Mehmonxona+rasmi';
      debugPrint(
          'ℹ️ HotelModel: Using fallback imageUrl for hotelId=$hotelId');
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
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) =>
      _$HotelModelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelModelToJson(this);
}
