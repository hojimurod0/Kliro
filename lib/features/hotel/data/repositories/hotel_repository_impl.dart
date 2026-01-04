import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
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
  // Helper methods for mapping
  Map<String, String>? _extractNameMap(Map<String, dynamic> item) {
    final names = item['names'];
    if (names is Map) {
      return Map<String, String>.from(
        names.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }
    return null;
  }

  String _extractName(Map<String, String>? nameMap, Map<String, dynamic> item) {
    return nameMap?['uz'] ??
        nameMap?['ru'] ??
        nameMap?['en'] ??
        item['name']?.toString() ??
        item['title']?.toString() ??
        item['label']?.toString() ??
        item['text']?.toString() ??
        item['value']?.toString() ??
        item['description']?.toString() ??
        item['content']?.toString() ??
        '';
  }

  City _mapCityFromMap(Map<String, dynamic> item) {
    final id = (item['id'] ?? item['city_id']) is int
        ? (item['id'] ?? item['city_id']) as int
        : int.tryParse(
                (item['id'] ?? item['city_id'])?.toString() ?? '') ??
            0;

    // names could be under 'names' or 'translations'
    final dynamic rawNames = item['names'] ?? item['translations'];
    Map<String, String>? nameMap;
    if (rawNames is Map) {
      nameMap = rawNames.map(
          (key, value) => MapEntry(key.toString(), value.toString()));
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
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final code = item['code'] as String?;
    return Country(id: id, name: name, names: nameMap, code: code);
  }

  Region _mapRegionFromMap(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final countryId = item['country_id'] as int?;
    return Region(id: id, name: name, names: nameMap, countryId: countryId);
  }

  HotelType _mapHotelTypeFromMap(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    return HotelType(id: id, name: name, names: nameMap);
  }

  Facility _mapFacilityFromMap(Map<String, dynamic> item) {
    debugPrint('🧐 Facility Item: $item');
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = item['icon'] as String?;
    return Facility(id: id, name: name, names: nameMap, icon: icon);
  }

  Equipment _mapEquipmentFromMap(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = item['icon'] as String?;
    return Equipment(id: id, name: name, names: nameMap, icon: icon);
  }

  Currency _mapCurrencyFromMap(Map<String, dynamic> item) {
    final code = item['code'] as String? ?? '';
    final name = item['name'] as String? ?? code;
    final symbol = item['symbol'] as String?;
    final rate = (item['rate'] as num?)?.toDouble();
    return Currency(code: code, name: name, symbol: symbol, rate: rate);
  }

  Star _mapStarFromMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      final value = item['value'] as int? ?? item['id'] as int? ?? 0;
      final name = item['name'] as String?;
      return Star(value: value, name: name);
    } else if (item is int) {
      return Star(value: item);
    }
    return const Star(value: 0);
  }

  HotelPhoto _mapHotelPhotoFromMap(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    // API javobida 'link' maydoni bor
    final url = item['link'] as String? ??
        item['url'] as String? ??
        item['photo_url'] as String? ??
        item['image_url'] as String? ??
        '';
    final thumbnailUrl = item['thumbnail_url'] as String?;
    final description = item['description'] as String?;
    final category = item['category'] as String? ??
        item['type'] as String? ??
        'general';
    final isDefault = item['default'] as bool? ?? 
        item['is_default'] as bool? ?? 
        item['isDefault'] as bool? ?? 
        false;
    
    debugPrint('🔍 HotelPhoto: id=$id, url=$url, isDefault=$isDefault');
    
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
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final maxOccupancy = item['max_occupancy'] as int?;
    final description = item['description'] as String?;
    return RoomType(
      id: id,
      name: name,
      names: nameMap,
      hotelId: hotelId,
      maxOccupancy: maxOccupancy,
      description: description,
    );
  }

  NearbyPlaceType _mapNearbyPlaceTypeFromMap(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = item['icon'] as String?;
    return NearbyPlaceType(id: id, name: name, names: nameMap, icon: icon);
  }

  NearbyPlace _mapNearbyPlaceFromMap(Map<String, dynamic> item, int hotelId) {
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final typeId = item['type_id'] as int?;
    final distance = (item['distance'] as num?)?.toDouble();
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
    debugPrint('🧐 ServiceInRoom Item: $item');
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = item['icon'] as String?;
    return ServiceInRoom(id: id, name: name, names: nameMap, icon: icon);
  }

  BedType _mapBedTypeFromMap(Map<String, dynamic> item) {
    final id = item['id'] as int? ?? 0;
    final nameMap = _extractNameMap(item);
    final name = _extractName(nameMap, item);
    final icon = item['icon'] as String?;
    return BedType(id: id, name: name, names: nameMap, icon: icon);
  }

  /// Загружает фотографии для списка отелей параллельно
  Future<List<HotelModel>> _loadPhotosForHotels(List<HotelModel> hotels) async {
    debugPrint('📸 Загрузка фотографий для ${hotels.length} отелей...');
    
    // Загружаем фотографии параллельно для всех отелей
    final hotelsWithPhotos = await Future.wait(
      hotels.map((hotel) async {
        try {
          // Remote data source dan Map list olamiz
          final photosData = await _remoteDataSource.getHotelPhotos(hotel.hotelId);
          debugPrint('✅ getHotelPhotos: Получено ${photosData.length} фотографий (raw data) для отеля ${hotel.hotelId}');
          
          // Map'larni HotelPhoto entity'larga aylantiramiz
          final photos = photosData.map((item) {
            try {
              return _mapHotelPhotoFromMap(item);
            } catch (e) {
              debugPrint('⚠️ Ошибка mapping фотографии для отеля ${hotel.hotelId}: $e');
              debugPrint('⚠️ Photo data: $item');
              return null;
            }
          }).whereType<HotelPhoto>().toList();
          
          debugPrint('✅ Загружено ${photos.length} фотографий для отеля ${hotel.hotelId} (${hotel.name})');
          
          // Если есть фотографии, обновляем отель
          if (photos.isNotEmpty) {
            // Если у отеля нет imageUrl, используем первую фотографию
            final imageUrl = hotel.imageUrl?.isNotEmpty == true 
                ? hotel.imageUrl 
                : (photos.first.url.isNotEmpty ? photos.first.url : null);
            
            if (imageUrl != null && imageUrl.isNotEmpty) {
              debugPrint('📸 Отель ${hotel.hotelId} (${hotel.name}): Установлен imageUrl = $imageUrl');
            }
            
            return hotel.copyWith(
              photos: photos,
              imageUrl: imageUrl,
            ) as HotelModel;
          } else {
            debugPrint('⚠️ Отель ${hotel.hotelId} (${hotel.name}): Фотографий не найдено');
          }
          return hotel;
        } catch (e, stackTrace) {
          debugPrint('⚠️ Ошибка загрузки фотографий для отеля ${hotel.hotelId} (${hotel.name}): $e');
          debugPrint('❌ StackTrace: $stackTrace');
          return hotel;
        }
      }),
    );
    
    final hotelsWithPhotosCount = hotelsWithPhotos.where((h) => h.photos?.isNotEmpty == true).length;
    debugPrint('✅ Загрузка фотографий завершена: ${hotelsWithPhotosCount} из ${hotelsWithPhotos.length} отелей имеют фотографии');
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
          debugPrint('🔍 Mehmonxona ma\'lumotlarini to\'ldirish...');
          debugPrint('🔍 To\'ldirish kerak bo\'lgan mehmonxonalar: ${model.hotels.length}');
          
          try {
            // /hotels/list API dan to'liq ma'lumotlarni olamiz
            final cityId = filter.cityId;
            // _remoteDataSource.getHotelsList returns List<HotelModel>
            final toLiqMehmonxonalar = await _remoteDataSource.getHotelsList(
              cityId: cityId,
            );
            
            debugPrint('🔍 /hotels/list dan olingan mehmonxonalar: ${toLiqMehmonxonalar.length}');
            
            // hotelId bo'yicha tez qidirish uchun Map yaratamiz
            final mehmonxonalarMap = <int, HotelModel>{};
            for (final mehmonxona in toLiqMehmonxonalar) {
              mehmonxonalarMap[mehmonxona.hotelId] = mehmonxona;
            }
            
            // Ma'lumotlarni birlashtiramiz: to'liq ma'lumotlar + narxlar/opsiyalar
            final toLiqHotellar = model.hotels.map((qidiruvMehmonxonasi) {
              final toLiqMehmonxona = mehmonxonalarMap[qidiruvMehmonxonasi.hotelId];
              
              if (toLiqMehmonxona != null) {
                debugPrint('✅ Mehmonxona ${qidiruvMehmonxonasi.hotelId} to\'ldirildi: "${toLiqMehmonxona.name}"');
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
                debugPrint('⚠️ Mehmonxona ${qidiruvMehmonxonasi.hotelId} /hotels/list da topilmadi');
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
            final hotelsWithPhotos = await _loadPhotosForHotels(toLiqModel.hotels);
            final finalModel = SearchResponseModel(
              hotels: hotelsWithPhotos,
              total: toLiqModel.total,
              page: toLiqModel.page,
              pageSize: toLiqModel.pageSize,
            );
            
            return finalModel.toEntity();
          } catch (e) {
            debugPrint('❌ Mehmonxona ma\'lumotlarini to\'ldirishda xatolik: $e');
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
          debugPrint('📸 Загружаем фотографии для отелей (ma\'lumotlar to\'liq)...');
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
        debugPrint('📸 Загружаем фотографии для отелей (fallback)...');
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
    try {
      final data = await _remoteDataSource.getCitiesWithIds(
        countryId: countryId ?? 1, // Default: Uzbekistan
      );

      debugPrint('🔍 Repository.getCitiesWithIds: Received ${data.length} items from API');
      if (data.isNotEmpty) {
        debugPrint('🔍 Repository.getCitiesWithIds: First item keys = ${data.first.keys}');
      }
      final cities = data.map((item) => _mapCityFromMap(item)).toList();
      debugPrint('✅ Repository.getCitiesWithIds: Mapped ${cities.length} cities');
      if (cities.isNotEmpty) {
        debugPrint('🔍 Repository.getCitiesWithIds: First city = ${cities.first.name} (id: ${cities.first.id})');
      }
      return cities;
    } on AppException catch (e) {
      if ((e is ServerException && e.statusCode == 404) || e.message.contains('404')) {
        // Return fallback cities if API is missing (404)
        final fallbackCities = [
          {'id': 1, 'name': 'Toshkent', 'names': {'uz': 'Toshkent', 'ru': 'Ташкент', 'en': 'Tashkent'}},
          {'id': 2, 'name': 'Samarqand', 'names': {'uz': 'Samarqand', 'ru': 'Самарканд', 'en': 'Samarkand'}},
          {'id': 3, 'name': 'Buxoro', 'names': {'uz': 'Buxoro', 'ru': 'Бухара', 'en': 'Bukhara'}},
          {'id': 4, 'name': 'Xiva', 'names': {'uz': 'Xiva', 'ru': 'Хива', 'en': 'Khiva'}},
          {'id': 5, 'name': 'Namangan', 'names': {'uz': 'Namangan', 'ru': 'Наманган', 'en': 'Namangan'}},
          {'id': 6, 'name': 'Andijon', 'names': {'uz': 'Andijon', 'ru': 'Андижан', 'en': 'Andijan'}},
          {'id': 7, 'name': 'Farg\'ona', 'names': {'uz': 'Farg\'ona', 'ru': 'Фергана', 'en': 'Fergana'}},
          {'id': 8, 'name': 'Nukus', 'names': {'uz': 'Nukus', 'ru': 'Нукус', 'en': 'Nukus'}},
        ];
        return fallbackCities.map((item) => _mapCityFromMap(item)).toList();
      }
      rethrow;
    } catch (e) {
      if (e.toString().contains('404')) {
         final fallbackCities = [
          {'id': 1, 'name': 'Toshkent', 'names': {'uz': 'Toshkent', 'ru': 'Ташкент', 'en': 'Tashkent'}},
          {'id': 2, 'name': 'Samarqand', 'names': {'uz': 'Samarqand', 'ru': 'Самарканд', 'en': 'Samarkand'}},
          {'id': 3, 'name': 'Buxoro', 'names': {'uz': 'Buxoro', 'ru': 'Бухара', 'en': 'Bukhara'}},
          {'id': 4, 'name': 'Xiva', 'names': {'uz': 'Xiva', 'ru': 'Хива', 'en': 'Khiva'}},
          {'id': 5, 'name': 'Namangan', 'names': {'uz': 'Namangan', 'ru': 'Наманган', 'en': 'Namangan'}},
          {'id': 6, 'name': 'Andijon', 'names': {'uz': 'Andijon', 'ru': 'Андижан', 'en': 'Andijan'}},
          {'id': 7, 'name': 'Farg\'ona', 'names': {'uz': 'Farg\'ona', 'ru': 'Фергана', 'en': 'Fergana'}},
          {'id': 8, 'name': 'Nukus', 'names': {'uz': 'Nukus', 'ru': 'Нукус', 'en': 'Nukus'}},
        ];
        return fallbackCities.map((item) => _mapCityFromMap(item)).toList();
      }
      debugPrint('HotelRepositoryImpl error: $e');
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
      final data = await _remoteDataSource.getHotelFacilities(hotelId);
      return data.map((item) => _mapFacilityFromMap(item)).toList();
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
      final data = await _remoteDataSource.getRoomTypeEquipment(
        roomTypeId,
        hotelId,
      );
      return data.map((item) => _mapEquipmentFromMap(item)).toList();
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
      final data = await _remoteDataSource.getHotelServicesInRoom(hotelId);
      return data.map((item) => _mapServiceInRoomFromMap(item)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
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
