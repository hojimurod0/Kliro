import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/hotel/hotel_dio_client.dart';
import '../../../../core/constants/hotel_endpoints.dart';
import '../models/search_request_model.dart';
import '../models/search_response_model.dart';
import '../models/hotel_model.dart';
import '../models/quote_model.dart';
import '../models/booking_model.dart';

abstract class HotelRemoteDataSource {
  Future<SearchResponseModel> searchHotels(SearchRequestModel request);
  Future<HotelModel> getHotelDetails(String hotelId);
  Future<List<String>> getCities({String? query});
  Future<List<Map<String, dynamic>>> getCitiesWithIds({int? countryId});
  Future<List<HotelModel>> getHotelsList({
    int? hotelTypeId,
    int? countryId,
    int? regionId,
    int? cityId,
  });
  Future<QuoteModel> getQuote(List<String> optionRefIds);
  Future<HotelBookingModel> createBooking(CreateBookingRequestModel request);
  Future<HotelBookingModel> confirmBooking(String bookingId, Map<String, dynamic> paymentInfo);
  Future<HotelBookingModel> cancelBooking(String bookingId, String? cancellationReason);
  Future<HotelBookingModel> readBooking(String bookingId);
  Future<List<HotelBookingModel>> getUserBookings();
  Future<List<Map<String, dynamic>>> getCountries();
  Future<List<Map<String, dynamic>>> getRegions({int? countryId});
  Future<List<Map<String, dynamic>>> getHotelTypes();
  Future<List<Map<String, dynamic>>> getFacilities();
  Future<List<Map<String, dynamic>>> getHotelFacilities(int hotelId);
  Future<List<Map<String, dynamic>>> getEquipment();
  Future<List<Map<String, dynamic>>> getRoomTypeEquipment(int roomTypeId, int? hotelId);
  Future<Map<String, dynamic>> getCurrencies();
  Future<List<Map<String, dynamic>>> getStars();
  Future<List<Map<String, dynamic>>> getHotelPhotos(int hotelId);
  Future<List<Map<String, dynamic>>> getHotelRoomTypes(int hotelId);
  Future<List<Map<String, dynamic>>> getHotelRoomPhotos({int? hotelId, int? roomTypeId});
  Future<Map<String, dynamic>> getPriceRange();
  Future<List<Map<String, dynamic>>> getNearbyPlacesTypes();
  Future<List<Map<String, dynamic>>> getHotelNearbyPlaces(int hotelId);
  Future<List<Map<String, dynamic>>> getServicesInRoom();
  Future<List<Map<String, dynamic>>> getHotelServicesInRoom(int hotelId);
  Future<List<Map<String, dynamic>>> getBedTypes();
}

class HotelRemoteDataSourceImpl implements HotelRemoteDataSource {
  HotelRemoteDataSourceImpl({required HotelDioClient dioClient})
      : _dioClient = dioClient;

  final HotelDioClient _dioClient;

  Map<String, dynamic> _ensureMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ParsingException('Server javobi noto\'g\'ri formatda');
  }

  @override
  Future<SearchResponseModel> searchHotels(SearchRequestModel request) async {
    final requestBody = request.toJson();

    final response = await _dioClient.post(
      HotelEndpoints.searchHotels,
      data: requestBody,
    );

    final responseData = _ensureMap(response.data);
    return SearchResponseModel.fromApiJson(responseData, filter: request.occupancies != null && request.occupancies!.isNotEmpty
        ? null // We'll need to reconstruct filter if needed
        : null);
  }

  @override
  Future<HotelModel> getHotelDetails(String hotelId) async {
    final response = await _dioClient.get(
      HotelEndpoints.getHotelDetails(hotelId),
    );

    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return HotelModel.fromApiJson(data);
  }

  @override
  Future<List<String>> getCities({String? query}) async {
    final response = await _dioClient.post(
      HotelEndpoints.getCities,
      queryParameters: query != null ? {'query': query} : null,
    );

    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => e.toString()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getCitiesWithIds({int? countryId}) async {
    debugPrint('🔍 HotelRemoteDataSource: getCitiesWithIds called with countryId: $countryId');
    debugPrint('🔍 HotelRemoteDataSource: Endpoint: ${HotelEndpoints.getCitiesWithIds}');
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getCitiesWithIds,
        queryParameters: countryId != null ? {'country_id': countryId} : null,
      );
      debugPrint('✅ HotelRemoteDataSource: Response status: ${response.statusCode}');
      debugPrint('🔍 HotelRemoteDataSource: Response data type: ${response.data.runtimeType}');
      
      if (response.data is List) {
        final list = (response.data as List).map((e) => e as Map<String, dynamic>).toList();
        debugPrint('✅ HotelRemoteDataSource: Response is List, returning ${list.length} items');
        if (list.isNotEmpty) {
          debugPrint('🔍 HotelRemoteDataSource: First item: ${list.first}');
        }
        return list;
      }

      final responseData = _ensureMap(response.data);
      debugPrint('🔍 HotelRemoteDataSource: Response data keys: ${responseData.keys.toList()}');
      dynamic data = responseData['data'];

      // If data is a Map, try to find the list inside
      if (data is Map) {
        debugPrint('🔍 HotelRemoteDataSource: Data is Map, keys: ${data.keys.toList()}');
        if (data['result'] is List) {
          data = data['result'];
          debugPrint('✅ HotelRemoteDataSource: Found list in "result" key');
        } else if (data['cities'] is List) {
          data = data['cities'];
          debugPrint('✅ HotelRemoteDataSource: Found list in "cities" key');
        } else if (data['items'] is List) {
          data = data['items'];
          debugPrint('✅ HotelRemoteDataSource: Found list in "items" key');
        } else {
          // Fallback: search for any list in values
          for (final value in data.values) {
            if (value is List) {
              data = value;
              debugPrint('✅ HotelRemoteDataSource: Found list in Map values');
              break;
            }
          }
        }
      }

      final listData = data as List<dynamic>? ?? [];
      debugPrint('✅ HotelRemoteDataSource: Returning ${listData.length} cities');
      if (listData.isNotEmpty) {
        debugPrint('🔍 HotelRemoteDataSource: First item: ${listData.first}');
      }
      return listData.map((e) => e as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ HotelRemoteDataSource: Exception - $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<HotelModel>> getHotelsList({
    int? hotelTypeId,
    int? countryId,
    int? regionId,
    int? cityId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (hotelTypeId != null) queryParams['hotel_type_id'] = hotelTypeId;
    if (countryId != null) queryParams['country_id'] = countryId;
    if (cityId != null) queryParams['city_id'] = cityId;
    // queryParams['mode'] = 'search';

    var response = await _dioClient.post(
      HotelEndpoints.getHotelList,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    
    // If response is empty and we were doing a general search, try specific fallback for Tashkent
    final isEmpty = response.data == null || 
         (response.data is List && (response.data as List).isEmpty) ||
         (response.data is Map && (response.data as Map).isEmpty);
    
    if (isEmpty && cityId == null && countryId == null) {
        // Try getting Tashkent hotels directly as fallback content
        response = await _dioClient.post(
          HotelEndpoints.getHotelList,
          queryParameters: {'city_id': 1}, // Tashkent
        );
    }

    // Handle both { data: [...] } and [...] formats
    List<dynamic> data = [];
    if (response.data is List) {
      data = response.data as List<dynamic>;
    } else if (response.data is Map) {
      final responseData = response.data as Map<String, dynamic>;
      
      // Try different possible keys
      if (responseData['data'] is List) {
        data = responseData['data'] as List<dynamic>;
      } else if (responseData['data'] is Map) {
        // If data is a Map, check for hotels inside
        final dataMap = responseData['data'] as Map<String, dynamic>;
        if (dataMap['hotels'] is List) {
          data = dataMap['hotels'] as List<dynamic>;
        } else if (dataMap['items'] is List) {
          data = dataMap['items'] as List<dynamic>;
        } else if (dataMap['result'] is List) {
          data = dataMap['result'] as List<dynamic>;
        }
      } else if (responseData['hotels'] is List) {
        data = responseData['hotels'] as List<dynamic>;
      } else if (responseData['items'] is List) {
        data = responseData['items'] as List<dynamic>;
      } else if (responseData['result'] is List) {
        data = responseData['result'] as List<dynamic>;
      } else {
        // Fallback: search for any list in values
        for (final entry in responseData.entries) {
          if (entry.value is List) {
            data = entry.value as List<dynamic>;
            break;
          } else if (entry.value is Map) {
            // Check inside nested maps
            final nestedMap = entry.value as Map<String, dynamic>;
            for (final nestedEntry in nestedMap.entries) {
              if (nestedEntry.value is List) {
                data = nestedEntry.value as List<dynamic>;
                break;
              }
            }
            if (data.isNotEmpty) break;
          }
        }
      }
    }
    
    if (data.isEmpty) {
      return [];
    }
    
    // Parse hotels with error handling
    final hotels = <HotelModel>[];
    for (int i = 0; i < data.length; i++) {
      try {
        final item = data[i];
        Map<String, dynamic> hotelMap;
        
        // Handle different formats
        if (item is Map<String, dynamic>) {
          hotelMap = item;
        } else if (item is List && item.isNotEmpty) {
          // If item is a List, try to get the first element
          final firstElement = item[0];
          if (firstElement is Map<String, dynamic>) {
            hotelMap = firstElement;
          } else {
            continue;
          }
        } else {
          continue;
        }
        
        final hotel = HotelModel.fromApiJson(hotelMap);
        hotels.add(hotel);
      } catch (e) {
        // Skip invalid hotel entries
        continue;
      }
    }
    
    return hotels;
  }

  @override
  Future<QuoteModel> getQuote(List<String> optionRefIds) async {
    try {
      final options =
          optionRefIds.map((id) => {'option_ref_id': id}).toList(growable: false);
      
      if (kDebugMode) {
        debugPrint('📤 HotelQuote Request: optionRefIds=$optionRefIds');
      }
      
      final response = await _dioClient.post(
        HotelEndpoints.getQuote,
        data: {'data': {'options': options}},
      );

      if (kDebugMode) {
        debugPrint('📥 HotelQuote Response: ${response.data.toString()}');
      }

      // Handle response data - it might be wrapped in 'data' or direct
      Map<String, dynamic> responseData;
      try {
        responseData = _ensureMap(response.data);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ HotelRemoteDataSourceImpl.getQuote: Failed to parse response.data: $e');
          debugPrint('❌ Response.data type: ${response.data.runtimeType}');
          debugPrint('❌ Response.data value: ${response.data}');
        }
        throw const ParsingException('Server javobi noto\'g\'ri formatda');
      }
      
      // Check if response has 'data' wrapper
      Map<String, dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] is Map) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }
      
      // Parse QuoteModel with error handling
      try {
        return QuoteModel.fromJson(data);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ HotelRemoteDataSourceImpl.getQuote: Failed to parse QuoteModel: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          debugPrint('❌ data keys: ${data.keys.toList()}');
        }
        throw ParsingException('Quote ma\'lumotlarini parse qilishda xatolik: ${e.toString()}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ HotelQuote error: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      // Re-throw to be handled by repository
      rethrow;
    }
  }

  @override
  Future<HotelBookingModel> createBooking(CreateBookingRequestModel request) async {
    try {
      // API format: {"data": {...}} va snake_case
      final requestBody = request.toApiJson();

      if (kDebugMode) {
        debugPrint('📤 HotelBookingCreate Request: ${requestBody.toString()}');
      }

      final response = await _dioClient.post(
        HotelEndpoints.createBooking,
        data: requestBody,
      );

      if (kDebugMode) {
        debugPrint('📥 HotelBookingCreate Response: ${response.data.toString()}');
      }

      // Handle response data - it might be wrapped in 'data' or direct
      Map<String, dynamic> responseData;
      try {
        responseData = _ensureMap(response.data);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ HotelRemoteDataSourceImpl.createBooking: Failed to parse response.data: $e');
          debugPrint('❌ Response.data type: ${response.data.runtimeType}');
          debugPrint('❌ Response.data value: ${response.data}');
        }
        throw const ParsingException('Server javobi noto\'g\'ri formatda');
      }
      
      if (kDebugMode) {
        debugPrint('🔍 HotelRemoteDataSourceImpl.createBooking raw responseData: $responseData');
      }
      
      // Payment URL ni top-level va data ichida qidirish
      String? paymentUrl;
      
      // Top-level dan olish
      paymentUrl = responseData['payment_url'] as String? ?? 
                   responseData['paymentUrl'] as String? ?? 
                   responseData['payment_link'] as String? ??
                   responseData['paymentLink'] as String?;
      
      // Agar top-level da bo'lmasa, data ichidan olish
      Map<String, dynamic> data;
      if (responseData.containsKey('data') && responseData['data'] is Map) {
        data = responseData['data'] as Map<String, dynamic>;
      } else {
        data = responseData;
      }
      
      if (paymentUrl == null || paymentUrl.isEmpty) {
        paymentUrl = data['payment_url'] as String? ?? 
                     data['paymentUrl'] as String? ?? 
                     data['payment_link'] as String? ??
                     data['paymentLink'] as String?;
      }
      
      if (kDebugMode) {
        debugPrint('✅ HotelRemoteDataSourceImpl.createBooking extracted paymentUrl: $paymentUrl');
      }
      
      // Payment URL ni data'ga qo'shish (agar mavjud bo'lsa)
      final dataWithPaymentUrl = Map<String, dynamic>.from(data);
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        dataWithPaymentUrl['payment_url'] = paymentUrl;
      }
      
      // Parse booking model with error handling
      try {
        return HotelBookingModel.fromJson(dataWithPaymentUrl);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ HotelRemoteDataSourceImpl.createBooking: Failed to parse HotelBookingModel: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          debugPrint('❌ dataWithPaymentUrl keys: ${dataWithPaymentUrl.keys.toList()}');
        }
        throw ParsingException('Booking ma\'lumotlarini parse qilishda xatolik: ${e.toString()}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ HotelBookingCreate error: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      // Re-throw to be handled by repository
      rethrow;
    }
  }

  @override
  Future<HotelBookingModel> confirmBooking(String bookingId, Map<String, dynamic> paymentInfo) async {
    final requestData = {
      'data': {
        'booking_id': bookingId,
        'payment_info': paymentInfo,
      },
    };

    final response = await _dioClient.post(
      HotelEndpoints.confirmBooking,
      data: requestData,
    );

    final responseData = _ensureMap(response.data);
    
    // Payment URL ni top-level va data ichida qidirish
    String? paymentUrl;
    
    // Top-level dan olish
    paymentUrl = responseData['payment_url'] as String? ?? 
                 responseData['paymentUrl'] as String? ?? 
                 responseData['payment_link'] as String? ??
                 responseData['paymentLink'] as String?;
    
    // Agar top-level da bo'lmasa, data ichidan olish
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    if (paymentUrl == null) {
      paymentUrl = data['payment_url'] as String? ?? 
                   data['paymentUrl'] as String? ?? 
                   data['payment_link'] as String? ??
                   data['paymentLink'] as String?;
    }
    
    // Payment URL ni data'ga qo'shish
    final dataWithPaymentUrl = Map<String, dynamic>.from(data);
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      dataWithPaymentUrl['payment_url'] = paymentUrl;
    }
    
    return HotelBookingModel.fromJson(dataWithPaymentUrl);
  }

  @override
  Future<HotelBookingModel> cancelBooking(String bookingId, String? cancellationReason) async {
    final requestData = <String, dynamic>{
      'data': {
        'booking_id': bookingId,
      },
    };
    
    if (cancellationReason != null) {
      requestData['data']!['cancellation_reason'] = cancellationReason;
    }

    final response = await _dioClient.post(
      HotelEndpoints.cancelBooking,
      data: requestData,
    );

    final responseData = _ensureMap(response.data);
    final bookingData = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return HotelBookingModel.fromJson(bookingData);
  }

  @override
  Future<HotelBookingModel> readBooking(String bookingId) async {
    final requestData = {
      'data': {
        'booking_id': bookingId,
      },
    };

    final response = await _dioClient.post(
      HotelEndpoints.readBooking,
      data: requestData,
    );

    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return HotelBookingModel.fromJson(data);
  }

  @override
  Future<List<HotelBookingModel>> getUserBookings() async {
    final response = await _dioClient.get(
      HotelEndpoints.getUserBookings,
    );

    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => HotelBookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    final response = await _dioClient.post(HotelEndpoints.getCountries);
    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRegions({int? countryId}) async {
    final response = await _dioClient.post(
      HotelEndpoints.getRegions,
      queryParameters: countryId != null ? {'country_id': countryId} : null,
    );
    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelTypes() async {
    final response = await _dioClient.post(HotelEndpoints.getHotelTypes);
    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  List<Map<String, dynamic>> _parseListResponse(dynamic responseData) {
    List<dynamic> list = [];
    
    // Helper to find list in a map
    List<dynamic>? findListInMap(Map<dynamic, dynamic> map) {
      List<dynamic>? take(String key) {
        if (map[key] is List) {
          return map[key] as List<dynamic>;
        }
        return null;
      }

      // Try common keys first
      return take('data') ??
          take('items') ??
          take('result') ??
          take('facilities') ??
          take('hotel_facilities') ??
          take('services') ??
          take('hotel_services') ??
          take('hotel_services_in_room') ??
          take('services_in_room') ??
          take('nearby_places') ??
          take('equipment') ??
          take('bed_types') ??
          take('room_types') ??
          take('photos') ??
          // Fallback: Check any value that is a list
          () {
            for (final entry in map.entries) {
              if (entry.value is List) {
                return entry.value as List<dynamic>;
              }
            }
            return null;
          }();
    }

    if (responseData == null) {
      return [];
    }

    if (responseData is List) {
      list = responseData;
    } else if (responseData is Map) {
      // 1. Try direct keys
      list = findListInMap(responseData) ?? [];
      
      // 2. If empty, check if 'data' is a Map and search inside it
      if (list.isEmpty && responseData['data'] is Map) {
        list = findListInMap(responseData['data'] as Map) ?? [];
      }

      // Log keys and selection to trace API structure issues
    }

    final result = list.map((e) {
      if (e is String) {
        return {'name': e};
      }
      if (e is Map) {
        try {
          final map = Map<String, dynamic>.from(e);
          // Ensure map has at least a name field
          if (!map.containsKey('name') && !map.containsKey('names')) {
            // Try to extract name from common fields
            final name = map['name_uz'] ?? 
                        map['name_ru'] ?? 
                        map['name_en'] ?? 
                        map['title'] ?? 
                        map['label'] ??
                        map.values.firstWhere((v) => v is String, orElse: () => 'Unknown')?.toString();
            if (name != null) {
              map['name'] = name;
            }
          }
          return map;
        } catch (err) {
          return <String, dynamic>{'name': e.toString()};
        }
      } 
      return {'name': e.toString()};
    }).toList();
    
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getFacilities() async {
    final response = await _dioClient.post(HotelEndpoints.getFacilities);
    return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelFacilities(int hotelId) async {
    final response = await _dioClient.post(
      HotelEndpoints.getHotelFacilities,
      queryParameters: {'hotel_id': hotelId},
    );
    final responseData = _ensureMap(response.data);
    
    // Hotel facilities API returns: {data: {hotel_facilities: [{facility_id: X, hotel_id: Y, paid: bool}]}}
    // We need to extract just the facility_ids
    List<dynamic> hotelFacilitiesList = [];
    
    if (responseData['data'] is Map) {
      final data = responseData['data'] as Map<String, dynamic>;
      hotelFacilitiesList = data['hotel_facilities'] as List<dynamic>? ?? [];
    } else {
      // Fallback to _parseListResponse if structure is different
      return _parseListResponse(response.data);
    }
    
    // Return list with facility_id for matching
    return hotelFacilitiesList.map((e) {
      if (e is Map) {
        final map = Map<String, dynamic>.from(e);
        // Ensure facility_id is present
        if (map.containsKey('facility_id')) {
          return {
            'facility_id': map['facility_id'],
            'hotel_id': map['hotel_id'],
            'paid': map['paid'] ?? false,
            'accessibility_level': map['accessibility_level'],
          };
        }
        return map;
      }
      return <String, dynamic>{'facility_id': e};
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getEquipment() async {
    final response = await _dioClient.post(HotelEndpoints.getEquipment);
    return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getRoomTypeEquipment(int roomTypeId, int? hotelId) async {
    final queryParams = <String, dynamic>{'room_type_id': roomTypeId};
    if (hotelId != null) queryParams['hotel_id'] = hotelId;

    final response = await _dioClient.post(
      HotelEndpoints.getRoomTypeEquipment,
      queryParameters: queryParams,
    );
    final responseData = _ensureMap(response.data);
    
    // Room equipment API might return: {data: {room_equipment: [{equipment_id: X, room_type_id: Y}]}}
    // We need to extract just the equipment_ids
    List<dynamic> roomEquipmentList = [];
    
    if (responseData['data'] is Map) {
      final data = responseData['data'] as Map<String, dynamic>;
      // Try different possible keys
      roomEquipmentList = data['room_equipment'] as List<dynamic>? ?? 
                         data['equipment'] as List<dynamic>? ?? 
                         data['room_type_equipment'] as List<dynamic>? ?? [];
    }
    
    if (roomEquipmentList.isEmpty) {
      // Fallback to _parseListResponse if structure is different
      return _parseListResponse(response.data);
    }
    
    // Return list with equipment_id for matching
    return roomEquipmentList.map((e) {
      if (e is Map) {
        final map = Map<String, dynamic>.from(e);
        // Ensure equipment_id is present
        if (map.containsKey('equipment_id')) {
          return {
            'equipment_id': map['equipment_id'],
            'room_type_id': map['room_type_id'],
          };
        }
        return map;
      }
      return <String, dynamic>{'equipment_id': e};
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getCurrencies() async {
    final response = await _dioClient.post(HotelEndpoints.getCurrencies);
    final responseData = _ensureMap(response.data);
    return responseData['data'] as Map<String, dynamic>? ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> getStars() async {
    final response = await _dioClient.post(HotelEndpoints.getStars);
     return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelPhotos(int hotelId) async {
    try {
      final response = await _dioClient.post(
        HotelEndpoints.getHotelPhotos,
        queryParameters: {'hotel_id': hotelId},
      );
      
      final responseData = _ensureMap(response.data);
      final dataValue = responseData['data'];
      
      // Agar data Map bo'lsa
      if (dataValue is Map<String, dynamic>) {
        final dataMap = dataValue;
        
        // data.photos array bo'lishi mumkin
        if (dataMap['photos'] is List) {
          final hotelPhotos = dataMap['photos'] as List<dynamic>;
          return hotelPhotos.map((e) => e as Map<String, dynamic>).toList();
        }
        
        // Agar data o'zi photos array bo'lsa (nested structure)
        if (dataMap['hotel_photos'] is List) {
          final hotelPhotos = dataMap['hotel_photos'] as List<dynamic>;
          return hotelPhotos.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      
      // Fallback: agar data to'g'ridan-to'g'ri array bo'lsa
      if (dataValue is List) {
        final data = dataValue;
        if (data.isNotEmpty) {
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      
      // Agar responseData to'g'ridan-to'g'ri array bo'lsa
      if (responseData['photos'] is List) {
        final photos = responseData['photos'] as List<dynamic>;
        return photos.map((e) => e as Map<String, dynamic>).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelRoomTypes(int hotelId) async {
    final response = await _dioClient.post(
      HotelEndpoints.getHotelRoomTypes,
      queryParameters: {'hotel_id': hotelId},
    );
    return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelRoomPhotos({int? hotelId, int? roomTypeId}) async {
    final queryParams = <String, dynamic>{};
    if (hotelId != null) queryParams['hotel_id'] = hotelId;
    if (roomTypeId != null) queryParams['room_type_id'] = roomTypeId;

    final response = await _dioClient.post(
      HotelEndpoints.getHotelRoomPhotos,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return _parseListResponse(response.data);
  }

  @override
  Future<Map<String, dynamic>> getPriceRange() async {
    final response = await _dioClient.post(HotelEndpoints.getPriceRange);
    final responseData = _ensureMap(response.data);
    return responseData['data'] as Map<String, dynamic>? ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyPlacesTypes() async {
    final response = await _dioClient.post(HotelEndpoints.getNearbyPlacesTypes);
    return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelNearbyPlaces(int hotelId) async {
    final response = await _dioClient.post(
      HotelEndpoints.getHotelNearbyPlaces,
      queryParameters: {'hotel_id': hotelId},
    );
     return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getServicesInRoom() async {
    final response = await _dioClient.post(HotelEndpoints.getServicesInRoom);
    final responseData = _ensureMap(response.data);
    
    if (kDebugMode) {
      debugPrint('🔍 getServicesInRoom: responseData keys=${responseData.keys}');
    }
    
    // Services in room API returns: {data: {services_in_room: [{id: X, names: [...]}]}}
    // We need to extract the services_in_room list
    List<dynamic> servicesList = [];
    
    if (responseData['data'] is Map) {
      final data = responseData['data'] as Map<String, dynamic>;
      if (kDebugMode) {
        debugPrint('🔍 getServicesInRoom: data keys=${data.keys}');
      }
      // Try different possible keys
      servicesList = data['services_in_room'] as List<dynamic>? ?? 
                    data['services'] as List<dynamic>? ?? [];
    } else if (responseData['data'] is List) {
      // If data is directly a list
      servicesList = responseData['data'] as List<dynamic>;
    }
    
    if (kDebugMode) {
      debugPrint('🔍 getServicesInRoom: servicesList length=${servicesList.length}');
      if (servicesList.isNotEmpty) {
        debugPrint('🔍 getServicesInRoom: First service=${servicesList.first}');
      }
    }
    
    // If we found the list, return it directly (it has full details with id and names)
    if (servicesList.isNotEmpty) {
      return servicesList.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{'id': e};
      }).toList();
    }
    
    // Fallback to _parseListResponse if structure is different
    return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelServicesInRoom(int hotelId) async {
    final response = await _dioClient.post(
      HotelEndpoints.getHotelServicesInRoom,
      queryParameters: {'hotel_id': hotelId},
    );
    final responseData = _ensureMap(response.data);
    
    if (kDebugMode) {
      debugPrint('🔍 getHotelServicesInRoom: hotelId=$hotelId, responseData keys=${responseData.keys}');
    }
    
    // Hotel services in room API returns: {data: {hotel_services_in_room: [{service_id: X, hotel_id: Y}]}}
    // or {data: {services_in_room: [{service_id: X, hotel_id: Y}]}}
    // We need to extract just the service_ids
    List<dynamic> hotelServicesList = [];
    
    if (responseData['data'] is Map) {
      final data = responseData['data'] as Map<String, dynamic>;
      if (kDebugMode) {
        debugPrint('🔍 getHotelServicesInRoom: data keys=${data.keys}');
      }
      // Try different possible keys (API might use different naming)
      hotelServicesList = data['hotel_services_in_room'] as List<dynamic>? ?? 
                         data['services_in_room'] as List<dynamic>? ?? 
                         data['hotel_services'] as List<dynamic>? ??
                         data['services'] as List<dynamic>? ?? [];
    } else if (responseData['data'] is List) {
      // If data is directly a list
      hotelServicesList = responseData['data'] as List<dynamic>;
    } else {
      // Fallback to _parseListResponse if structure is different
      if (kDebugMode) {
        debugPrint('⚠️ getHotelServicesInRoom: Using fallback _parseListResponse');
      }
      return _parseListResponse(response.data);
    }
    
    if (kDebugMode) {
      debugPrint('🔍 getHotelServicesInRoom: hotelServicesList length=${hotelServicesList.length}');
      if (hotelServicesList.isNotEmpty) {
        debugPrint('🔍 getHotelServicesInRoom: First item=${hotelServicesList.first}');
      }
    }
    
    // If list is empty, return empty list
    if (hotelServicesList.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ getHotelServicesInRoom: hotelServicesList is empty');
      }
      return [];
    }
    
    // Return list with services_in_room_id for matching
    // API returns: {hotel_id: X, services_in_room_id: Y}
    return hotelServicesList.map((e) {
      if (e is Map) {
        final map = Map<String, dynamic>.from(e);
        // API returns 'services_in_room_id' field (not 'service_id' or 'id')
        final servicesInRoomId = map['services_in_room_id'] ?? map['service_id'] ?? map['id'] ?? map['serviceId'];
        if (servicesInRoomId != null) {
          if (kDebugMode) {
            debugPrint('🔍 getHotelServicesInRoom: Found services_in_room_id=$servicesInRoomId');
          }
          return {
            'services_in_room_id': servicesInRoomId,
            'service_id': servicesInRoomId, // Also add as service_id for compatibility
            'hotel_id': map['hotel_id'] ?? hotelId,
          };
        }
        if (kDebugMode) {
          debugPrint('⚠️ getHotelServicesInRoom: services_in_room_id not found in item=$map');
        }
        // If no services_in_room_id found, return the map as is (might have full details)
        return map;
      }
      // If it's not a Map, assume it's the services_in_room_id directly
      return <String, dynamic>{
        'services_in_room_id': e,
        'service_id': e, // Also add as service_id for compatibility
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getBedTypes() async {
    final response = await _dioClient.post(HotelEndpoints.getBedTypes);
    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
