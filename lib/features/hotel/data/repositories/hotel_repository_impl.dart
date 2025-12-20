import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/hotel_endpoints.dart';
import '../../../../core/network/hotel/hotel_dio_client.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../models/search_request_model.dart';
import '../models/search_response_model.dart';
import '../models/hotel_model.dart';

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
      final response = await _dioClient.post(
        HotelEndpoints.searchHotels,
        data: request.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          responseData['message'] as String? ?? 'Qidiruv muvaffaqiyatsiz',
        );
      }

      final dataMap =
          responseData['data'] as Map<String, dynamic>? ??
          responseData['result'] as Map<String, dynamic>? ??
          responseData;

      final model = SearchResponseModel.fromJson(dataMap);
      return model.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: $e');
    }
  }

  @override
  Future<Hotel> getHotelDetails({required String hotelId}) async {
    try {
      final response = await _dioClient.get(
        HotelEndpoints.getHotelDetails(hotelId),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          responseData['message'] as String? ??
              'Ma\'lumot olish muvaffaqiyatsiz',
        );
      }

      final dataMap =
          responseData['data'] as Map<String, dynamic>? ??
          responseData['result'] as Map<String, dynamic>? ??
          responseData;

      final model = HotelModel.fromJson(dataMap);
      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: $e');
    }
  }

  @override
  Future<List<String>> getCities({String? query}) async {
    try {
      final response = await _dioClient.get(
        HotelEndpoints.getCities,
        queryParameters: query != null ? {'query': query} : null,
      );
      final responseData = response.data;

      if (responseData is List) {
        return responseData.map((item) => item.toString()).toList();
      }

      if (responseData is Map<String, dynamic>) {
        List<dynamic>? cities;

        if (responseData.containsKey('result') &&
            responseData['result'] is List) {
          cities = responseData['result'] as List;
        } else if (responseData.containsKey('data') &&
            responseData['data'] is List) {
          cities = responseData['data'] as List;
        } else if (responseData.containsKey('cities') &&
            responseData['cities'] is List) {
          cities = responseData['cities'] as List;
        }

        if (cities != null) {
          return cities.map((item) => item.toString()).toList();
        }
      }

      return [];
    } on AppException catch (e) {
      if (e is ServerException && e.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: $e');
    }
  }

  Map<String, dynamic> _ensureMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ParsingException('Server javobi noto\'g\'ri formatda');
  }
}

