import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/avia_endpoints.dart';
import '../../../../core/network/avia/avia_dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/retry_helper.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../domain/entities/avichipta.dart';
import '../../domain/entities/avichipta_filter.dart';
import '../../domain/entities/avichipta_search_result.dart';
import '../../domain/repositories/avichiptalar_repository.dart';
import '../models/search_request_model.dart';
import '../models/search_response_model.dart';
import '../models/avichipta_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/balance_response_model.dart';
import '../models/search_offers_request_model.dart';
import '../models/offer_model.dart';
import '../models/create_booking_request_model.dart';
import '../models/booking_model.dart';
import '../models/fare_family_model.dart';
import '../models/fare_rules_model.dart';
import '../models/price_check_model.dart';
import '../models/payment_permission_model.dart';
import '../models/payment_response_model.dart';
import '../models/refund_amounts_model.dart';
import '../models/cancel_response_model.dart';
import '../models/airport_hint_model.dart';
import '../models/human_model.dart';
import '../models/schedule_model.dart';
import '../models/visa_type_model.dart';
import '../models/service_class_model.dart';
import '../models/passenger_type_model.dart';
import '../models/health_model.dart';
import '../utils/parsing_converter.dart';
import '../utils/validation_helper.dart';

// Cache entry with timestamp
class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  _CacheEntry(this.data, this.timestamp, this.ttl);

  bool get isExpired =>
      DateTime.now().difference(timestamp) > ttl;
}

class AvichiptalarRepositoryImpl implements AvichiptalarRepository {
  AvichiptalarRepositoryImpl({required AviaDioClient dioClient})
    : _dioClient = dioClient;

  final AviaDioClient _dioClient;

  // --- In-memory caches with TTL and size limits ---
  static const int _maxCacheSize = 50; // Maximum cache entries
  static const Duration _cacheTTL = Duration(hours: 1); // Cache TTL

  final Map<String, _CacheEntry<FareFamilyResponseModel>> _fareFamilyCache = {};
  final Map<String, Future<Either<AppException, FareFamilyResponseModel>>>
      _fareFamilyInFlight = {};

  final Map<String, _CacheEntry<FareRulesModel>> _fareRulesCache = {};
  final Map<String, Future<Either<AppException, FareRulesModel>>>
      _fareRulesInFlight = {};

  // Clean expired entries and enforce size limit
  void _cleanCache<T>(Map<String, _CacheEntry<T>> cache) {
    // Remove expired entries
    cache.removeWhere((key, entry) => entry.isExpired);

    // If still over limit, remove oldest entries
    if (cache.length > _maxCacheSize) {
      final sortedEntries = cache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
      final toRemove = sortedEntries.length - _maxCacheSize;
      // Ensure we don't try to remove more than available
      final removeCount = toRemove > sortedEntries.length 
          ? sortedEntries.length 
          : toRemove;
      for (int i = 0; i < removeCount; i++) {
        cache.remove(sortedEntries[i].key);
      }
    }
  }

  // Search methods
  @override
  Future<AvichiptaSearchResult> searchFlights({
    AvichiptaFilter filter = AvichiptaFilter.empty,
  }) async {
    try {
      final request = SearchRequestModel.fromFilter(filter);
      final response = await _dioClient.post(
        AviaEndpoints.searchFlights,
        data: request.toJson(),
      );
      final responseData = ParsingConverter.ensureMap(response.data);
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
    } catch (e, stackTrace) {
      AppLogger.error('Search flights parsing error', e, stackTrace);
      throw ParsingException('Javobni parse qilishda xatolik: $e');
    }
  }

  @override
  Future<Avichipta> getFlightDetails({required String flightId}) async {
    try {
      ValidationHelper.validateFlightId(flightId);
      final response = await _dioClient.get(
        AviaEndpoints.getFlightDetails(flightId),
      );
      final responseData = ParsingConverter.ensureMap(response.data);
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

      final model = AvichiptaModel.fromJson(dataMap);
      return model;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Get flight details parsing error', e, stackTrace);
      throw ParsingException('Javobni parse qilishda xatolik: $e');
    }
  }

  @override
  Future<List<String>> getCities({String? query}) async {
    try {
      // Query validation - agar bo'sh string bo'lsa, null qilamiz
      final cleanQuery = query?.trim();
      final response = await _dioClient.get(
        AviaEndpoints.getCities,
        queryParameters: cleanQuery != null && cleanQuery.isNotEmpty
            ? {'query': cleanQuery}
            : null,
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


  // Auth methods
  @override
  Future<Either<AppException, LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    try {
      final response = await _dioClient.post(
        AviaEndpoints.login,
        data: request.toJson(),
      );

      final model = ParsingConverter.parseResponse(
        response.data,
        LoginResponseModel.fromJson,
      );

      // Обновляем токен в клиенте если он есть
      final token = model.accessToken ?? model.token;
      if (token != null && token.isNotEmpty) {
        _dioClient.updateToken(token);
      }

      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, BalanceResponseModel>> checkBalance() async {
    try {
      final response = await _dioClient.get(AviaEndpoints.checkBalance);

      final model = ParsingConverter.parseResponse(
        response.data,
        BalanceResponseModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Offers methods
  @override
  Future<Either<AppException, OffersResponseModel>> searchOffers(
    SearchOffersRequestModel request,
  ) async {
    try {
      final queryParams = request.toQueryParameters();
      final response = await RetryHelper.retry(
        operation: () => _dioClient.get(
          AviaEndpoints.searchOffers,
          queryParameters: queryParams,
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );

      AppLogger.networkResponse(200, AviaEndpoints.searchOffers, response.data);

      // Extract offers list va total using ParsingConverter
      // extractOffersList already returns List<OfferModel>, no need to parse again
      List<OfferModel> offers;
      int? total;

      if (response.data is List<dynamic>) {
        // Agar response.data List bo'lsa, extractOffersList ga beramiz
        offers = ParsingConverter.extractOffersList(response.data);
        total = offers.length;
      } else if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        offers = ParsingConverter.extractOffersList(responseData);
        total = ParsingConverter.extractTotal(responseData) ?? offers.length;
      } else {
        offers = [];
        total = 0;
      }

      final model = OffersResponseModel(offers: offers, total: total);

      return Right(model);
    } on AppException catch (e) {
      AppLogger.error('Search Offers AppException', e);
      return Left(e);
    } catch (e) {
      AppLogger.error('Search Offers Exception', e);
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, OfferModel>> checkOffer(String offerId) async {
    try {
      ValidationHelper.validateOfferId(offerId);

      final response = await _dioClient.get(AviaEndpoints.checkOffer(offerId));

      final model = ParsingConverter.parseResponse(
        response.data,
        OfferModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, FareFamilyResponseModel>> fareFamily(
    String offerId,
  ) async {
    try {
      ValidationHelper.validateOfferId(offerId);

      // Clean cache before checking
      _cleanCache(_fareFamilyCache);

      final cached = _fareFamilyCache[offerId];
      if (cached != null && !cached.isExpired) {
        return Right(cached.data);
      }
      // Remove expired entry
      if (cached != null) {
        _fareFamilyCache.remove(offerId);
      }

      final inFlight = _fareFamilyInFlight[offerId];
      if (inFlight != null) return await inFlight;

      final future = () async {
        try {
          final response =
              await _dioClient.get(AviaEndpoints.fareFamily(offerId));
          // Some backends return a bare List for fare-family; normalize to Map for parser.
          final raw = response.data;
          final Map<String, dynamic> normalizedRoot;
          if (raw is List) {
            normalizedRoot = <String, dynamic>{'families': raw};
          } else if (raw is Map) {
            normalizedRoot = Map<String, dynamic>.from(raw);
          } else {
            throw ParsingException(
              'Server javobi noto\'g\'ri formatda: ${raw.runtimeType}',
            );
          }

          final model = FareFamilyResponseModel.fromJson(normalizedRoot);
          _fareFamilyCache[offerId] = _CacheEntry(model, DateTime.now(), _cacheTTL);
          return Right<AppException, FareFamilyResponseModel>(model);
        } on AppException catch (e) {
          return Left<AppException, FareFamilyResponseModel>(e);
        } catch (e, stackTrace) {
          AppLogger.error('Fare family parsing error', e, stackTrace);
          return Left<AppException, FareFamilyResponseModel>(
            ParsingException('Javobni parse qilishda xatolik: $e'),
          );
        } finally {
          // Always cleanup in-flight request
          _fareFamilyInFlight.remove(offerId);
        }
      }();

      _fareFamilyInFlight[offerId] = future;
      return await future;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, FareRulesModel>> fareRules(String offerId) async {
    try {
      ValidationHelper.validateOfferId(offerId);

      // Clean cache before checking
      _cleanCache(_fareRulesCache);

      final cached = _fareRulesCache[offerId];
      if (cached != null && !cached.isExpired) {
        return Right(cached.data);
      }
      // Remove expired entry
      if (cached != null) {
        _fareRulesCache.remove(offerId);
      }

      final inFlight = _fareRulesInFlight[offerId];
      if (inFlight != null) return await inFlight;

      final future = () async {
        try {
          final response =
              await _dioClient.get(AviaEndpoints.offerRules(offerId));
          final model = ParsingConverter.parseResponse(
            response.data,
            FareRulesModel.fromJson,
          );
          _fareRulesCache[offerId] = _CacheEntry(model, DateTime.now(), _cacheTTL);
          return Right<AppException, FareRulesModel>(model);
        } on AppException catch (e) {
          return Left<AppException, FareRulesModel>(e);
        } catch (e, stackTrace) {
          AppLogger.error('Fare rules parsing error', e, stackTrace);
          return Left<AppException, FareRulesModel>(
            ParsingException('Javobni parse qilishda xatolik: $e'),
          );
        } finally {
          // Always cleanup in-flight request
          _fareRulesInFlight.remove(offerId);
        }
      }();

      _fareRulesInFlight[offerId] = future;
      return await future;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Booking methods
  @override
  Future<Either<AppException, BookingModel>> createBooking(
    String offerId,
    CreateBookingRequestModel request,
  ) async {
    try {
      ValidationHelper.validateOfferId(offerId);

      AppLogger.debug('Creating booking for offer: $offerId');
      AppLogger.debug('Request payload: ${AppLogger.sanitize(request.toJson().toString())}');

      // Sanitize booking request using ValidationHelper
      final payload = ValidationHelper.sanitizeBookingRequest(request);

      final endpoint = AviaEndpoints.createBooking(offerId);
      AppLogger.network('POST', endpoint, payload);

      final response = await RetryHelper.retry(
        operation: () => _dioClient.post(
          endpoint,
          data: payload,
        ),
        // Backend can respond with 410 "Запрос обрабатывается." while processing.
        // Give it more time and retries before surfacing an error to the user.
        maxRetries: 8,
        delay: const Duration(seconds: 1),
      );

      AppLogger.networkResponse(response.statusCode ?? 0, endpoint, response.data);

      final model = ParsingConverter.parseResponse(
        response.data,
        BookingModel.fromJson,
      );
      // Some create-booking responses don't provide `id` field.
      // Backend commonly returns `booking_number` under `data`.
      String? bookingId = model.id;
      String? createdAt = model.createdAt;
      final raw = response.data;
      if ((bookingId == null || bookingId.trim().isEmpty) && raw is Map) {
        final root = Map<String, dynamic>.from(raw);
        final dataMap = root['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(root['data'] as Map<String, dynamic>)
            : <String, dynamic>{};
        bookingId =
            (root['id'] ?? dataMap['id'] ?? dataMap['booking_number'] ?? root['booking_number'])
                ?.toString();
        createdAt = createdAt ?? root['created_at']?.toString() ?? dataMap['created']?.toString();
      }

      final normalizedId = bookingId?.trim();
      final normalizedCreatedAt = createdAt?.trim();
      final normalizedModel = (normalizedId != null && normalizedId.isNotEmpty)
          ? model.copyWith(
              id: normalizedId,
              createdAt: (normalizedCreatedAt != null && normalizedCreatedAt.isNotEmpty)
                  ? normalizedCreatedAt
                  : model.createdAt,
            )
          : model;
      AppLogger.success('Booking model parsed successfully: ${normalizedModel.id}');
      return Right(normalizedModel);
    } on AppException catch (e) {
      AppLogger.error('Repository AppException', e);
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('Repository Unexpected error', e, stackTrace);
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, BookingModel>> getBooking(
    String bookingId,
  ) async {
    try {
      ValidationHelper.validateBookingId(bookingId);

      final response = await RetryHelper.retry(
        operation: () => _dioClient.get(
          AviaEndpoints.getBooking(bookingId),
        ),
        // Booking info can be temporarily unavailable while backend is processing.
        maxRetries: 6,
        delay: const Duration(seconds: 1),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        BookingModel.fromJson,
      );
      // Ensure booking id is set even if backend uses a different field name.
      final normalizedId = (model.id == null || model.id!.trim().isEmpty)
          ? bookingId
          : model.id!;
      return Right(model.copyWith(id: normalizedId));
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, FareRulesModel>> bookingRules(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.get(
        AviaEndpoints.bookingRules(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        FareRulesModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Payment methods
  @override
  Future<Either<AppException, PriceCheckModel>> checkPrice(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.get(
        AviaEndpoints.checkPrice(bookingId),
      );
      
      final model = ParsingConverter.parseResponse(
        response.data,
        PriceCheckModel.fromJson,
      );
      
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, PaymentPermissionModel>> paymentPermission(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.get(
        AviaEndpoints.paymentPermission(bookingId),
      );
      
      final model = ParsingConverter.parseResponse(
        response.data,
        PaymentPermissionModel.fromJson,
      );
      
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, PaymentResponseModel>> payBooking(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.post(
        AviaEndpoints.payBooking(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        PaymentResponseModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Cancel methods
  @override
  Future<Either<AppException, CancelResponseModel>> cancelUnpaid(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.post(
        AviaEndpoints.cancelUnpaid(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        CancelResponseModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, CancelResponseModel>> voidTicket(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.post(
        AviaEndpoints.voidTicket(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        CancelResponseModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Refund methods
  @override
  Future<Either<AppException, RefundAmountsModel>> getRefundAmounts(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.get(
        AviaEndpoints.getRefundAmounts(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        RefundAmountsModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, CancelResponseModel>> autoCancel(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.post(
        AviaEndpoints.autoCancel(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        CancelResponseModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, CancelResponseModel>> manualRefund(
    String bookingId,
  ) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      final response = await _dioClient.post(
        AviaEndpoints.manualRefund(bookingId),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        CancelResponseModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Airport Hints
  @override
  Future<Either<AppException, List<AirportHintModel>>> getAirportHints({
    required String phrase,
    int limit = 10,
  }) async {
    try {
      if (phrase.trim().isEmpty) {
        return Right([]);
      }
      
      if (limit <= 0 || limit > 100) {
        return Left(const ValidationException('Limit 1 dan 100 gacha bo\'lishi kerak'));
      }

      final response = await _dioClient.get(
        AviaEndpoints.airportHints,
        queryParameters: {'phrase': phrase, 'limit': limit},
      );

      final responseData = response.data;

      // Extract airport hints list using ParsingConverter
      // extractAirportHintsList already returns List<AirportHintModel>, no need to parse again
      final airports = ParsingConverter.extractAirportHintsList(responseData);

      AppLogger.success('Total airports parsed: ${airports.length}');

      return Right(airports);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // Documents and Services
  @override
  Future<Either<AppException, String>> getPdfReceipt(String bookingId) async {
    try {
      if (bookingId.isEmpty) {
        return Left(
          const ValidationException('Booking ID bo\'sh bo\'lmasligi kerak'),
        );
      }

      // Avval JSON sifatida olishga harakat qilish
      try {
        final jsonResponse = await _dioClient.get(
          AviaEndpoints.pdfReceipt(bookingId),
        );

        final data = jsonResponse.data;
        
        // 1. Agar response Map bo'lsa (JSON format)
        if (data is Map<String, dynamic>) {
          final url = data['url'] ?? 
                      data['pdf_url'] ?? 
                      data['receipt_url'] ??
                      data['data']?['url'] ??
                      data['data']?['pdf_url'] ??
                      data['data']?['receipt_url'];
          if (url != null && url.toString().isNotEmpty) {
            return Right(url.toString());
          }
          
          // Base64 field tekshirish
          final base64 = data['base64'] ?? 
                         data['pdf_base64'] ?? 
                         data['data']?['base64'];
          if (base64 != null && base64.toString().isNotEmpty) {
            return Right('data:application/pdf;base64,${base64.toString()}');
          }
        }
        
        // 2. Agar response String bo'lsa
        if (data is String) {
          // Base64 data URI format tekshirish
          if (data.startsWith('data:application/pdf') || 
              data.startsWith('data:application/octet-stream')) {
            return Right(data);
          }
          // Oddiy base64 string bo'lsa
          if (!data.startsWith('http://') && !data.startsWith('https://')) {
            try {
              // Base64 ekanligini tekshirish
              base64Decode(data);
              return Right('data:application/pdf;base64,$data');
            } catch (_) {
              // Base64 emas, oddiy string
            }
          }
          // URL bo'lsa
          if (data.startsWith('http://') || data.startsWith('https://')) {
            return Right(data);
          }
        }
      } catch (e) {
        // JSON parse qilishda xatolik bo'lsa, bytes sifatida olishga harakat qilish
        AppLogger.debug('JSON parse qilishda xatolik, bytes sifatida olishga harakat: $e');
      }

      // Agar JSON ishlamasa, bytes sifatida olish
      final bytesResponse = await _dioClient.get(
        AviaEndpoints.pdfReceipt(bookingId),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      final bytesData = bytesResponse.data;
      
      // 3. Agar response bytes bo'lsa (to'g'ridan-to'g'ri PDF)
      if (bytesData is List<int> || bytesData is Uint8List) {
        final base64 = base64Encode(bytesData);
        return Right('data:application/pdf;base64,$base64');
      }
      
      return Left(ParsingException('PDF formatini aniqlab bo\'lmadi. Response type: ${bytesData.runtimeType}'));
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, List<ScheduleModel>>> getSchedule({
    required String departureFrom,
    required String departureTo,
    required String airportFrom,
  }) async {
    try {
      final response = await _dioClient.get(
        AviaEndpoints.schedule,
        queryParameters: {
          'departure_from': departureFrom,
          'departure_to': departureTo,
          'airport_from': airportFrom,
        },
      );

      final data = response.data;
      List<ScheduleModel> schedules = [];

      if (data is List) {
        schedules = data
            .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['result'] ?? data['schedules'];
        if (list is List) {
          schedules = list
              .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return Right(schedules);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, List<VisaTypeModel>>> getVisaTypes({
    required List<String> countries,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      for (int i = 0; i < countries.length; i++) {
        queryParams['countries[$i]'] = countries[i];
      }

      final response = await _dioClient.get(
        AviaEndpoints.visaTypes,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<VisaTypeModel> visaTypes = [];

      if (data is List) {
        visaTypes = data
            .map((e) => VisaTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['result'] ?? data['visa_types'];
        if (list is List) {
          visaTypes = list
              .map((e) => VisaTypeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return Right(visaTypes);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, List<ServiceClassModel>>> getServiceClasses() async {
    try {
      final response = await _dioClient.get(AviaEndpoints.serviceClasses);

      final data = response.data;
      List<ServiceClassModel> serviceClasses = [];

      if (data is List) {
        serviceClasses = data
            .map((e) => ServiceClassModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['result'] ?? data['service_classes'];
        if (list is List) {
          serviceClasses = list
              .map((e) => ServiceClassModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return Right(serviceClasses);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, List<PassengerTypeModel>>> getPassengerTypes() async {
    try {
      final response = await _dioClient.get(AviaEndpoints.passengerTypes);

      final data = response.data;
      List<PassengerTypeModel> passengerTypes = [];

      if (data is List) {
        passengerTypes = data
            .map((e) => PassengerTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['result'] ?? data['passenger_types'];
        if (list is List) {
          passengerTypes = list
              .map((e) => PassengerTypeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return Right(passengerTypes);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, HealthModel>> getHealth() async {
    try {
      final response = await _dioClient.get(AviaEndpoints.health);

      final model = ParsingConverter.parseResponse(
        response.data,
        HealthModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  // User Humans methods
  @override
  Future<Either<AppException, HumanModel>> createHuman(HumanModel human) async {
    try {
      // Human model validation
      if (human.firstName.trim().isEmpty) {
        return Left(const ValidationException('Ism bo\'sh bo\'lmasligi kerak'));
      }
      if (human.lastName.trim().isEmpty) {
        return Left(const ValidationException('Familiya bo\'sh bo\'lmasligi kerak'));
      }
      final response = await _dioClient.post(
        AviaEndpoints.userHumans,
        data: human.toJson(),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        HumanModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, List<HumanModel>>> getHumans() async {
    try {
      AppLogger.debug('getHumans: Requesting ${AviaEndpoints.userHumans}');
      
      // Token'ni tekshirish va log qilish
      try {
        final authService = AuthService.instance;
        final token = await authService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          AppLogger.debug('getHumans: Token available: YES (${token.substring(0, 30)}...)');
          
          // Token ichidagi user_id'ni decode qilish
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              String normalizedPayload = payload;
              switch (payload.length % 4) {
                case 1:
                  normalizedPayload += '===';
                  break;
                case 2:
                  normalizedPayload += '==';
                  break;
                case 3:
                  normalizedPayload += '=';
                  break;
              }
              final decoded = utf8.decode(base64.decode(normalizedPayload));
              final payloadMap = json.decode(decoded) as Map<String, dynamic>;
              final userId = payloadMap['user_id'] ?? payloadMap['userId'] ?? payloadMap['sub'];
              AppLogger.debug('getHumans: Token user_id: $userId');
              AppLogger.debug('getHumans: Token payload: $payloadMap');
            }
          } catch (e) {
            AppLogger.warning('getHumans: Could not decode token: $e');
          }
        } else {
          AppLogger.warning('getHumans: Token is NULL or EMPTY!');
        }
      } catch (e) {
        AppLogger.warning('getHumans: Could not check token: $e');
      }
      
      final response = await _dioClient.get(AviaEndpoints.userHumans);
      final data = response.data;
      
      AppLogger.debug('getHumans API response type: ${data.runtimeType}');
      AppLogger.debug('getHumans API response data: $data');
      AppLogger.debug('getHumans: Response status code: ${response.statusCode}');
      
      if (data is List) {
        AppLogger.debug('Data is List, length: ${data.length}');
        final humans =
            data
                .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                .toList();
        AppLogger.success('Parsed humans count: ${humans.length}');
        return Right(humans);
      } else if (data is Map<String, dynamic>) {
        AppLogger.debug('Data is Map, keys: ${data.keys.toList()}');
        
        // data['data'] tekshirish
        if (data.containsKey('data')) {
          final listData = data['data'];
          AppLogger.debug('Found data key, type: ${listData.runtimeType}');
          if (listData is List) {
            AppLogger.debug('data is List, length: ${listData.length}');
            final humans =
                listData
                    .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                    .toList();
            AppLogger.success('Parsed humans count: ${humans.length}');
            return Right(humans);
          }
        }
        
        // data['result'] tekshirish
        if (data.containsKey('result')) {
          final resultData = data['result'];
          AppLogger.debug('Found result key, type: ${resultData.runtimeType}');
          
          if (resultData is List) {
            AppLogger.debug('result is List, length: ${resultData.length}');
            final humans =
                resultData
                    .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                    .toList();
            AppLogger.success('Parsed humans count: ${humans.length}');
            return Right(humans);
          } else if (resultData is Map<String, dynamic> && resultData.containsKey('data')) {
            final listData = resultData['data'];
            AppLogger.debug('result.data type: ${listData.runtimeType}');
            if (listData is List) {
              AppLogger.debug('result.data is List, length: ${listData.length}');
              final humans =
                  listData
                      .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                      .toList();
              AppLogger.success('Parsed humans count: ${humans.length}');
              return Right(humans);
            }
          }
        }
        
        // Boshqa barcha keylarni tekshirish
        AppLogger.debug('Checking all keys in response...');
        for (var key in data.keys) {
          AppLogger.debug('Key: $key, Value type: ${data[key].runtimeType}');
          if (data[key] is List) {
            AppLogger.debug('Found List in key: $key, length: ${(data[key] as List).length}');
            try {
              final humans =
                  (data[key] as List)
                      .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                      .toList();
              AppLogger.success('Successfully parsed humans from key: $key, count: ${humans.length}');
              return Right(humans);
            } catch (e) {
              AppLogger.warning('Failed to parse from key $key: $e');
            }
          }
        }
      }
      
      AppLogger.warning('getHumans - No valid data format found, returning empty list');
      return const Right([]);
    } on AppException catch (e) {
      AppLogger.error('getHumans AppException', e);
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('getHumans Exception', e, stackTrace);
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, List<HumanModel>>> searchHumans({
    required String name,
  }) async {
    try {
      final response = await _dioClient.get(
        AviaEndpoints.userHumansSearch,
        queryParameters: {'name': name},
      );
      final data = response.data;
      if (data is List) {
        final humans =
            data
                .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                .toList();
        return Right(humans);
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        final list = data['data'] as List;
        final humans =
            list
                .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                .toList();
        return Right(humans);
      } else if (data is Map<String, dynamic> && data['result'] is List) {
        final list = data['result'] as List;
        final humans =
            list
                .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                .toList();
        return Right(humans);
      } else if (data is Map<String, dynamic> &&
          data['result'] is Map<String, dynamic> &&
          (data['result'] as Map<String, dynamic>)['data'] is List) {
        final list = (data['result'] as Map<String, dynamic>)['data'] as List;
        final humans =
            list
                .map((e) => HumanModel.fromJson(e as Map<String, dynamic>))
                .toList();
        return Right(humans);
      }
      return const Right([]);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, HumanModel>> updateHuman(
    String id,
    HumanModel human,
  ) async {
    try {
      ValidationHelper.validateUuid(id);
      // Human model validation
      if (human.firstName.trim().isEmpty) {
        return Left(const ValidationException('Ism bo\'sh bo\'lmasligi kerak'));
      }
      if (human.lastName.trim().isEmpty) {
        return Left(const ValidationException('Familiya bo\'sh bo\'lmasligi kerak'));
      }
      final response = await _dioClient.put(
        AviaEndpoints.userHuman(id),
        data: human.toJson(),
      );
      final model = ParsingConverter.parseResponse(
        response.data,
        HumanModel.fromJson,
      );
      return Right(model);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteHuman(String id) async {
    try {
      ValidationHelper.validateUuid(id);
      await _dioClient.delete(AviaEndpoints.userHuman(id));
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ParsingException('Javobni parse qilishda xatolik: $e'));
    }
  }
}
