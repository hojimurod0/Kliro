import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_booking.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../../../../core/utils/error_message_helper.dart';
import '../../../../core/errors/exceptions.dart';

part 'hotel_event.dart';
part 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final HotelRepository repository;

  // Cache full hotel details to enrich search results
  // Limit cache size to prevent memory leaks
  static const int _maxCacheSize = 100;
  List<Hotel> _cachedHotels = [];
  
  // Quote cache - cache quotes by optionRefIds
  final Map<String, HotelQuote> _quoteCache = {};
  static const Duration _quoteCacheExpiry = Duration(minutes: 5);
  final Map<String, DateTime> _quoteCacheTimestamps = {};

  HotelBloc({required this.repository}) : super(HotelInitial()) {
    // Search
    on<SearchHotelsRequested>(_onSearchHotelsRequested);
    on<HotelStateReset>(_onHotelStateReset);

    // Hotel Details
    on<GetHotelDetailsRequested>(_onGetHotelDetailsRequested);

    // Cities
    on<GetCitiesRequested>(_onGetCitiesRequested);
    on<GetCitiesWithIdsRequested>(_onGetCitiesWithIdsRequested);

    // Booking Flow
    on<GetQuoteRequested>(_onGetQuoteRequested);
    on<CreateBookingRequested>(_onCreateBookingRequested);
    on<ConfirmBookingRequested>(_onConfirmBookingRequested);
    on<CancelBookingRequested>(_onCancelBookingRequested);
    on<ReadBookingRequested>(_onReadBookingRequested);

    // User Bookings
    on<GetUserBookingsRequested>(_onGetUserBookingsRequested);

    // Reference Data
    on<GetCountriesRequested>(_onGetCountriesRequested);
    on<GetHotelsListRequested>(_onGetHotelsListRequested);
    on<GetRegionsRequested>(_onGetRegionsRequested);
    on<GetHotelTypesRequested>(_onGetHotelTypesRequested);
    on<GetFacilitiesRequested>(_onGetFacilitiesRequested);
    on<GetHotelFacilitiesRequested>(_onGetHotelFacilitiesRequested);
    on<GetEquipmentRequested>(_onGetEquipmentRequested);
    on<GetRoomTypeEquipmentRequested>(_onGetRoomTypeEquipmentRequested);
    on<GetCurrenciesRequested>(_onGetCurrenciesRequested);
    on<GetStarsRequested>(_onGetStarsRequested);
    on<GetHotelPhotosRequested>(_onGetHotelPhotosRequested);
    on<GetHotelRoomTypesRequested>(_onGetHotelRoomTypesRequested);
    on<GetHotelRoomPhotosRequested>(_onGetHotelRoomPhotosRequested);
    on<GetPriceRangeRequested>(_onGetPriceRangeRequested);
    on<GetNearbyPlacesTypesRequested>(_onGetNearbyPlacesTypesRequested);
    on<GetHotelNearbyPlacesRequested>(_onGetHotelNearbyPlacesRequested);
    on<GetServicesInRoomRequested>(_onGetServicesInRoomRequested);
    on<GetHotelServicesInRoomRequested>(_onGetHotelServicesInRoomRequested);
    on<GetBedTypesRequested>(_onGetBedTypesRequested);
  }

  Future<void> _onGetHotelsListRequested(
    GetHotelsListRequested event,
    Emitter<HotelState> emit,
  ) async {
    try {
      final hotels = await repository.getHotelsList(
        hotelTypeId: event.hotelTypeId,
        countryId: event.countryId,
        regionId: event.regionId,
        cityId: event.cityId,
      );

      // Update cache with size limit
      _updateCache(hotels);

      // Check if we are currently displaying search results
      if (state is HotelSearchSuccess) {
        final currentSearchState = state as HotelSearchSuccess;
        final enrichedResult = currentSearchState.result.copyWith(
          hotels: _enrichSearchResults(currentSearchState.result.hotels),
        );

        emit(HotelSearchSuccess(enrichedResult,
            filter: currentSearchState.filter));
      } else {
        emit(HotelHotelsListSuccess(hotels));
      }
    } on AppException catch (e) {
      if (state is! HotelSearchSuccess) {
        emit(HotelHotelsListFailure(ErrorMessageHelper.getMessage(e)));
      }
    } catch (e) {
      if (state is! HotelSearchSuccess) {
        emit(HotelHotelsListFailure('hotel.error.unknown'.tr()));
      }
    }
  }

  // Search
  Future<void> _onSearchHotelsRequested(
    SearchHotelsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelSearchLoading(event.filter));
    try {
      final result = await repository.searchHotels(filter: event.filter);

      // Merge search results with cached hotel details
      final enrichedHotels = _enrichSearchResults(result.hotels);
      final enrichedResult = result.copyWith(hotels: enrichedHotels);

      emit(HotelSearchSuccess(enrichedResult, filter: event.filter));
    } on AppException catch (e) {
      // If backend returns 404 (no hotels for selected dates/filters), show empty state instead of error
      if (e is ServerException && e.statusCode == 404) {
        emit(HotelSearchSuccess(
          const HotelSearchResult(hotels: []),
          filter: event.filter,
        ));
        return;
      }
      emit(HotelSearchFailure(
        ErrorMessageHelper.getMessage(e),
        filter: event.filter,
      ));
    } catch (e) {
      emit(HotelSearchFailure(
        'hotel.search.error.unknown'.tr(),
        filter: event.filter,
      ));
    }
  }

  List<Hotel> _enrichSearchResults(List<Hotel> searchHotels) {
    if (_cachedHotels.isEmpty) return searchHotels;

    return searchHotels.map((searchHotel) {
      try {
        // Find matching hotel in cache
        final cached = _cachedHotels.firstWhere(
          (h) => h.hotelId == searchHotel.hotelId,
          orElse: () => searchHotel,
        );

        if (cached == searchHotel) {
          return searchHotel;
        }

        // Merge: use cached details + search options/price
        return cached.copyWith(
          price: searchHotel.price,
          options: searchHotel.options,
          // Keep the search request params valid
          checkInDate: searchHotel.checkInDate,
          checkOutDate: searchHotel.checkOutDate,
          guests: searchHotel.guests,
        );
      } catch (e) {
        return searchHotel;
      }
    }).toList();
  }

  Future<void> _onHotelStateReset(
    HotelStateReset event,
    Emitter<HotelState> emit,
  ) async {
    // Clear cache on reset
    _cachedHotels.clear();
    _quoteCache.clear();
    _quoteCacheTimestamps.clear();
    emit(HotelInitial());
  }
  
  /// Clean expired quote cache entries
  void _cleanExpiredQuoteCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _quoteCacheTimestamps.entries) {
      final age = now.difference(entry.value);
      if (age >= _quoteCacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _quoteCache.remove(key);
      _quoteCacheTimestamps.remove(key);
    }
    
    if (kDebugMode && expiredKeys.isNotEmpty) {
      debugPrint('🧹 Cleaned ${expiredKeys.length} expired quote cache entries');
    }
  }

  /// Updates cache with new hotels, maintaining max size
  void _updateCache(List<Hotel> newHotels) {
    // Create a map for quick lookup
    final hotelMap = <int, Hotel>{};
    
    // Add existing cached hotels
    for (final hotel in _cachedHotels) {
      hotelMap[hotel.hotelId] = hotel;
    }
    
    // Update with new hotels (newer data takes precedence)
    for (final hotel in newHotels) {
      hotelMap[hotel.hotelId] = hotel;
    }
    
    // Convert back to list and limit size
    _cachedHotels = hotelMap.values.toList();
    
    // If cache exceeds max size, keep only the most recent ones
    if (_cachedHotels.length > _maxCacheSize) {
      _cachedHotels = _cachedHotels.sublist(
        _cachedHotels.length - _maxCacheSize,
      );
    }
  }

  // Hotel Details
  Future<void> _onGetHotelDetailsRequested(
    GetHotelDetailsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final hotel = await repository.getHotelDetails(hotelId: event.hotelId);
      emit(HotelDetailsSuccess(hotel));
    } on AppException catch (e) {
      emit(HotelDetailsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelDetailsFailure('hotel.error.unknown'.tr()));
    }
  }

  // Cities
  Future<void> _onGetCitiesRequested(
    GetCitiesRequested event,
    Emitter<HotelState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(HotelCitiesSuccess([]));
      return;
    }

    try {
      final cities = await repository.getCities(query: event.query);
      emit(HotelCitiesSuccess(cities));
    } on AppException catch (e) {
      emit(HotelCitiesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelCitiesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetCitiesWithIdsRequested(
    GetCitiesWithIdsRequested event,
    Emitter<HotelState> emit,
  ) async {
    debugPrint('🔍 HotelBloc: _onGetCitiesWithIdsRequested called with countryId: ${event.countryId}');
    try {
      final cities =
          await repository.getCitiesWithIds(countryId: event.countryId);
      debugPrint('✅ HotelBloc: Successfully loaded ${cities.length} cities');
      if (cities.isNotEmpty) {
        debugPrint('🔍 First 5 cities: ${cities.take(5).map((c) => '${c.name} (id: ${c.id})').toList()}');
      }
      emit(HotelCitiesWithIdsSuccess(cities));
    } on AppException catch (e) {
      debugPrint('❌ HotelBloc: Failed to load cities - AppException: ${e.message}');
      emit(HotelCitiesWithIdsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e, stackTrace) {
      debugPrint('❌ HotelBloc: Failed to load cities - Exception: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      emit(HotelCitiesWithIdsFailure('hotel.error.unknown'.tr()));
    }
  }

  // Booking Flow
  Future<void> _onGetQuoteRequested(
    GetQuoteRequested event,
    Emitter<HotelState> emit,
  ) async {
    // Clean expired cache entries periodically
    _cleanExpiredQuoteCache();
    
    // Check cache first
    final cacheKey = event.optionRefIds.join(',');
    final cachedQuote = _quoteCache[cacheKey];
    final cacheTimestamp = _quoteCacheTimestamps[cacheKey];
    
    if (cachedQuote != null && cacheTimestamp != null) {
      final cacheAge = DateTime.now().difference(cacheTimestamp);
      if (cacheAge < _quoteCacheExpiry) {
        if (kDebugMode) {
          debugPrint('✅ Using cached quote for: $cacheKey');
        }
        emit(HotelQuoteSuccess(cachedQuote));
        return;
      } else {
        // Cache expired, remove it
        _quoteCache.remove(cacheKey);
        _quoteCacheTimestamps.remove(cacheKey);
      }
    }
    
    emit(HotelLoading());
    try {
      final quote = await repository.getQuote(optionRefIds: event.optionRefIds);
      
      // Cache the quote
      _quoteCache[cacheKey] = quote;
      _quoteCacheTimestamps[cacheKey] = DateTime.now();
      
      emit(HotelQuoteSuccess(quote));
    } on AppException catch (e) {
      final errorMessage = ErrorMessageHelper.getMessage(e);
      if (kDebugMode) {
        debugPrint('❌ GetQuote error: $errorMessage');
      }
      emit(HotelQuoteFailure(errorMessage));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ GetQuote unknown error: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      emit(HotelQuoteFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    
    // Retry mechanism for parsing errors
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        final booking = await repository.createBooking(request: event.request);
        emit(HotelBookingCreateSuccess(booking));
        return; // Success, exit retry loop
      } on ParsingException catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          if (kDebugMode) {
            debugPrint('⚠️ Parsing error, retrying ($retryCount/$maxRetries): ${e.message}');
          }
          // Wait before retry
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          continue;
        } else {
          // Max retries reached
          final errorMessage = ErrorMessageHelper.getMessage(e);
          if (kDebugMode) {
            debugPrint('❌ HotelBookingCreateFailure after $maxRetries retries: $errorMessage');
          }
          emit(HotelBookingCreateFailure(errorMessage));
          return;
        }
      } on AppException catch (e) {
        final errorMessage = ErrorMessageHelper.getMessage(e);
        if (kDebugMode) {
          debugPrint('❌ HotelBookingCreateFailure: $errorMessage');
        }
        emit(HotelBookingCreateFailure(errorMessage));
        return;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ HotelBookingCreateFailure (unknown): $e');
          debugPrint('❌ Stack trace: $stackTrace');
        }
        // Check if it's a parsing error
        if (e.toString().toLowerCase().contains('parsing') || 
            e.toString().toLowerCase().contains('format')) {
          if (retryCount < maxRetries) {
            retryCount++;
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
            continue;
          } else {
            emit(HotelBookingCreateFailure('error.parsing'.tr()));
            return;
          }
        } else {
          emit(HotelBookingCreateFailure('hotel.error.unknown'.tr()));
          return;
        }
      }
    }
  }

  Future<void> _onConfirmBookingRequested(
    ConfirmBookingRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final booking = await repository.confirmBooking(
        bookingId: event.bookingId,
        paymentInfo: event.paymentInfo,
      );
      emit(HotelBookingConfirmSuccess(booking));
    } on AppException catch (e) {
      emit(HotelBookingConfirmFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelBookingConfirmFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onCancelBookingRequested(
    CancelBookingRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final booking = await repository.cancelBooking(
        bookingId: event.bookingId,
        cancellationReason: event.cancellationReason,
      );
      emit(HotelBookingCancelSuccess(booking));
    } on AppException catch (e) {
      emit(HotelBookingCancelFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelBookingCancelFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onReadBookingRequested(
    ReadBookingRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final booking = await repository.readBooking(bookingId: event.bookingId);
      emit(HotelBookingReadSuccess(booking));
    } on AppException catch (e) {
      emit(HotelBookingReadFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelBookingReadFailure('hotel.error.unknown'.tr()));
    }
  }

  // User Bookings
  Future<void> _onGetUserBookingsRequested(
    GetUserBookingsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelUserBookingsLoading());
    try {
      final bookings = await repository.getUserBookings();
      emit(HotelUserBookingsSuccess(bookings));
    } on AppException catch (e) {
      emit(HotelUserBookingsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelUserBookingsFailure('hotel.error.unknown'.tr()));
    }
  }

  // Reference Data Handlers
  Future<void> _onGetCountriesRequested(
    GetCountriesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelCountriesLoading());
    try {
      final countries = await repository.getCountries();
      emit(HotelCountriesSuccess(countries));
    } on AppException catch (e) {
      if (kDebugMode) {
      }
      emit(HotelCountriesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelCountriesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetRegionsRequested(
    GetRegionsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelRegionsLoading());
    try {
      final regions = await repository.getRegions(countryId: event.countryId);
      if (kDebugMode) {
      }
      emit(HotelRegionsSuccess(regions));
    } on AppException catch (e) {
      if (kDebugMode) {
      }
      emit(HotelRegionsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelRegionsFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelTypesRequested(
    GetHotelTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelTypesLoading());
    try {
      final types = await repository.getHotelTypes();
      if (kDebugMode) {
      }
      emit(HotelTypesSuccess(types));
    } on AppException catch (e) {
      emit(HotelTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelTypesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetFacilitiesRequested(
    GetFacilitiesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelFacilitiesLoading());
    try {
      final facilities = await repository.getFacilities();
      emit(HotelFacilitiesSuccess(facilities));
    } on AppException catch (e) {
      if (kDebugMode) {
      }
      emit(HotelFacilitiesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelFacilitiesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelFacilitiesRequested(
    GetHotelFacilitiesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelHotelFacilitiesLoading());
    try {
      final facilities =
          await repository.getHotelFacilities(hotelId: event.hotelId);
      emit(HotelHotelFacilitiesSuccess(facilities));
    } on AppException catch (e) {
      emit(HotelHotelFacilitiesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelHotelFacilitiesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetEquipmentRequested(
    GetEquipmentRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelEquipmentLoading());
    try {
      final equipment = await repository.getEquipment();
      emit(HotelEquipmentSuccess(equipment));
    } on AppException catch (e) {
      if (kDebugMode) {
      }
      emit(HotelEquipmentFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelEquipmentFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetRoomTypeEquipmentRequested(
    GetRoomTypeEquipmentRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelRoomTypeEquipmentLoading());
    try {
      final equipment =
          await repository.getRoomTypeEquipment(roomTypeId: event.roomTypeId);
      if (kDebugMode) {
        debugPrint(
            '✅ Get Room Type Equipment Success: Found ${equipment.length} equipment');
      }
      emit(HotelRoomTypeEquipmentSuccess(equipment));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Room Type Equipment Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelRoomTypeEquipmentFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelRoomTypeEquipmentFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetCurrenciesRequested(
    GetCurrenciesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelCurrenciesLoading());
    try {
      final currencies = await repository.getCurrencies();
      if (kDebugMode) {
        debugPrint(
            '✅ Get Currencies Success: Found ${currencies.length} currencies');
      }
      emit(HotelCurrenciesSuccess(currencies));
    } on AppException catch (e) {
      if (kDebugMode) {
      }
      emit(HotelCurrenciesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelCurrenciesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetStarsRequested(
    GetStarsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelStarsLoading());
    try {
      final stars = await repository.getStars();
      if (kDebugMode) {
      }
      emit(HotelStarsSuccess(stars));
    } on AppException catch (e) {
      if (kDebugMode) {
      }
      emit(HotelStarsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelStarsFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelPhotosRequested(
    GetHotelPhotosRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelPhotosLoading());
    try {
      final photos = await repository.getHotelPhotos(hotelId: event.hotelId);
      // debugPrint('✅ Get Hotel Photos Success: Found ${photos.length} photos');

      // If we're in search success state and hotel doesn't have imageUrl, update it
      if (state is HotelSearchSuccess && photos.isNotEmpty) {
        final currentState = state as HotelSearchSuccess;
        final currentHotels = currentState.result.hotels;

        // Find default photo or first photo
        final defaultPhoto = photos.firstWhere(
          (p) => p.isDefault && p.url.isNotEmpty,
          orElse: () => photos.firstWhere(
            (p) => p.url.isNotEmpty,
            orElse: () => photos.first,
          ),
        );

        if (defaultPhoto.url.isNotEmpty) {
          final updatedHotels = currentHotels.map((h) {
            if (h.hotelId == event.hotelId &&
                (h.imageUrl == null || h.imageUrl!.isEmpty)) {
              // debugPrint('✅ HotelBloc: Updating hotel ${h.hotelId} with image: ${defaultPhoto.url}');
              return h.copyWith(imageUrl: defaultPhoto.url);
            }
            return h;
          }).toList();

          final updatedResult =
              currentState.result.copyWith(hotels: updatedHotels);
          emit(HotelSearchSuccess(updatedResult, filter: currentState.filter));
        }
      }

      emit(HotelPhotosSuccess(photos));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Hotel Photos Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelPhotosFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelPhotosFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelRoomTypesRequested(
    GetHotelRoomTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelRoomTypesLoading());
    try {
      final roomTypes =
          await repository.getHotelRoomTypes(hotelId: event.hotelId);
      if (kDebugMode) {
        debugPrint(
            '✅ Get Hotel Room Types Success: Found ${roomTypes.length} room types');
      }
      emit(HotelRoomTypesSuccess(roomTypes));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Hotel Room Types Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      // Check if it's a 404 error for room types - this means hotel is not available
      String errorMessage;
      if (e is ServerException && e.statusCode == 404) {
        errorMessage = 'error.hotel_not_available'.tr();
      } else {
        errorMessage = ErrorMessageHelper.getMessage(e);
      }
      emit(HotelRoomTypesFailure(errorMessage));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelRoomTypesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelRoomPhotosRequested(
    GetHotelRoomPhotosRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelRoomPhotosLoading());
    try {
      final photos = await repository.getHotelRoomPhotos(
        hotelId: event.hotelId,
        roomTypeId: event.roomTypeId,
      );
      if (kDebugMode) {
        debugPrint(
            '✅ Get Hotel Room Photos Success: Found ${photos.length} photos');
      }
      emit(HotelRoomPhotosSuccess(photos));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Hotel Room Photos Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelRoomPhotosFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
      }
      emit(HotelRoomPhotosFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetPriceRangeRequested(
    GetPriceRangeRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelPriceRangeLoading());
    try {
      final priceRange = await repository.getPriceRange();
      if (kDebugMode) {
        debugPrint(
            '✅ Get Price Range Success: ${priceRange.minPrice} - ${priceRange.maxPrice}');
      }
      emit(HotelPriceRangeSuccess(priceRange));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Price Range Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelPriceRangeFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Price Range Error: $e');
      }
      emit(HotelPriceRangeFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetNearbyPlacesTypesRequested(
    GetNearbyPlacesTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelNearbyPlacesTypesLoading());
    try {
      final types = await repository.getNearbyPlacesTypes();
      if (kDebugMode) {
        debugPrint(
            '✅ Get Nearby Places Types Success: Found ${types.length} types');
      }
      emit(HotelNearbyPlacesTypesSuccess(types));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Nearby Places Types Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelNearbyPlacesTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Nearby Places Types Error: $e');
      }
      emit(HotelNearbyPlacesTypesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelNearbyPlacesRequested(
    GetHotelNearbyPlacesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelNearbyPlacesLoading());
    try {
      final places =
          await repository.getHotelNearbyPlaces(hotelId: event.hotelId);
      if (kDebugMode) {
        debugPrint(
            '✅ Get Hotel Nearby Places Success: Found ${places.length} places');
      }
      emit(HotelNearbyPlacesSuccess(places));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Hotel Nearby Places Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelNearbyPlacesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Hotel Nearby Places Error: $e');
      }
      emit(HotelNearbyPlacesFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetServicesInRoomRequested(
    GetServicesInRoomRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelServicesInRoomLoading());
    try {
      final services = await repository.getServicesInRoom();
      if (kDebugMode) {
        debugPrint(
            '✅ Get Services In Room Success: Found ${services.length} services');
      }
      emit(HotelServicesInRoomSuccess(services));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Get Services In Room Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelServicesInRoomFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Services In Room Error: $e');
      }
      emit(HotelServicesInRoomFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetHotelServicesInRoomRequested(
    GetHotelServicesInRoomRequested event,
    Emitter<HotelState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('🔍 BLoC: GetHotelServicesInRoomRequested for hotelId=${event.hotelId}');
    }
    emit(HotelHotelServicesInRoomLoading());
    try {
      if (kDebugMode) {
        debugPrint('🔍 BLoC: Calling repository.getHotelServicesInRoom...');
      }
      final services =
          await repository.getHotelServicesInRoom(hotelId: event.hotelId);
      if (kDebugMode) {
        debugPrint(
            '✅ BLoC: Get Hotel Services In Room Success: Found ${services.length} services');
        if (services.isNotEmpty) {
          debugPrint('✅ BLoC: Services IDs: ${services.map((s) => s.id).toList()}');
        }
      }
      emit(HotelHotelServicesInRoomSuccess(services));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ BLoC: Get Hotel Services In Room Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelHotelServicesInRoomFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ BLoC: Get Hotel Services In Room Error: $e');
        debugPrint('❌ BLoC: StackTrace: $stackTrace');
      }
      emit(HotelHotelServicesInRoomFailure('hotel.error.unknown'.tr()));
    }
  }

  Future<void> _onGetBedTypesRequested(
    GetBedTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelBedTypesLoading());
    try {
      final bedTypes = await repository.getBedTypes();
      if (kDebugMode) {
        debugPrint('✅ Get Bed Types Success: Found ${bedTypes.length} bed types');
      }
      emit(HotelBedTypesSuccess(bedTypes));
    } on AppException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Bed Types Error: ${ErrorMessageHelper.getMessage(e)}');
      }
      emit(HotelBedTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get Bed Types Error: $e');
      }
      emit(HotelBedTypesFailure('hotel.error.unknown'.tr()));
    }
  }
}
