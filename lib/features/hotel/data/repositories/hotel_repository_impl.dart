import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_booking.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../datasources/hotel_remote_data_source.dart';
import '../models/search_request_model.dart';
import '../models/search_response_model.dart';
import '../models/quote_model.dart';
import '../models/booking_model.dart';
import '../models/hotel_model.dart';

class HotelRepositoryImpl implements HotelRepository {
  HotelRepositoryImpl({required HotelRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final HotelRemoteDataSource _remoteDataSource;

  // Helper methods for mapping
  // Safe parsing helpers
  int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }

  String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, String>? _extractNameMap(Map<String, dynamic> item) {
    final names = item['names'];

    // Handle List format: [{locale: 'ru', value: '<p>...</p>'}, ...]
    if (names is List) {
      final nameMap = <String, String>{};
      for (var item in names) {
        if (item is Map) {
          final locale = item['locale']?.toString();
          final value = item['value']?.toString();
          if (locale != null && value != null) {
            // Clean HTML tags from value
            nameMap[locale] = _stripHtmlTags(value);
          }
        }
      }
      return nameMap.isNotEmpty ? nameMap : null;
    }

    // Handle Map format: {uz: '...', ru: '...', en: '...'}
    if (names is Map) {
      final nameMap = <String, String>{};
      names.forEach((key, value) {
        final locale = key.toString();
        final text = value?.toString() ?? '';
        if (text.isNotEmpty) {
          // Clean HTML tags from value
          nameMap[locale] = _stripHtmlTags(text);
        }
      });
      return nameMap.isNotEmpty ? nameMap : null;
    }

    return null;
  }

  /// Strips HTML tags from text
  String _stripHtmlTags(String html) {
    if (html.isEmpty) return html;

    // Remove HTML tags using regex
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    // Trim and clean up multiple spaces
    text = text.trim().replaceAll(RegExp(r'\s+'), ' ');

    return text;
  }

  String _extractName(Map<String, String>? nameMap, Map<String, dynamic> item) {
    // Try nameMap first (multi-language support)
    if (nameMap != null && nameMap.isNotEmpty) {
      final name = nameMap['uz'] ?? nameMap['ru'] ?? nameMap['en'];
      if (name != null && name.isNotEmpty) {
        return name;
      }
      // Try any value from nameMap
      if (nameMap.values.isNotEmpty) {
        final anyName =
            nameMap.values.firstWhere((v) => v.isNotEmpty, orElse: () => '');
        if (anyName.isNotEmpty) return anyName;
      }
    }

    // Try direct fields
    final directName = item['name']?.toString() ??
        item['title']?.toString() ??
        item['label']?.toString() ??
        item['text']?.toString() ??
        item['value']?.toString() ??
        item['description']?.toString() ??
        item['content']?.toString();

    if (directName != null && directName.isNotEmpty) {
      return directName;
    }

    // Last resort: use ID if available
    final id = item['id'];
    if (id != null) {
      return 'Item $id';
    }

    return 'Unknown';
  }

  City _mapCityFromMap(Map<String, dynamic> item) {
    final id = (item['id'] ?? item['city_id']) is int
        ? (item['id'] ?? item['city_id']) as int
        : int.tryParse((item['id'] ?? item['city_id'])?.toString() ?? '') ?? 0;

    // names could be under 'names' or 'translations'
    final dynamic rawNames = item['names'] ?? item['translations'];
    Map<String, String>? nameMap;
    if (rawNames is Map) {
      nameMap = rawNames
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    } else if (rawNames is List) {
      nameMap = {};
      for (var tr in rawNames) {
        if (tr is Map) {
          final key = tr['locale'] ?? tr['language'] ?? tr['lang'];
          final value = tr['value'] ?? tr['name'] ?? tr['text'];
          if (key != null && value != null) {
            nameMap[key.toString()] = value.toString();
          }
        }
      }
    }

    final String name = nameMap?['uz'] ??
        nameMap?['ru'] ??
        nameMap?['en'] ??
        item['name']?.toString() ??
        item['title']?.toString() ??
        '';

    return City(id: id, name: name, names: nameMap);
  }

  Country _mapCountryFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final code = _parseString(item['code']);
    return Country(id: id, name: name, names: nameMap, code: code);
  }

  Region _mapRegionFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final countryId = _parseInt(item['country_id'], defaultValue: 0);
    return Region(
        id: id,
        name: name,
        names: nameMap,
        countryId: countryId > 0 ? countryId : null);
  }

  HotelType _mapHotelTypeFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    return HotelType(id: id, name: name, names: nameMap);
  }

  Facility _mapFacilityFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = _parseString(item['icon']);
    return Facility(id: id, name: name, names: nameMap, icon: icon);
  }

  Equipment _mapEquipmentFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = _parseString(item['icon']);
    return Equipment(id: id, name: name, names: nameMap, icon: icon);
  }

  Currency _mapCurrencyFromMap(Map<String, dynamic> item) {
    final code = _parseString(item['code']) ?? '';
    final name = _parseString(item['name']) ?? code;
    final symbol = _parseString(item['symbol']);
    final rate = _parseDouble(item['rate']);
    return Currency(code: code, name: name, symbol: symbol, rate: rate);
  }

  Star _mapStarFromMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      final value = _parseInt(item['value'] ?? item['id']);
      final name = _parseString(item['name']);
      return Star(value: value, name: name);
    } else if (item is int) {
      return Star(value: item);
    }
    return const Star(value: 0);
  }

  /// Helper function to normalize image URLs (similar to HotelModel.extractImageUrl)
  String? _normalizeImageUrl(dynamic value) {
    if (value == null) return null;

    String? rawUrl;

    if (value is String && value.isNotEmpty) {
      rawUrl = value;
    } else if (value is List && value.isNotEmpty) {
      final firstItem = value[0];
      if (firstItem is String && firstItem.isNotEmpty) {
        rawUrl = firstItem;
      } else if (firstItem is Map) {
        rawUrl = _normalizeImageUrl(firstItem['link'] ??
            firstItem['url'] ??
            firstItem['image_url'] ??
            firstItem['photo_url']);
      }
    } else if (value is Map) {
      rawUrl = _normalizeImageUrl(value['link'] ??
          value['url'] ??
          value['image_url'] ??
          value['photo_url']);
    }

    if (rawUrl == null || rawUrl.isEmpty) return null;

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
      final cleanBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      return '$cleanBaseUrl$rawUrl';
    }

    // If it doesn't look like a URL, return null
    if (!rawUrl.contains('.') || rawUrl.contains(' ')) {
      return null;
    }

    return rawUrl;
  }

  HotelPhoto _mapHotelPhotoFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);

    // Try to extract and normalize URL from various fields
    final rawUrl = _parseString(
        item['link'] ?? item['url'] ?? item['photo_url'] ?? item['image_url']);

    final url = _normalizeImageUrl(rawUrl) ?? '';

    // Normalize thumbnail URL too
    final rawThumbnailUrl =
        _parseString(item['thumbnail_url'] ?? item['thumbnail']);
    final thumbnailUrl = _normalizeImageUrl(rawThumbnailUrl);

    final description = _parseString(item['description']);
    final category =
        _parseString(item['category'] ?? item['type']) ?? 'general';
    final isDefault = item['default'] as bool? ??
        item['is_default'] as bool? ??
        item['isDefault'] as bool? ??
        false;

    return HotelPhoto(
      id: id,
      url: url,
      thumbnailUrl: thumbnailUrl,
      description: description,
      category: category,
      isDefault: isDefault,
    );
  }

  RoomType _mapRoomTypeFromMap(Map<String, dynamic> item, int hotelId) {
    final id = _parseInt(item['id'] ?? item['room_type_id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final maxOccupancy = item.containsKey('max_occupancy')
        ? _parseInt(item['max_occupancy'], defaultValue: 0)
        : null;
    final description = _parseString(item['description']);

    // Debug: log room type parsing
    debugPrint(
        '🔍 RoomType parsing: id=$id, name=$name, nameMap=$nameMap, maxOccupancy=$maxOccupancy');
    debugPrint('🔍 RoomType raw item keys: ${item.keys.toList()}');
    if (item['names'] != null) {
      debugPrint(
          '🔍 RoomType names type: ${item['names'].runtimeType}, value: ${item['names']}');
    }

    return RoomType(
      id: id,
      name: name,
      names: nameMap,
      hotelId: hotelId,
      maxOccupancy:
          maxOccupancy != null && maxOccupancy > 0 ? maxOccupancy : null,
      description: description,
    );
  }

  NearbyPlaceType _mapNearbyPlaceTypeFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = _parseString(item['icon']);
    return NearbyPlaceType(id: id, name: name, names: nameMap, icon: icon);
  }

  NearbyPlace _mapNearbyPlaceFromMap(Map<String, dynamic> item, int hotelId) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final typeId = _parseInt(item['type_id'], defaultValue: 0);
    final distance = _parseDouble(item['distance']);
    final coordinates = item['coordinates'] as Map<String, dynamic>?;
    Map<String, double>? coordsMap;
    if (coordinates != null) {
      coordsMap = coordinates.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as num?)?.toDouble() ?? 0.0,
        ),
      );
    }
    return NearbyPlace(
      id: id,
      name: name,
      names: nameMap,
      hotelId: hotelId,
      typeId: typeId,
      distance: distance,
      coordinates: coordsMap,
    );
  }

  ServiceInRoom _mapServiceInRoomFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = _parseString(item['icon']);
    return ServiceInRoom(id: id, name: name, names: nameMap, icon: icon);
  }

  BedType _mapBedTypeFromMap(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = _parseString(item['icon']);
    return BedType(id: id, name: name, names: nameMap, icon: icon);
  }

  /// Загружает фотографии для списка отелей параллельно
  Future<List<HotelModel>> _loadPhotosForHotels(List<HotelModel> hotels) async {
    // Загружаем фотографии параллельно для всех отелей
    // Limit concurrent requests to avoid overwhelming the server
    const maxConcurrent = 10;
    final hotelsWithPhotos = <HotelModel>[];

    for (var i = 0; i < hotels.length; i += maxConcurrent) {
      final batch = hotels.sublist(
        i,
        i + maxConcurrent > hotels.length ? hotels.length : i + maxConcurrent,
      );

      final batchResults = await Future.wait(
        batch.map((hotel) async {
          try {
            // Remote data source dan Map list olamiz
            final photosData =
                await _remoteDataSource.getHotelPhotos(hotel.hotelId);

            if (photosData.isEmpty) {
              return hotel;
            }

            // Map'larni HotelPhoto entity'larga aylantiramiz
            final photos = photosData
                .map((item) {
                  try {
                    return _mapHotelPhotoFromMap(item);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<HotelPhoto>()
                .toList();

            // Filter out photos with empty URLs
            final validPhotos = photos.where((p) => p.url.isNotEmpty).toList();

            // Если есть валидные фотографии, обновляем отель
            if (validPhotos.isNotEmpty) {
              // Try to find default photo first, then first photo with valid URL
              HotelPhoto? selectedPhoto;
              try {
                selectedPhoto = validPhotos.firstWhere(
                  (p) => p.isDefault && p.url.isNotEmpty,
                );
              } catch (e) {
                // No default photo, use first valid photo
                selectedPhoto = validPhotos.first;
              }

              // Always update imageUrl if hotel doesn't have one or if we found a better photo
              final currentImageUrl =
                  hotel.imageUrl?.isNotEmpty == true ? hotel.imageUrl : null;
              final newImageUrl = selectedPhoto.url.isNotEmpty
                  ? selectedPhoto.url
                  : currentImageUrl;

              return hotel.copyWith(
                photos: validPhotos,
                imageUrl: newImageUrl,
              );
            }
            return hotel;
          } catch (e) {
            return hotel;
          }
        }),
      );

      hotelsWithPhotos.addAll(batchResults);
    }

    return hotelsWithPhotos;
  }

  // Search methods
  @override
  Future<HotelSearchResult> searchHotels({
    HotelFilter filter = HotelFilter.empty,
  }) async {
    try {
      final request = SearchRequestModel.fromFilter(filter);
      final model = await _remoteDataSource.searchHotels(request);

      // Agar mehmonxonalarda to'liq ma'lumotlar bo'lmasa, ularni to'ldiramiz
      if (model.hotels.isNotEmpty) {
        final firstHotel = model.hotels.first;
        final maLumotlarToLiqEmas = firstHotel.name.startsWith('Hotel #') ||
            (firstHotel.imageUrl == null || firstHotel.imageUrl!.isEmpty);

        if (maLumotlarToLiqEmas) {
          try {
            // /hotels/list API dan to'liq ma'lumotlarni olamiz
            final cityId = filter.cityId;
            // _remoteDataSource.getHotelsList returns List<HotelModel>
            final toLiqMehmonxonalar = await _remoteDataSource.getHotelsList(
              cityId: cityId,
            );

            // hotelId bo'yicha tez qidirish uchun Map yaratamiz
            final mehmonxonalarMap = <int, HotelModel>{};
            for (final mehmonxona in toLiqMehmonxonalar) {
              mehmonxonalarMap[mehmonxona.hotelId] = mehmonxona;
            }

            // Ma'lumotlarni birlashtiramiz: to'liq ma'lumotlar + narxlar/opsiyalar
            final toLiqHotellar = model.hotels.map((qidiruvMehmonxonasi) {
              final toLiqMehmonxona =
                  mehmonxonalarMap[qidiruvMehmonxonasi.hotelId];

              if (toLiqMehmonxona != null) {
                // To'liq ma'lumotlar + qidiruvdan kelgan narxlar/opsiyalar
                return toLiqMehmonxona.copyWith(
                  price: qidiruvMehmonxonasi.price,
                  options: qidiruvMehmonxonasi.options,
                  checkInDate: qidiruvMehmonxonasi.checkInDate,
                  checkOutDate: qidiruvMehmonxonasi.checkOutDate,
                  guests: qidiruvMehmonxonasi.guests,
                  // Saqlangan fotografiyalarni ham saqlaymiz
                  photos: toLiqMehmonxona.photos,
                );
              } else {
                return qidiruvMehmonxonasi;
              }
            }).toList();

            final toLiqModel = SearchResponseModel(
              hotels: toLiqHotellar,
              total: model.total,
              page: model.page,
              pageSize: model.pageSize,
            );

            // Загружаем фотографии для всех отелей
            final hotelsWithPhotos =
                await _loadPhotosForHotels(toLiqModel.hotels);
            final finalModel = SearchResponseModel(
              hotels: hotelsWithPhotos,
              total: toLiqModel.total,
              page: toLiqModel.page,
              pageSize: toLiqModel.pageSize,
            );

            return finalModel.toEntity();
          } catch (e) {
            // Xatolik bo'lsa, asl ma'lumotlarni qaytaramiz
            final hotelsWithPhotos = await _loadPhotosForHotels(model.hotels);
            final finalModel = SearchResponseModel(
              hotels: hotelsWithPhotos,
              total: model.total,
              page: model.page,
              pageSize: model.pageSize,
            );
            return finalModel.toEntity();
          }
        } else {
          // Загружаем фотографии для всех отелей
          final hotelsWithPhotos = await _loadPhotosForHotels(model.hotels);
          final finalModel = SearchResponseModel(
            hotels: hotelsWithPhotos,
            total: model.total,
            page: model.page,
            pageSize: model.pageSize,
          );
          return finalModel.toEntity();
        }
      }

      // Agar mehmonxonalar bo'sh bo'lsa ham, fotografiyalarni yuklashga harakat qilamiz
      if (model.hotels.isNotEmpty) {
        final hotelsWithPhotos = await _loadPhotosForHotels(model.hotels);
        final finalModel = SearchResponseModel(
          hotels: hotelsWithPhotos,
          total: model.total,
          page: model.page,
          pageSize: model.pageSize,
        );
        return finalModel.toEntity();
      }

      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Hotel>> getHotelsList(
      {int? hotelTypeId, int? countryId, int? regionId, int? cityId}) async {
    try {
      final models = await _remoteDataSource.getHotelsList(
        hotelTypeId: hotelTypeId,
        countryId: countryId,
        regionId: regionId,
        cityId: cityId,
      );
      return models;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<Hotel> getHotelDetails({required String hotelId}) async {
    try {
      return await _remoteDataSource.getHotelDetails(hotelId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<String>> getCities({String? query}) async {
    try {
      return await _remoteDataSource.getCities(query: query);
    } on AppException catch (e) {
      if (e is ServerException && e.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<City>> getCitiesWithIds({int? countryId}) async {
    debugPrint(
        '🔍 HotelRepository: getCitiesWithIds called with countryId: $countryId');
    try {
      final data = await _remoteDataSource.getCitiesWithIds(
        countryId: countryId ?? 1, // Default: Uzbekistan
      );
      debugPrint('🔍 HotelRepository: Received ${data.length} cities from API');
      if (data.isNotEmpty) {
        debugPrint('🔍 First city data: ${data.first}');
      }

      final cities = data.map((item) => _mapCityFromMap(item)).toList();
      debugPrint('✅ HotelRepository: Mapped ${cities.length} cities');
      if (cities.isNotEmpty) {
        debugPrint(
            '🔍 First mapped city: ${cities.first.name} (id: ${cities.first.id})');
      }
      return cities;
    } on AppException catch (e) {
      debugPrint('❌ HotelRepository: AppException - ${e.message}');
      if ((e is ServerException && e.statusCode == 404) ||
          e.message.contains('404')) {
        debugPrint('⚠️ HotelRepository: 404 error, using fallback cities');
        // Return fallback cities if API is missing (404)
        final fallbackCities = [
          {
            'id': 1,
            'name': 'Toshkent',
            'names': {'uz': 'Toshkent', 'ru': 'Ташкент', 'en': 'Tashkent'}
          },
          {
            'id': 2,
            'name': 'Samarqand',
            'names': {'uz': 'Samarqand', 'ru': 'Самарканд', 'en': 'Samarkand'}
          },
          {
            'id': 3,
            'name': 'Buxoro',
            'names': {'uz': 'Buxoro', 'ru': 'Бухара', 'en': 'Bukhara'}
          },
          {
            'id': 4,
            'name': 'Xiva',
            'names': {'uz': 'Xiva', 'ru': 'Хива', 'en': 'Khiva'}
          },
          {
            'id': 5,
            'name': 'Namangan',
            'names': {'uz': 'Namangan', 'ru': 'Наманган', 'en': 'Namangan'}
          },
          {
            'id': 6,
            'name': 'Andijon',
            'names': {'uz': 'Andijon', 'ru': 'Андижан', 'en': 'Andijan'}
          },
          {
            'id': 7,
            'name': 'Farg\'ona',
            'names': {'uz': 'Farg\'ona', 'ru': 'Фергана', 'en': 'Fergana'}
          },
          {
            'id': 8,
            'name': 'Nukus',
            'names': {'uz': 'Nukus', 'ru': 'Нукус', 'en': 'Nukus'}
          },
        ];
        final fallback =
            fallbackCities.map((item) => _mapCityFromMap(item)).toList();
        debugPrint(
            '✅ HotelRepository: Returning ${fallback.length} fallback cities');
        return fallback;
      }
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ HotelRepository: Exception - $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (e.toString().contains('404')) {
        debugPrint(
            '⚠️ HotelRepository: 404 in exception message, using fallback cities');
        final fallbackCities = [
          {
            'id': 1,
            'name': 'Toshkent',
            'names': {'uz': 'Toshkent', 'ru': 'Ташкент', 'en': 'Tashkent'}
          },
          {
            'id': 2,
            'name': 'Samarqand',
            'names': {'uz': 'Samarqand', 'ru': 'Самарканд', 'en': 'Samarkand'}
          },
          {
            'id': 3,
            'name': 'Buxoro',
            'names': {'uz': 'Buxoro', 'ru': 'Бухара', 'en': 'Bukhara'}
          },
          {
            'id': 4,
            'name': 'Xiva',
            'names': {'uz': 'Xiva', 'ru': 'Хива', 'en': 'Khiva'}
          },
          {
            'id': 5,
            'name': 'Namangan',
            'names': {'uz': 'Namangan', 'ru': 'Наманган', 'en': 'Namangan'}
          },
          {
            'id': 6,
            'name': 'Andijon',
            'names': {'uz': 'Andijon', 'ru': 'Андижан', 'en': 'Andijan'}
          },
          {
            'id': 7,
            'name': 'Farg\'ona',
            'names': {'uz': 'Farg\'ona', 'ru': 'Фергана', 'en': 'Fergana'}
          },
          {
            'id': 8,
            'name': 'Nukus',
            'names': {'uz': 'Nukus', 'ru': 'Нукус', 'en': 'Nukus'}
          },
        ];
        final fallback =
            fallbackCities.map((item) => _mapCityFromMap(item)).toList();
        debugPrint(
            '✅ HotelRepository: Returning ${fallback.length} fallback cities');
        return fallback;
      }
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  // Booking Flow methods
  @override
  Future<HotelQuote> getQuote({
    required List<String> optionRefIds,
  }) async {
    try {
      final model = await _remoteDataSource.getQuote(optionRefIds);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<HotelBooking> createBooking({
    required CreateHotelBookingRequest request,
  }) async {
    try {
      final requestModel = CreateBookingRequestModel.fromEntity(request);
      final model = await _remoteDataSource.createBooking(requestModel);
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<HotelBooking> confirmBooking({
    required String bookingId,
    required PaymentInfo paymentInfo,
  }) async {
    try {
      final paymentInfoMap = {
        'payment_method': paymentInfo.paymentMethod,
        if (paymentInfo.cardNumber != null)
          'card_number': paymentInfo.cardNumber,
        if (paymentInfo.transactionId != null)
          'transaction_id': paymentInfo.transactionId,
      };
      final model = await _remoteDataSource.confirmBooking(
        bookingId,
        paymentInfoMap,
      );
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<HotelBooking> cancelBooking({
    required String bookingId,
    String? cancellationReason,
  }) async {
    try {
      final model = await _remoteDataSource.cancelBooking(
        bookingId,
        cancellationReason,
      );
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<HotelBooking> readBooking({
    required String bookingId,
  }) async {
    try {
      final model = await _remoteDataSource.readBooking(bookingId);
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  // Reference Data methods
  @override
  Future<List<Country>> getCountries() async {
    try {
      final data = await _remoteDataSource.getCountries();
      return data.map((item) => _mapCountryFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Region>> getRegions({int? countryId}) async {
    try {
      final data = await _remoteDataSource.getRegions(countryId: countryId);
      return data.map((item) => _mapRegionFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelType>> getHotelTypes() async {
    try {
      final data = await _remoteDataSource.getHotelTypes();
      return data.map((item) => _mapHotelTypeFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Facility>> getFacilities() async {
    try {
      final data = await _remoteDataSource.getFacilities();
      return data.map((item) => _mapFacilityFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Facility>> getHotelFacilities({required int hotelId}) async {
    try {
      // Step 1: Get facility_ids for this hotel from hotel-facilities API
      final hotelFacilitiesData =
          await _remoteDataSource.getHotelFacilities(hotelId);

      // Extract facility_ids
      final facilityIds = hotelFacilitiesData
          .map((item) => _parseInt(item['facility_id']))
          .where((id) => id > 0)
          .toSet();

      if (facilityIds.isEmpty) {
        return [];
      }

      // Step 2: Get all facilities with full details (names, icons) from facilities API
      final allFacilitiesData = await _remoteDataSource.getFacilities();
      final allFacilities =
          allFacilitiesData.map((item) => _mapFacilityFromMap(item)).toList();

      // Step 3: Match facility_ids with full facility details
      final matchedFacilities = allFacilities
          .where((facility) => facilityIds.contains(facility.id))
          .toList();

      return matchedFacilities;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Equipment>> getEquipment() async {
    try {
      final data = await _remoteDataSource.getEquipment();
      return data.map((item) => _mapEquipmentFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Equipment>> getRoomTypeEquipment({
    required int roomTypeId,
    int? hotelId,
  }) async {
    try {
      // Step 1: Get equipment_ids for this room type from room-equipment API
      final roomEquipmentData = await _remoteDataSource.getRoomTypeEquipment(
        roomTypeId,
        hotelId,
      );

      // Check if response already has full equipment details (has 'id' and 'names' fields)
      final hasFullDetails = roomEquipmentData.isNotEmpty &&
          roomEquipmentData.first.containsKey('id') &&
          (roomEquipmentData.first.containsKey('names') ||
              roomEquipmentData.first.containsKey('name'));

      if (hasFullDetails) {
        // API returned full details, map directly
        return roomEquipmentData
            .map((item) => _mapEquipmentFromMap(item))
            .toList();
      }

      // Step 2: Extract equipment_ids (similar to facilities)
      final equipmentIds = roomEquipmentData
          .map((item) => _parseInt(item['equipment_id'] ?? item['id']))
          .where((id) => id > 0)
          .toSet();

      if (equipmentIds.isEmpty) {
        return [];
      }

      // Step 3: Get all equipment with full details (names, icons) from equipment API
      final allEquipmentData = await _remoteDataSource.getEquipment();
      final allEquipment =
          allEquipmentData.map((item) => _mapEquipmentFromMap(item)).toList();

      // Step 4: Match equipment_ids with full equipment details
      final matchedEquipment = allEquipment
          .where((equipment) => equipmentIds.contains(equipment.id))
          .toList();

      return matchedEquipment;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Currency>> getCurrencies() async {
    try {
      final data = await _remoteDataSource.getCurrencies();
      // API might return Map with 'currencies' key or Map with currency codes as keys
      if (data.containsKey('currencies') && data['currencies'] is List) {
        final currenciesList = data['currencies'] as List<dynamic>;
        return currenciesList
            .map((item) => _mapCurrencyFromMap(item as Map<String, dynamic>))
            .toList();
      }
      // If Map keys are currency codes (e.g., {"USD": {...}, "UZS": {...}})
      if (data.isNotEmpty && data.values.every((v) => v is Map)) {
        return data.entries.map((entry) {
          final currencyData = entry.value as Map<String, dynamic>;
          final code = entry.key;
          final name = currencyData['name'] as String? ?? code;
          final symbol = currencyData['symbol'] as String?;
          final rate = (currencyData['rate'] as num?)?.toDouble();
          return Currency(code: code, name: name, symbol: symbol, rate: rate);
        }).toList();
      }
      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Star>> getStars() async {
    try {
      final data = await _remoteDataSource.getStars();
      return data.map((item) => _mapStarFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelPhoto>> getHotelPhotos({required int hotelId}) async {
    try {
      final data = await _remoteDataSource.getHotelPhotos(hotelId);
      return data.map((item) => _mapHotelPhotoFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelBooking>> getUserBookings() async {
    try {
      final models = await _remoteDataSource.getUserBookings();
      return models;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<RoomType>> getHotelRoomTypes({required int hotelId}) async {
    try {
      final data = await _remoteDataSource.getHotelRoomTypes(hotelId);
      return data.map((item) => _mapRoomTypeFromMap(item, hotelId)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelPhoto>> getHotelRoomPhotos({
    int? hotelId,
    int? roomTypeId,
  }) async {
    try {
      final data = await _remoteDataSource.getHotelRoomPhotos(
        hotelId: hotelId,
        roomTypeId: roomTypeId,
      );
      return data.map((item) => _mapHotelPhotoFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<PriceRange> getPriceRange() async {
    try {
      final data = await _remoteDataSource.getPriceRange();
      final minPrice = (data['min_price'] as num?)?.toDouble() ?? 0.0;
      final maxPrice = (data['max_price'] as num?)?.toDouble() ?? 10000000.0;
      final currency = data['currency'] as String? ?? 'uzs';

      List<PriceRangeItem>? priceRanges;
      if (data['price_ranges'] is List) {
        priceRanges = (data['price_ranges'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return PriceRangeItem(
              min: (item['min'] as num?)?.toDouble() ?? 0.0,
              max: (item['max'] as num?)?.toDouble() ?? 0.0,
              label: item['label'] as String?,
            );
          }
          return const PriceRangeItem(min: 0, max: 0);
        }).toList();
      }

      return PriceRange(
        minPrice: minPrice,
        maxPrice: maxPrice,
        currency: currency,
        priceRanges: priceRanges,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<NearbyPlaceType>> getNearbyPlacesTypes() async {
    try {
      final data = await _remoteDataSource.getNearbyPlacesTypes();
      return data.map((item) => _mapNearbyPlaceTypeFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<NearbyPlace>> getHotelNearbyPlaces({required int hotelId}) async {
    try {
      final data = await _remoteDataSource.getHotelNearbyPlaces(hotelId);
      return data.map((item) => _mapNearbyPlaceFromMap(item, hotelId)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<ServiceInRoom>> getServicesInRoom() async {
    try {
      final data = await _remoteDataSource.getServicesInRoom();
      return data.map((item) => _mapServiceInRoomFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<ServiceInRoom>> getHotelServicesInRoom(
      {required int hotelId}) async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 getHotelServicesInRoom: Starting for hotelId=$hotelId');
      }

      // Step 1: Get service_ids for this hotel from hotel-services-in-room API
      final hotelServicesData =
          await _remoteDataSource.getHotelServicesInRoom(hotelId);

      if (kDebugMode) {
        debugPrint(
            '🔍 getHotelServicesInRoom: hotelServicesData length=${hotelServicesData.length}');
        if (hotelServicesData.isNotEmpty) {
          debugPrint(
              '🔍 getHotelServicesInRoom: First item keys=${hotelServicesData.first.keys}');
          debugPrint(
              '🔍 getHotelServicesInRoom: First item=$hotelServicesData.first');
        }
      }

      if (hotelServicesData.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ getHotelServicesInRoom: hotelServicesData is empty');
        }
        return [];
      }

      // Check if response already has full service details (has 'id' and 'names' fields)
      final hasFullDetails = hotelServicesData.first.containsKey('id') &&
          (hotelServicesData.first.containsKey('names') ||
              hotelServicesData.first.containsKey('name'));

      if (kDebugMode) {
        debugPrint('🔍 getHotelServicesInRoom: hasFullDetails=$hasFullDetails');
      }

      if (hasFullDetails) {
        // API returned full details, map directly
        if (kDebugMode) {
          debugPrint('✅ getHotelServicesInRoom: Using full details from API');
        }
        return hotelServicesData
            .map((item) => _mapServiceInRoomFromMap(item))
            .toList();
      }

      // Step 2: Extract services_in_room_ids (similar to facilities)
      // API returns services_in_room_id field from hotel-services-in-room API
      final serviceIds = hotelServicesData
          .map((item) {
            // API returns 'services_in_room_id' field (not 'service_id' or 'id')
            final servicesInRoomId =
                item['services_in_room_id'] ?? item['service_id'] ?? item['id'];
            if (servicesInRoomId == null && kDebugMode) {
              debugPrint(
                  '⚠️ getHotelServicesInRoom: services_in_room_id not found in item=$item');
            }
            return _parseInt(servicesInRoomId);
          })
          .where((id) => id > 0)
          .toSet();

      if (kDebugMode) {
        debugPrint(
            '🔍 getHotelServicesInRoom: Extracted serviceIds=$serviceIds');
      }

      if (serviceIds.isEmpty) {
        // If no valid service_ids found, return empty list
        if (kDebugMode) {
          debugPrint('⚠️ getHotelServicesInRoom: No valid service_ids found');
        }
        return [];
      }

      // Step 3: Get all services with full details (names, icons) from services-in-room API
      final allServicesData = await _remoteDataSource.getServicesInRoom();

      if (kDebugMode) {
        debugPrint(
            '🔍 getHotelServicesInRoom: allServicesData length=${allServicesData.length}');
        if (allServicesData.isNotEmpty) {
          debugPrint(
              '🔍 getHotelServicesInRoom: First service keys=${allServicesData.first.keys}');
        }
      }

      final allServices = allServicesData
          .map((item) => _mapServiceInRoomFromMap(item))
          .toList();

      if (kDebugMode) {
        debugPrint(
            '🔍 getHotelServicesInRoom: allServices length=${allServices.length}');
        debugPrint(
            '🔍 getHotelServicesInRoom: allServices ids=${allServices.map((s) => s.id).toList()}');
      }

      // Step 4: Match service_ids with full service details
      final matchedServices = allServices
          .where((service) => serviceIds.contains(service.id))
          .toList();

      if (kDebugMode) {
        debugPrint(
            '✅ getHotelServicesInRoom: Matched ${matchedServices.length} services');
      }

      return matchedServices;
    } on AppException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ getHotelServicesInRoom: Error=$e');
      }
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<BedType>> getBedTypes() async {
    try {
      final data = await _remoteDataSource.getBedTypes();
      return data.map((item) => _mapBedTypeFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }
}
