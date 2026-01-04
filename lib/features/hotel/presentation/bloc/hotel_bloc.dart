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
  List<Hotel> _cachedHotels = [];

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

      // Update cache
      _cachedHotels = hotels;

      debugPrint('✅ Get Hotels List Success: Loaded ${hotels.length} hotels');

      // Check if we are currently displaying search results
      if (state is HotelSearchSuccess) {
        final currentSearchState = state as HotelSearchSuccess;
        debugPrint(
            '🔄 HotelBloc: Enriching current search results with new hotel list data');

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
        emit(HotelHotelsListFailure('Noma\'lum xatolik yuz berdi'));
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
      final startTime = DateTime.now();
      final result = await repository.searchHotels(filter: event.filter);

      // Merge search results with cached hotel details
      final enrichedHotels = _enrichSearchResults(result.hotels);
      final enrichedResult = result.copyWith(hotels: enrichedHotels);

      // Calculate delay needed to reach 2.5 seconds minimum
      final elapsed = DateTime.now().difference(startTime);
      final remaining = const Duration(milliseconds: 2500) - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      debugPrint(
          '✅ Search Hotels Success: Found ${enrichedResult.hotels.length} hotels');
      if (enrichedResult.hotels.isNotEmpty) {
        debugPrint(
            '🔍 First hotel in result: ${enrichedResult.hotels.first.name}');
        debugPrint('🔍 First hotel ID: ${enrichedResult.hotels.first.id}');
      } else {
        debugPrint('⚠️ WARNING: result.hotels is EMPTY!');
      }
      emit(HotelSearchSuccess(enrichedResult, filter: event.filter));
    } on AppException catch (e) {
      debugPrint('❌ Search Hotels Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelSearchFailure(
        ErrorMessageHelper.getMessage(e),
        filter: event.filter,
      ));
    } catch (e) {
      debugPrint('❌ Search Hotels Error: $e');
      emit(HotelSearchFailure(
        'Noma\'lum xatolik yuz berdi',
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
    emit(HotelInitial());
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
      emit(HotelDetailsFailure('Noma\'lum xatolik yuz berdi'));
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
      emit(HotelCitiesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetCitiesWithIdsRequested(
    GetCitiesWithIdsRequested event,
    Emitter<HotelState> emit,
  ) async {
    debugPrint(
        '🔍 _onGetCitiesWithIdsRequested: countryId = ${event.countryId}');
    try {
      final cities =
          await repository.getCitiesWithIds(countryId: event.countryId);
      debugPrint('✅ GetCitiesWithIds Success: Loaded ${cities.length} cities');
      if (cities.isNotEmpty) {
        debugPrint(
            '🔍 First city: ${cities.first.name} (id: ${cities.first.id})');
      }
      emit(HotelCitiesWithIdsSuccess(cities));
    } on AppException catch (e) {
      debugPrint(
          '❌ GetCitiesWithIds Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelCitiesWithIdsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ GetCitiesWithIds Error: $e');
      emit(HotelCitiesWithIdsFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  // Booking Flow
  Future<void> _onGetQuoteRequested(
    GetQuoteRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final quote = await repository.getQuote(optionRefIds: event.optionRefIds);
      emit(HotelQuoteSuccess(quote));
    } on AppException catch (e) {
      emit(HotelQuoteFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      emit(HotelQuoteFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelLoading());
    try {
      final booking = await repository.createBooking(request: event.request);
      emit(HotelBookingCreateSuccess(booking));
    } on AppException catch (e) {
      emit(HotelBookingCreateFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      emit(HotelBookingCreateFailure('Noma\'lum xatolik yuz berdi'));
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
      emit(HotelBookingConfirmFailure('Noma\'lum xatolik yuz berdi'));
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
      emit(HotelBookingCancelFailure('Noma\'lum xatolik yuz berdi'));
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
      emit(HotelBookingReadFailure('Noma\'lum xatolik yuz berdi'));
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
      emit(HotelUserBookingsFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '✅ Get Countries Success: Found ${countries.length} countries');
      emit(HotelCountriesSuccess(countries));
    } on AppException catch (e) {
      debugPrint('❌ Get Countries Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelCountriesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Countries Error: $e');
      emit(HotelCountriesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetRegionsRequested(
    GetRegionsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelRegionsLoading());
    try {
      final regions = await repository.getRegions(countryId: event.countryId);
      debugPrint('✅ Get Regions Success: Found ${regions.length} regions');
      emit(HotelRegionsSuccess(regions));
    } on AppException catch (e) {
      debugPrint('❌ Get Regions Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelRegionsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Regions Error: $e');
      emit(HotelRegionsFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetHotelTypesRequested(
    GetHotelTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelTypesLoading());
    try {
      final types = await repository.getHotelTypes();
      debugPrint('✅ Get Hotel Types Success: Found ${types.length} types');
      emit(HotelTypesSuccess(types));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Hotel Types Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Types Error: $e');
      emit(HotelTypesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetFacilitiesRequested(
    GetFacilitiesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelFacilitiesLoading());
    try {
      final facilities = await repository.getFacilities();
      debugPrint(
          '✅ Get Facilities Success: Found ${facilities.length} facilities');
      emit(HotelFacilitiesSuccess(facilities));
    } on AppException catch (e) {
      debugPrint('❌ Get Facilities Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelFacilitiesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Facilities Error: $e');
      emit(HotelFacilitiesFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '✅ Get Hotel Facilities Success: Found ${facilities.length} facilities');
      emit(HotelHotelFacilitiesSuccess(facilities));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Hotel Facilities Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelHotelFacilitiesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Facilities Error: $e');
      emit(HotelHotelFacilitiesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetEquipmentRequested(
    GetEquipmentRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelEquipmentLoading());
    try {
      final equipment = await repository.getEquipment();
      debugPrint(
          '✅ Get Equipment Success: Found ${equipment.length} equipment');
      emit(HotelEquipmentSuccess(equipment));
    } on AppException catch (e) {
      debugPrint('❌ Get Equipment Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelEquipmentFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Equipment Error: $e');
      emit(HotelEquipmentFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '✅ Get Room Type Equipment Success: Found ${equipment.length} equipment');
      emit(HotelRoomTypeEquipmentSuccess(equipment));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Room Type Equipment Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelRoomTypeEquipmentFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Room Type Equipment Error: $e');
      emit(HotelRoomTypeEquipmentFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetCurrenciesRequested(
    GetCurrenciesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelCurrenciesLoading());
    try {
      final currencies = await repository.getCurrencies();
      debugPrint(
          '✅ Get Currencies Success: Found ${currencies.length} currencies');
      emit(HotelCurrenciesSuccess(currencies));
    } on AppException catch (e) {
      debugPrint('❌ Get Currencies Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelCurrenciesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Currencies Error: $e');
      emit(HotelCurrenciesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetStarsRequested(
    GetStarsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelStarsLoading());
    try {
      final stars = await repository.getStars();
      debugPrint('✅ Get Stars Success: Found ${stars.length} stars');
      emit(HotelStarsSuccess(stars));
    } on AppException catch (e) {
      debugPrint('❌ Get Stars Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelStarsFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Stars Error: $e');
      emit(HotelStarsFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '❌ Get Hotel Photos Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelPhotosFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Photos Error: $e');
      emit(HotelPhotosFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '✅ Get Hotel Room Types Success: Found ${roomTypes.length} room types');
      emit(HotelRoomTypesSuccess(roomTypes));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Hotel Room Types Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelRoomTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Room Types Error: $e');
      emit(HotelRoomTypesFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '✅ Get Hotel Room Photos Success: Found ${photos.length} photos');
      emit(HotelRoomPhotosSuccess(photos));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Hotel Room Photos Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelRoomPhotosFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Room Photos Error: $e');
      emit(HotelRoomPhotosFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetPriceRangeRequested(
    GetPriceRangeRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelPriceRangeLoading());
    try {
      final priceRange = await repository.getPriceRange();
      debugPrint(
          '✅ Get Price Range Success: ${priceRange.minPrice} - ${priceRange.maxPrice}');
      emit(HotelPriceRangeSuccess(priceRange));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Price Range Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelPriceRangeFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Price Range Error: $e');
      emit(HotelPriceRangeFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetNearbyPlacesTypesRequested(
    GetNearbyPlacesTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelNearbyPlacesTypesLoading());
    try {
      final types = await repository.getNearbyPlacesTypes();
      debugPrint(
          '✅ Get Nearby Places Types Success: Found ${types.length} types');
      emit(HotelNearbyPlacesTypesSuccess(types));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Nearby Places Types Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelNearbyPlacesTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Nearby Places Types Error: $e');
      emit(HotelNearbyPlacesTypesFailure('Noma\'lum xatolik yuz berdi'));
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
      debugPrint(
          '✅ Get Hotel Nearby Places Success: Found ${places.length} places');
      emit(HotelNearbyPlacesSuccess(places));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Hotel Nearby Places Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelNearbyPlacesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Nearby Places Error: $e');
      emit(HotelNearbyPlacesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetServicesInRoomRequested(
    GetServicesInRoomRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelServicesInRoomLoading());
    try {
      final services = await repository.getServicesInRoom();
      debugPrint(
          '✅ Get Services In Room Success: Found ${services.length} services');
      emit(HotelServicesInRoomSuccess(services));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Services In Room Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelServicesInRoomFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Services In Room Error: $e');
      emit(HotelServicesInRoomFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetHotelServicesInRoomRequested(
    GetHotelServicesInRoomRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelHotelServicesInRoomLoading());
    try {
      final services =
          await repository.getHotelServicesInRoom(hotelId: event.hotelId);
      debugPrint(
          '✅ Get Hotel Services In Room Success: Found ${services.length} services');
      emit(HotelHotelServicesInRoomSuccess(services));
    } on AppException catch (e) {
      debugPrint(
          '❌ Get Hotel Services In Room Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelHotelServicesInRoomFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Hotel Services In Room Error: $e');
      emit(HotelHotelServicesInRoomFailure('Noma\'lum xatolik yuz berdi'));
    }
  }

  Future<void> _onGetBedTypesRequested(
    GetBedTypesRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelBedTypesLoading());
    try {
      final bedTypes = await repository.getBedTypes();
      debugPrint('✅ Get Bed Types Success: Found ${bedTypes.length} bed types');
      emit(HotelBedTypesSuccess(bedTypes));
    } on AppException catch (e) {
      debugPrint('❌ Get Bed Types Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelBedTypesFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Get Bed Types Error: $e');
      emit(HotelBedTypesFailure('Noma\'lum xatolik yuz berdi'));
    }
  }
}
