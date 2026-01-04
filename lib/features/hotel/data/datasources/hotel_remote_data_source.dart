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
    debugPrint('🔍 searchHotels: responseData keys = ${responseData.keys.toList()}');
    if (responseData['data'] != null && responseData['data'] is Map) {
      final data = responseData['data'] as Map<String, dynamic>;
      debugPrint('🔍 searchHotels: data keys = ${data.keys.toList()}');
      if (data['hotels'] != null && data['hotels'] is List) {
        final hotels = data['hotels'] as List;
        debugPrint('🔍 searchHotels: hotels count = ${hotels.length}');
        if (hotels.isNotEmpty) {
          final firstHotel = hotels[0];
          debugPrint('🔍 COMPREHENSIVE DUMP searchHotels FIRST ITEM: $firstHotel'); // Added dump
          if (firstHotel is Map) {
            debugPrint('🔍 searchHotels: First hotel keys = ${firstHotel.keys.toList()}');
            if (firstHotel['hotel_info'] != null) {
              debugPrint('🔍 searchHotels: First hotel has hotel_info');
              if (firstHotel['hotel_info'] is Map) {
                debugPrint('🔍 searchHotels: hotel_info keys = ${(firstHotel['hotel_info'] as Map).keys.toList()}');
              }
            } else {
              debugPrint('⚠️ searchHotels: First hotel has NO hotel_info');
            }
          }
        }
      }
    }
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
    final response = await _dioClient.post(
      HotelEndpoints.getCitiesWithIds,
      queryParameters: countryId != null ? {'country_id': countryId} : null,
    );

    debugPrint('🔍 getCitiesWithIds: response.data type = ${response.data.runtimeType}');
    
    if (response.data is List) {
      debugPrint('🔍 getCitiesWithIds: response.data is List, length = ${(response.data as List).length}');
      return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
    }

    final responseData = _ensureMap(response.data);
    debugPrint('🔍 getCitiesWithIds: responseData keys = ${responseData.keys}');
    dynamic data = responseData['data'];
    debugPrint('🔍 getCitiesWithIds: data type = ${data.runtimeType}');

    // If data is a Map, try to find the list inside
    if (data is Map) {
      debugPrint('🔍 getCitiesWithIds: data is Map, keys = ${data.keys}');
      if (data['result'] is List) {
        data = data['result'];
        debugPrint('🔍 getCitiesWithIds: Found data in "result" key, length = ${(data as List).length}');
      } else if (data['cities'] is List) {
        data = data['cities'];
        debugPrint('🔍 getCitiesWithIds: Found data in "cities" key, length = ${(data as List).length}');
      } else if (data['items'] is List) {
        data = data['items'];
        debugPrint('🔍 getCitiesWithIds: Found data in "items" key, length = ${(data as List).length}');
      } else {
        // Fallback: search for any list in values
        for (final value in data.values) {
          if (value is List) {
            data = value;
            debugPrint('🔍 getCitiesWithIds: Found list in data values, length = ${(data as List).length}');
            break;
          }
        }
      }
    }

    final listData = data as List<dynamic>? ?? [];
    debugPrint('✅ getCitiesWithIds: Returning ${listData.length} cities');
    return listData.map((e) => e as Map<String, dynamic>).toList();
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
    
    debugPrint('🔍 Hotels List Response Type: ${response.data.runtimeType}');
    debugPrint('🔍 Hotels List Response Keys: ${response.data is Map ? (response.data as Map).keys.toList() : "Not a Map"}');
    
    // If response is empty and we were doing a general search, try specific fallback for Tashkent
    // This is a hack because 'mode=search' generic might not work
    final isEmpty = response.data == null || 
         (response.data is List && (response.data as List).isEmpty) ||
         (response.data is Map && (response.data as Map).isEmpty);
    
    if (isEmpty && cityId == null && countryId == null) {
        debugPrint('⚠️ Empty response, trying Tashkent fallback');
        // Try getting Tashkent hotels directly as fallback content
        response = await _dioClient.post(
          HotelEndpoints.getHotelList,
          queryParameters: {'city_id': 1}, // Tashkent
        );
        debugPrint('🔍 Tashkent Hotels Response Type: ${response.data.runtimeType}');
        debugPrint('🔍 Tashkent Hotels Response Keys: ${response.data is Map ? (response.data as Map).keys.toList() : "Not a Map"}');
    }

    // Handle both { data: [...] } and [...] formats
    List<dynamic> data = [];
    if (response.data is List) {
      data = response.data as List<dynamic>;
      debugPrint('✅ Response is List, found ${data.length} items');
    } else if (response.data is Map) {
      final responseData = response.data as Map<String, dynamic>;
      debugPrint('🔍 Response is Map, keys: ${responseData.keys.toList()}');
      
      // Try different possible keys
      if (responseData['data'] is List) {
        data = responseData['data'] as List<dynamic>;
        debugPrint('✅ Found data in "data" key, ${data.length} items');
      } else if (responseData['data'] is Map) {
        // If data is a Map, check for hotels inside
        final dataMap = responseData['data'] as Map<String, dynamic>;
        debugPrint('🔍 Data is Map, keys: ${dataMap.keys.toList()}');
        if (dataMap['hotels'] is List) {
          data = dataMap['hotels'] as List<dynamic>;
          debugPrint('✅ Found data in "data.hotels" key, ${data.length} items');
        } else if (dataMap['items'] is List) {
          data = dataMap['items'] as List<dynamic>;
          debugPrint('✅ Found data in "data.items" key, ${data.length} items');
        } else if (dataMap['result'] is List) {
          data = dataMap['result'] as List<dynamic>;
          debugPrint('✅ Found data in "data.result" key, ${data.length} items');
        }
      } else if (responseData['hotels'] is List) {
        data = responseData['hotels'] as List<dynamic>;
        debugPrint('✅ Found data in "hotels" key, ${data.length} items');
      } else if (responseData['items'] is List) {
        data = responseData['items'] as List<dynamic>;
        debugPrint('✅ Found data in "items" key, ${data.length} items');
      } else if (responseData['result'] is List) {
        data = responseData['result'] as List<dynamic>;
        debugPrint('✅ Found data in "result" key, ${data.length} items');
      } else {
        // Fallback: search for any list in values
        debugPrint('🔍 Searching for lists in response values...');
        for (final entry in responseData.entries) {
          if (entry.value is List) {
            data = entry.value as List<dynamic>;
            debugPrint('✅ Found data in "${entry.key}" key, ${data.length} items');
            break;
          } else if (entry.value is Map) {
            // Check inside nested maps
            final nestedMap = entry.value as Map<String, dynamic>;
            for (final nestedEntry in nestedMap.entries) {
              if (nestedEntry.value is List) {
                data = nestedEntry.value as List<dynamic>;
                debugPrint('✅ Found data in "${entry.key}.${nestedEntry.key}" key, ${data.length} items');
                break;
              }
            }
            if (data.isNotEmpty) break;
          }
        }
      }
    }
    
    if (data.isEmpty) {
      debugPrint('⚠️ No hotels found in response');
      return [];
    }
    
    debugPrint('🔍 Parsing ${data.length} hotel items...');
    
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
          debugPrint('⚠️ Item $i is a List, trying to extract Map from first element');
          final firstElement = item[0];
          if (firstElement is Map<String, dynamic>) {
            hotelMap = firstElement;
          } else {
            debugPrint('⚠️ Item $i List first element is not a Map, skipping');
            continue;
          }
        } else {
          debugPrint('⚠️ Item $i is not a Map or List, type: ${item.runtimeType}, skipping');
          continue;
        }
        
        final hotel = HotelModel.fromApiJson(hotelMap);
        hotels.add(hotel);
      } catch (e, stackTrace) {
        debugPrint('❌ Error parsing hotel item $i: $e');
        debugPrint('Item type: ${data[i].runtimeType}');
        debugPrint('Stack trace: $stackTrace');
        // Skip invalid hotel entries
        continue;
      }
    }
    
    debugPrint('✅ Successfully parsed ${hotels.length} hotels out of ${data.length} items');
    return hotels;
  }

  @override
  Future<QuoteModel> getQuote(List<String> optionRefIds) async {
    final response = await _dioClient.post(
      HotelEndpoints.getQuote,
      data: {'data': {'option_ref_ids': optionRefIds}},
    );

    final responseData = _ensureMap(response.data);
    return QuoteModel.fromJson(responseData);
  }

  @override
  Future<HotelBookingModel> createBooking(CreateBookingRequestModel request) async {
    final requestBody = request.toJson();

    final response = await _dioClient.post(
      HotelEndpoints.createBooking,
      data: requestBody,
    );

    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return HotelBookingModel.fromJson(data);
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
    final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
    return HotelBookingModel.fromJson(data);
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
      if (map['data'] is List) return map['data'];
      if (map['items'] is List) return map['items'];
      if (map['result'] is List) return map['result'];
      if (map['facilities'] is List) return map['facilities'];
      if (map['services'] is List) return map['services'];
      if (map['nearby_places'] is List) return map['nearby_places'];
      if (map['equipment'] is List) return map['equipment'];
      if (map['bed_types'] is List) return map['bed_types'];
      if (map['room_types'] is List) return map['room_types'];
      if (map['photos'] is List) return map['photos'];
      
      // Fallback: Check any value that is a list
      for (final val in map.values) {
        if (val is List) return val;
      }
      return null;
    }

    if (responseData is List) {
      list = responseData;
    } else if (responseData is Map) {
      // 1. Try direct keys
      list = findListInMap(responseData) ?? [];
      
      // 2. If empty, check if 'data' is a Map and search inside it
      if (list.isEmpty && responseData['data'] is Map) {
        list = findListInMap(responseData['data']) ?? [];
      }
    }

    return list.map((e) {
      if (e is String) return {'name': e};
      if (e is Map) {
        try {
          return Map<String, dynamic>.from(e);
        } catch (_) {
          return <String, dynamic>{};
        }
      } 
      return {'name': e.toString()};
    }).toList();
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
      data: {'hotel_id': hotelId},
    );
    debugPrint('🔧 getHotelFacilities raw: ${response.data}');
    return _parseListResponse(response.data);
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
     return _parseListResponse(response.data);
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
        data: {}, // POST so'rov uchun bo'sh body
      );
      
      debugPrint('📸 getHotelPhotos Response for hotel $hotelId: ${response.data.runtimeType}');
      
      final responseData = _ensureMap(response.data);
      debugPrint('📸 getHotelPhotos Response keys: ${responseData.keys.toList()}');
      
      // API javobida data.photos array bor
      final dataValue = responseData['data'];
      
      // Agar data Map bo'lsa
      if (dataValue is Map<String, dynamic>) {
        final dataMap = dataValue;
        debugPrint('📸 getHotelPhotos data is Map, keys: ${dataMap.keys.toList()}');
        
        // data.photos array bo'lishi mumkin
        if (dataMap['photos'] is List) {
          final hotelPhotos = dataMap['photos'] as List<dynamic>;
          debugPrint('✅ getHotelPhotos: Found ${hotelPhotos.length} photos in data.photos for hotel $hotelId');
          if (hotelPhotos.isNotEmpty) {
            debugPrint('📸 First photo keys: ${(hotelPhotos.first as Map).keys.toList()}');
          }
          return hotelPhotos.map((e) => e as Map<String, dynamic>).toList();
        }
        
        // Agar data o'zi photos array bo'lsa (nested structure)
        if (dataMap['hotel_photos'] is List) {
          final hotelPhotos = dataMap['hotel_photos'] as List<dynamic>;
          debugPrint('✅ getHotelPhotos: Found ${hotelPhotos.length} photos in data.hotel_photos for hotel $hotelId');
          return hotelPhotos.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      
      // Fallback: agar data to'g'ridan-to'g'ri array bo'lsa
      if (dataValue is List) {
        final data = dataValue;
        if (data.isNotEmpty) {
          debugPrint('✅ getHotelPhotos: Found ${data.length} photos (direct array) for hotel $hotelId');
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      
      // Agar responseData to'g'ridan-to'g'ri array bo'lsa
      if (responseData['photos'] is List) {
        final photos = responseData['photos'] as List<dynamic>;
        debugPrint('✅ getHotelPhotos: Found ${photos.length} photos in root photos for hotel $hotelId');
        return photos.map((e) => e as Map<String, dynamic>).toList();
      }
      
      debugPrint('⚠️ getHotelPhotos: No photos found for hotel $hotelId. Response structure: ${responseData.keys.toList()}');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ getHotelPhotos Error for hotel $hotelId: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelRoomTypes(int hotelId) async {
    final response = await _dioClient.post(HotelEndpoints.getHotelRoomTypes(hotelId));
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
      data: {'hotel_id': hotelId},
    );
     return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getServicesInRoom() async {
    final response = await _dioClient.post(HotelEndpoints.getServicesInRoom);
     return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getHotelServicesInRoom(int hotelId) async {
    final response = await _dioClient.post(
      HotelEndpoints.getHotelServicesInRoom,
      data: {'hotel_id': hotelId},
    );
    debugPrint('🔧 getHotelServicesInRoom raw: ${response.data}');
    return _parseListResponse(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getBedTypes() async {
    final response = await _dioClient.post(HotelEndpoints.getBedTypes);
    final responseData = _ensureMap(response.data);
    final data = responseData['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
