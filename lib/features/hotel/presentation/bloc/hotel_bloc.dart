import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../../../../core/utils/error_message_helper.dart';
import '../../../../core/errors/exceptions.dart';

part 'hotel_event.dart';
part 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final HotelRepository repository;

  HotelBloc({required this.repository}) : super(HotelInitial()) {
    // Search
    on<SearchHotelsRequested>(_onSearchHotelsRequested);
    on<HotelStateReset>(_onHotelStateReset);

    // Hotel Details
    on<GetHotelDetailsRequested>(_onGetHotelDetailsRequested);

    // Cities
    on<GetCitiesRequested>(_onGetCitiesRequested);
  }

  // Search
  Future<void> _onSearchHotelsRequested(
    SearchHotelsRequested event,
    Emitter<HotelState> emit,
  ) async {
    emit(HotelSearchLoading(event.filter));
    try {
      final result = await repository.searchHotels(filter: event.filter);
      debugPrint('✅ Search Hotels Success: Found ${result.hotels.length} hotels');
      emit(HotelSearchSuccess(result, filter: event.filter));
    } on AppException catch (e) {
      debugPrint('❌ Search Hotels Error: ${ErrorMessageHelper.getMessage(e)}');
      emit(HotelSearchFailure(ErrorMessageHelper.getMessage(e)));
    } catch (e) {
      debugPrint('❌ Search Hotels Error: $e');
      emit(HotelSearchFailure('Noma\'lum xatolik yuz berdi'));
    }
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
}

