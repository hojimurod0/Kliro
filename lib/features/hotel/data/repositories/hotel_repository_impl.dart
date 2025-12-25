import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/hotel_endpoints.dart';
import '../../../../core/network/hotel/hotel_dio_client.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_booking.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../models/search_request_model.dart';
import '../models/search_response_model.dart';
import '../models/hotel_model.dart';
import '../models/quote_model.dart';
import '../models/booking_model.dart';

class HotelRepositoryImpl implements HotelRepository {
  HotelRepositoryImpl({required HotelDioClient dioClient})
      : _dioClient = dioClient;

  final HotelDioClient _dioClient;

  // Search methods
  @override
  Future<HotelSearchResult> searchHotels({
    HotelFilter filter = HotelFilter.empty,
  }) async {
    try {
      final request = SearchRequestModel.fromFilter(filter);
      final requestBody = request.toJson(); // {"data": {...}}

      final response = await _dioClient.post(
        HotelEndpoints.searchHotels,
        data: requestBody,
      );

      final responseData = _ensureMap(response.data);

      // Parse API response format: {"success": true, "data": {...}}
      final model = SearchResponseModel.fromApiJson(
        responseData,
        filter: filter,
      );

      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<Hotel> getHotelDetails({required String hotelId}) async {
    try {
      // Hotelios API'da alohida hotel details endpoint yo'q
      // Search natijalaridan hotel details olish kerak
      // Yoki /hotels/list?hotel_id=123 endpoint'idan foydalanish mumkin

      final hotelIdInt = int.tryParse(hotelId);
      if (hotelIdInt == null) {
        throw ValidationException('Noto\'g\'ri hotel ID');
      }

      // /hotels/list endpoint'idan foydalanish
      final response = await _dioClient.post(
        HotelEndpoints.getHotelList,
        queryParameters: {'hotel_id': hotelIdInt},
        data: {},
      );

      final responseData = response.data;

      // Response format: List yoki {"data": [...]}
      List<dynamic>? hotelsData;
      if (responseData is List) {
        hotelsData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          hotelsData = responseData['data'] as List;
        } else if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          hotelsData = responseData['result'] as List;
        }
      }

      if (hotelsData != null && hotelsData.isNotEmpty) {
        final hotelData = hotelsData.first as Map<String, dynamic>;
        final model = HotelModel.fromJson(hotelData);
        return model;
      }

      throw ValidationException('Hotel topilmadi');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<String>> getCities({String? query}) async {
    try {
      // Hotelios API: POST /hotels/cities?country_id=1
      // Request body: {}
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) {
        // Agar query city name bo'lsa, uni country_id ga o'girish kerak
        // Hozircha query ni country_id sifatida ishlatamiz (agar int bo'lsa)
        final countryId = int.tryParse(query);
        if (countryId != null) {
          queryParams['country_id'] = countryId;
        }
      }

      final response = await _dioClient.post(
        HotelEndpoints.getCities,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        data: {},
      );

      final responseData = response.data;

      // API response format: List yoki {"data": [...]}
      if (responseData is List) {
        // Har bir city object: {"id": 67, "names": {"ru": "...", "uz": "...", "en": "..."}}
        return responseData.map((item) {
          if (item is Map<String, dynamic>) {
            final names = item['names'] as Map<String, dynamic>?;
            // Uzbek tilini qaytarish (yoki ru, en)
            return names?['uz'] as String? ??
                names?['ru'] as String? ??
                names?['en'] as String? ??
                item['name'] as String? ??
                item.toString();
          }
          return item.toString();
        }).toList();
      }

      if (responseData is Map<String, dynamic>) {
        List<dynamic>? cities;

        if (responseData.containsKey('data') && responseData['data'] is List) {
          cities = responseData['data'] as List;
        } else if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          cities = responseData['result'] as List;
        } else if (responseData.containsKey('cities') &&
            responseData['cities'] is List) {
          cities = responseData['cities'] as List;
        }

        if (cities != null) {
          return cities.map((item) {
            if (item is Map<String, dynamic>) {
              final names = item['names'] as Map<String, dynamic>?;
              return names?['uz'] as String? ??
                  names?['ru'] as String? ??
                  names?['en'] as String? ??
                  item['name'] as String? ??
                  item.toString();
            }
            return item.toString();
          }).toList();
        }
      }

      return [];
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
      final queryParams = <String, dynamic>{};
      if (countryId != null) {
        queryParams['country_id'] = countryId;
      } else {
        queryParams['country_id'] = 1; // Default: Uzbekistan
      }

      final response = await _dioClient.post(
        HotelEndpoints.getCities,
        queryParameters: queryParams,
        data: {},
      );

      final responseData = response.data;

      List<City> cities = [];

      if (responseData is List) {
        cities = responseData.map((item) {
          if (item is Map<String, dynamic>) {
            final id = item['id'] as int? ?? 0;
            final names = item['names'] as Map<String, dynamic>?;
            final nameMap = names != null
                ? Map<String, String>.from(
                    names.map((key, value) => MapEntry(key, value.toString())))
                : null;
            final name = nameMap?['uz'] ??
                nameMap?['ru'] ??
                nameMap?['en'] ??
                item['name'] as String? ??
                '';
            return City(id: id, name: name, names: nameMap);
          }
          return City(id: 0, name: item.toString());
        }).toList();
      } else if (responseData is Map<String, dynamic>) {
        List<dynamic>? citiesData;

        if (responseData.containsKey('data') && responseData['data'] is List) {
          citiesData = responseData['data'] as List;
        } else if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          citiesData = responseData['result'] as List;
        } else if (responseData.containsKey('cities') &&
            responseData['cities'] is List) {
          citiesData = responseData['cities'] as List;
        }

        if (citiesData != null) {
          cities = citiesData.map((item) {
            if (item is Map<String, dynamic>) {
              final id = item['id'] as int? ?? 0;
              final names = item['names'] as Map<String, dynamic>?;
              final nameMap = names != null
                  ? Map<String, String>.from(names
                      .map((key, value) => MapEntry(key, value.toString())))
                  : null;
              final name = nameMap?['uz'] ??
                  nameMap?['ru'] ??
                  nameMap?['en'] ??
                  item['name'] as String? ??
                  '';
              return City(id: id, name: name, names: nameMap);
            }
            return City(id: 0, name: item.toString());
          }).toList();
        }
      }

      return cities;
    } on AppException catch (e) {
      if (e is ServerException && e.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  // Booking Flow methods
  @override
  Future<HotelQuote> getQuote({
    required List<String> optionRefIds,
  }) async {
    try {
      final requestBody = {
        'data': {
          'options': optionRefIds.map((id) => {'option_ref_id': id}).toList(),
        },
      };

      final response = await _dioClient.post(
        HotelEndpoints.getQuote,
        data: requestBody,
      );

      final responseData = _ensureMap(response.data);
      final model = QuoteModel.fromJson(responseData);
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
      final response = await _dioClient.post(
        HotelEndpoints.createBooking,
        data: requestModel.toJson(),
      );

      final responseData = _ensureMap(response.data);
      final model = HotelBookingModel.fromJson(responseData);
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
      final requestBody = {
        'data': {
          'booking_id': bookingId,
          'payment_info': {
            'payment_method': paymentInfo.paymentMethod,
            if (paymentInfo.cardNumber != null)
              'card_number': paymentInfo.cardNumber,
            if (paymentInfo.transactionId != null)
              'transaction_id': paymentInfo.transactionId,
          },
        },
      };

      final response = await _dioClient.post(
        HotelEndpoints.confirmBooking,
        data: requestBody,
      );

      final responseData = _ensureMap(response.data);
      final model = HotelBookingModel.fromJson(responseData);
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
      final requestBody = {
        'data': {
          'booking_id': bookingId,
          if (cancellationReason != null)
            'cancellation_reason': cancellationReason,
        },
      };

      final response = await _dioClient.post(
        HotelEndpoints.cancelBooking,
        data: requestBody,
      );

      final responseData = _ensureMap(response.data);
      final model = HotelBookingModel.fromJson(responseData);
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
      final requestBody = {
        'data': {
          'booking_id': bookingId,
        },
      };

      final response = await _dioClient.post(
        HotelEndpoints.readBooking,
        data: requestBody,
      );

      final responseData = _ensureMap(response.data);
      final model = HotelBookingModel.fromJson(responseData);
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
      final response = await _dioClient.post(
        HotelEndpoints.getCountries,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? countriesData;

      if (responseData is List) {
        countriesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        countriesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['countries'] as List<dynamic>?;
      }

      if (countriesData == null) return [];

      return countriesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final code = item['code'] as String?;
          return Country(id: id, name: name, names: nameMap, code: code);
        }
        return Country(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Region>> getRegions({int? countryId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (countryId != null) {
        queryParams['country_id'] = countryId;
      }

      final response = await _dioClient.post(
        HotelEndpoints.getRegions,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? regionsData;

      if (responseData is List) {
        regionsData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        regionsData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['regions'] as List<dynamic>?;
      }

      if (regionsData == null) return [];

      return regionsData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final countryId = item['country_id'] as int?;
          return Region(
              id: id, name: name, names: nameMap, countryId: countryId);
        }
        return Region(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelType>> getHotelTypes() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getHotelTypes,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? typesData;

      if (responseData is List) {
        typesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        typesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['types'] as List<dynamic>?;
      }

      if (typesData == null) return [];

      return typesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          return HotelType(id: id, name: name, names: nameMap);
        }
        return HotelType(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Facility>> getFacilities() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getFacilities,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? facilitiesData;

      if (responseData is List) {
        facilitiesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        facilitiesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['facilities'] as List<dynamic>?;
      }

      if (facilitiesData == null) return [];

      return facilitiesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return Facility(id: id, name: name, names: nameMap, icon: icon);
        }
        return Facility(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Facility>> getHotelFacilities({required int hotelId}) async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getHotelFacilities,
        queryParameters: {'hotel_id': hotelId},
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? facilitiesData;

      if (responseData is List) {
        facilitiesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        facilitiesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['facilities'] as List<dynamic>?;
      }

      if (facilitiesData == null) return [];

      return facilitiesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return Facility(id: id, name: name, names: nameMap, icon: icon);
        }
        return Facility(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Equipment>> getEquipment() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getEquipment,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? equipmentData;

      if (responseData is List) {
        equipmentData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        equipmentData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['equipment'] as List<dynamic>?;
      }

      if (equipmentData == null) return [];

      return equipmentData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return Equipment(id: id, name: name, names: nameMap, icon: icon);
        }
        return Equipment(id: 0, name: item.toString());
      }).toList();
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
      final queryParams = <String, dynamic>{
        'room_type_id': roomTypeId,
      };
      if (hotelId != null) {
        queryParams['hotel_id'] = hotelId;
      }

      final response = await _dioClient.post(
        HotelEndpoints.getRoomTypeEquipment,
        queryParameters: queryParams,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? equipmentData;

      if (responseData is List) {
        equipmentData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        equipmentData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['equipment'] as List<dynamic>?;
      }

      if (equipmentData == null) return [];

      return equipmentData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return Equipment(id: id, name: name, names: nameMap, icon: icon);
        }
        return Equipment(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Currency>> getCurrencies() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getCurrencies,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? currenciesData;

      if (responseData is List) {
        currenciesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        currenciesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['currencies'] as List<dynamic>?;
      }

      if (currenciesData == null) return [];

      return currenciesData.map((item) {
        if (item is Map<String, dynamic>) {
          final code = item['code'] as String? ?? '';
          final name = item['name'] as String? ?? code;
          final symbol = item['symbol'] as String?;
          final rate = (item['rate'] as num?)?.toDouble();
          return Currency(code: code, name: name, symbol: symbol, rate: rate);
        }
        return Currency(code: item.toString(), name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<Star>> getStars() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getStars,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? starsData;

      if (responseData is List) {
        starsData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        starsData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['stars'] as List<dynamic>?;
      }

      if (starsData == null) return [];

      return starsData.map((item) {
        if (item is Map<String, dynamic>) {
          final value = item['value'] as int? ?? item['id'] as int? ?? 0;
          final name = item['name'] as String?;
          return Star(value: value, name: name);
        } else if (item is int) {
          return Star(value: item);
        }
        return Star(value: 0);
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelPhoto>> getHotelPhotos({required int hotelId}) async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getHotelPhotos,
        queryParameters: {'hotel_id': hotelId},
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? photosData;

      if (responseData is List) {
        photosData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        photosData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['photos'] as List<dynamic>?;
      }

      if (photosData == null) return [];

      return photosData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final url =
              item['url'] as String? ?? item['photo_url'] as String? ?? '';
          final thumbnailUrl = item['thumbnail_url'] as String?;
          final description = item['description'] as String?;
          final category = item['category'] as String?;
          return HotelPhoto(
            id: id,
            url: url,
            thumbnailUrl: thumbnailUrl,
            description: description,
            category: category,
          );
        }
        return HotelPhoto(id: 0, url: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<HotelBooking>> getUserBookings() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getUserBookings,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? bookingsData;

      if (responseData is List) {
        bookingsData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        bookingsData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['bookings'] as List<dynamic>?;
      }

      if (bookingsData == null) return [];

      return bookingsData.map((item) {
        if (item is Map<String, dynamic>) {
          return HotelBookingModel.fromJson(item);
        }
        throw const ParsingException('Noto\'g\'ri booking format');
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<RoomType>> getHotelRoomTypes({required int hotelId}) async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getHotelRoomTypes,
        queryParameters: {'hotel_id': hotelId},
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? roomTypesData;

      if (responseData is List) {
        roomTypesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        roomTypesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['room_types'] as List<dynamic>?;
      }

      if (roomTypesData == null) return [];

      return roomTypesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
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
        return RoomType(id: 0, name: item.toString());
      }).toList();
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
      final queryParams = <String, dynamic>{};
      if (hotelId != null) queryParams['hotel_id'] = hotelId;
      if (roomTypeId != null) queryParams['room_type_id'] = roomTypeId;

      final response = await _dioClient.post(
        HotelEndpoints.getHotelRoomPhotos,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? photosData;

      if (responseData is List) {
        photosData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        photosData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['photos'] as List<dynamic>?;
      }

      if (photosData == null) return [];

      return photosData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final url = item['url'] as String? ?? '';
          final thumbnailUrl = item['thumbnail_url'] as String?;
          final description = item['description'] as String?;
          final category = item['type'] as String? ?? 'room';
          return HotelPhoto(
            id: id,
            url: url,
            thumbnailUrl: thumbnailUrl,
            description: description,
            category: category,
          );
        }
        return const HotelPhoto(id: 0, url: '');
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<PriceRange> getPriceRange() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getPriceRange,
        data: {},
      );

      final responseData = response.data;
      Map<String, dynamic>? data;

      if (responseData is Map<String, dynamic>) {
        data = responseData['data'] as Map<String, dynamic>? ??
            responseData['result'] as Map<String, dynamic>? ??
            responseData;
      }

      if (data == null) {
        throw const ParsingException('Price range ma\'lumotlari topilmadi');
      }

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
      final response = await _dioClient.post(
        HotelEndpoints.getNearbyPlacesTypes,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? typesData;

      if (responseData is List) {
        typesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        typesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['types'] as List<dynamic>?;
      }

      if (typesData == null) return [];

      return typesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return NearbyPlaceType(
              id: id, name: name, names: nameMap, icon: icon);
        }
        return NearbyPlaceType(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<NearbyPlace>> getHotelNearbyPlaces({required int hotelId}) async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getHotelNearbyPlaces,
        queryParameters: {'hotel_id': hotelId},
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? placesData;

      if (responseData is List) {
        placesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        placesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['nearby_places'] as List<dynamic>?;
      }

      if (placesData == null) return [];

      return placesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final typeId = item['type_id'] as int?;
          final distance = (item['distance'] as num?)?.toDouble();
          final coordinates = item['coordinates'] as Map<String, dynamic>?;
          Map<String, double>? coordsMap;
          if (coordinates != null) {
            coordsMap = coordinates.map((key, value) =>
                MapEntry(key, (value as num?)?.toDouble() ?? 0.0));
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
        return NearbyPlace(id: 0, name: item.toString(), hotelId: hotelId);
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<ServiceInRoom>> getServicesInRoom() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getServicesInRoom,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? servicesData;

      if (responseData is List) {
        servicesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        servicesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['services'] as List<dynamic>?;
      }

      if (servicesData == null) return [];

      return servicesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return ServiceInRoom(id: id, name: name, names: nameMap, icon: icon);
        }
        return ServiceInRoom(id: 0, name: item.toString());
      }).toList();
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
      final response = await _dioClient.post(
        HotelEndpoints.getHotelServicesInRoom,
        queryParameters: {'hotel_id': hotelId},
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? servicesData;

      if (responseData is List) {
        servicesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        servicesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['services'] as List<dynamic>?;
      }

      if (servicesData == null) return [];

      return servicesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return ServiceInRoom(id: id, name: name, names: nameMap, icon: icon);
        }
        return ServiceInRoom(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  @override
  Future<List<BedType>> getBedTypes() async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getBedTypes,
        data: {},
      );

      final responseData = response.data;
      List<dynamic>? bedTypesData;

      if (responseData is List) {
        bedTypesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        bedTypesData = responseData['data'] as List<dynamic>? ??
            responseData['result'] as List<dynamic>? ??
            responseData['bed_types'] as List<dynamic>?;
      }

      if (bedTypesData == null) return [];

      return bedTypesData.map((item) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final names = item['names'] as Map<String, dynamic>?;
          final nameMap = names != null
              ? Map<String, String>.from(
                  names.map((key, value) => MapEntry(key, value.toString())))
              : null;
          final name = nameMap?['uz'] ??
              nameMap?['ru'] ??
              nameMap?['en'] ??
              item['name'] as String? ??
              '';
          final icon = item['icon'] as String?;
          return BedType(id: id, name: name, names: nameMap, icon: icon);
        }
        return BedType(id: 0, name: item.toString());
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ma\'lumotlarni qayta ishlashda xatolik: $e');
    }
  }

  Map<String, dynamic> _ensureMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ParsingException('Server javobi noto\'g\'ri formatda');
  }
}
