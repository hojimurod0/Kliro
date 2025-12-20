import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/balance_response_model.dart';
import '../../data/models/search_offers_request_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/create_booking_request_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/fare_family_model.dart';
import '../../data/models/fare_rules_model.dart';
import '../../data/models/price_check_model.dart';
import '../../data/models/payment_permission_model.dart';
import '../../data/models/payment_response_model.dart';
import '../../data/models/refund_amounts_model.dart';
import '../../data/models/cancel_response_model.dart';
import '../../data/models/airport_hint_model.dart';
import '../../data/models/human_model.dart';
import '../../domain/repositories/avichiptalar_repository.dart';
import '../../../../core/utils/error_message_helper.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/avia/avia_dio_client.dart';

part 'avia_event.dart';
part 'avia_state.dart';

class AviaBloc extends Bloc<AviaEvent, AviaState> {
  final AvichiptalarRepository repository;
  final AviaDioClient? dioClient;

  AviaBloc({required this.repository, this.dioClient}) : super(AviaInitial()) {
    // Login
    on<LoginRequested>(_onLoginRequested);

    // Balance
    on<CheckBalanceRequested>(_onCheckBalanceRequested);

    // Search
    on<SearchOffersRequested>(_onSearchOffersRequested);
    on<AviaStateReset>(_onAviaStateReset);

    // Offers
    on<OfferDetailRequested>(_onOfferDetailRequested);
    on<FareFamilyRequested>(_onFareFamilyRequested);
    on<FareRulesRequested>(_onFareRulesRequested);

    // Booking
    on<CreateBookingRequested>(_onCreateBookingRequested);
    on<BookingInfoRequested>(_onBookingInfoRequested);
    on<BookingRulesRequested>(_onBookingRulesRequested);

    // Payment
    on<CheckPriceRequested>(_onCheckPriceRequested);
    on<PaymentPermissionRequested>(_onPaymentPermissionRequested);
    on<PaymentRequested>(_onPaymentRequested);

    // Cancel
    on<CancelUnpaidRequested>(_onCancelUnpaidRequested);
    on<VoidTicketRequested>(_onVoidTicketRequested);

    // Refund
    on<RefundAmountsRequested>(_onRefundAmountsRequested);
    on<AutoCancelRequested>(_onAutoCancelRequested);
    on<ManualRefundRequested>(_onManualRefundRequested);

    // Airport Hints
    on<AirportHintsRequested>(_onAirportHintsRequested);
    
    // User Humans
    on<CreateHumanRequested>(_onCreateHumanRequested);
    on<GetHumansRequested>(_onGetHumansRequested);
    on<SearchHumansRequested>(_onSearchHumansRequested);
    on<UpdateHumanRequested>(_onUpdateHumanRequested);
    on<DeleteHumanRequested>(_onDeleteHumanRequested);
  }

  // Login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.login(event.request);
    result.fold(
      (failure) =>
          emit(AviaLoginFailure(ErrorMessageHelper.getMessage(failure))),
      (response) {
        // DioClient'da token'ni yangilash (agar mavjud bo'lsa)
        final token = response.accessToken ?? response.token;
        if (token != null && token.isNotEmpty && dioClient != null) {
          dioClient!.updateToken(token);
        }
        emit(AviaLoginSuccess(response));
      },
    );
  }

  // Balance
  Future<void> _onCheckBalanceRequested(
    CheckBalanceRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.checkBalance();
    result.fold(
      (failure) =>
          emit(AviaBalanceFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaBalanceSuccess(response)),
    );
  }

  // Search
  Future<void> _onSearchOffersRequested(
    SearchOffersRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaSearchLoading(event.request));
    final result = await repository.searchOffers(event.request);
    result.fold(
      (failure) {
        AppLogger.error('Search Offers Error: ${ErrorMessageHelper.getMessage(failure)}');
        emit(AviaSearchFailure(ErrorMessageHelper.getMessage(failure)));
      },
      (response) {
        final offers = response.offers ?? [];
        AppLogger.success('Search Offers Success: Found ${offers.length} offers');
        if (offers.isEmpty) {
          AppLogger.warning('Search Offers: Offers list is empty');
        } else {
          AppLogger.debug('Search Offers: First offer ID: ${offers.first.id}');
        }
        emit(AviaSearchSuccess(offers, searchRequest: event.request));
      },
    );
  }

  Future<void> _onAviaStateReset(
    AviaStateReset event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaInitial());
  }

  // Offer Detail
  Future<void> _onOfferDetailRequested(
    OfferDetailRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.checkOffer(event.offerId);
    result.fold(
      (failure) =>
          emit(AviaOfferDetailFailure(ErrorMessageHelper.getMessage(failure))),
      (offer) => emit(AviaOfferDetailSuccess(offer)),
    );
  }

  Future<void> _onFareFamilyRequested(
    FareFamilyRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.fareFamily(event.offerId);
    result.fold(
      (failure) =>
          emit(AviaFareFamilyFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaFareFamilySuccess(response.families ?? [])),
    );
  }

  Future<void> _onFareRulesRequested(
    FareRulesRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.fareRules(event.offerId);
    result.fold(
      (failure) =>
          emit(AviaFareRulesFailure(ErrorMessageHelper.getMessage(failure))),
      (rules) => emit(AviaFareRulesSuccess(rules)),
    );
  }

  // Booking
  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.createBooking(event.offerId, event.request);
    result.fold(
      (failure) {
        final errorMessage = ErrorMessageHelper.getMessage(failure);
        AppLogger.error('Booking creation failed: $errorMessage', failure);
        
        // Extract existing_booking_id from exception details if present
        String? existingBookingId;
        if (failure.details is Map) {
          final details = failure.details as Map<String, dynamic>;
          existingBookingId = details['existing_booking_id'] as String?;
          if (existingBookingId != null) {
            AppLogger.debug('Found existing booking ID: $existingBookingId');
          }
        }
        
        emit(AviaCreateBookingFailure(
          errorMessage,
          existingBookingId: existingBookingId,
        ));
      },
      (booking) {
        AppLogger.success('Booking created successfully: ${booking.id}');
        emit(AviaCreateBookingSuccess(booking));
      },
    );
  }

  Future<void> _onBookingInfoRequested(
    BookingInfoRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.getBooking(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaBookingInfoFailure(ErrorMessageHelper.getMessage(failure))),
      (booking) => emit(AviaBookingInfoSuccess(booking)),
    );
  }

  Future<void> _onBookingRulesRequested(
    BookingRulesRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.bookingRules(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaBookingRulesFailure(ErrorMessageHelper.getMessage(failure))),
      (rules) => emit(AviaBookingRulesSuccess(rules)),
    );
  }

  // Payment
  Future<void> _onCheckPriceRequested(
    CheckPriceRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.checkPrice(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaCheckPriceFailure(ErrorMessageHelper.getMessage(failure))),
      (priceCheck) => emit(AviaCheckPriceSuccess(priceCheck)),
    );
  }

  Future<void> _onPaymentPermissionRequested(
    PaymentPermissionRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.paymentPermission(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaPaymentPermissionFailure(ErrorMessageHelper.getMessage(failure)),
      ),
      (permission) => emit(AviaPaymentPermissionSuccess(permission)),
    );
  }

  Future<void> _onPaymentRequested(
    PaymentRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.payBooking(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaPaymentFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaPaymentSuccess(response)),
    );
  }

  // Cancel
  Future<void> _onCancelUnpaidRequested(
    CancelUnpaidRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.cancelUnpaid(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaCancelUnpaidFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaCancelUnpaidSuccess(response)),
    );
  }

  Future<void> _onVoidTicketRequested(
    VoidTicketRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.voidTicket(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaVoidFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaVoidSuccess(response)),
    );
  }

  // Refund
  Future<void> _onRefundAmountsRequested(
    RefundAmountsRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.getRefundAmounts(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaRefundAmountsFailure(ErrorMessageHelper.getMessage(failure)),
      ),
      (amounts) => emit(AviaRefundAmountsSuccess(amounts)),
    );
  }

  Future<void> _onAutoCancelRequested(
    AutoCancelRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.autoCancel(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaAutoCancelFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaAutoCancelSuccess(response)),
    );
  }

  Future<void> _onManualRefundRequested(
    ManualRefundRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.manualRefund(event.bookingId);
    result.fold(
      (failure) =>
          emit(AviaManualRefundFailure(ErrorMessageHelper.getMessage(failure))),
      (response) => emit(AviaManualRefundSuccess(response)),
    );
  }

  // Airport Hints
  Future<void> _onAirportHintsRequested(
    AirportHintsRequested event,
    Emitter<AviaState> emit,
  ) async {
    if (event.phrase.isEmpty) {
      emit(AviaAirportHintsSuccess([]));
      return;
    }

    final result = await repository.getAirportHints(
      phrase: event.phrase,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(
        AviaAirportHintsFailure(ErrorMessageHelper.getMessage(failure)),
      ),
      (airports) => emit(AviaAirportHintsSuccess(airports)),
    );
  }
  // User Humans Handlers
  Future<void> _onCreateHumanRequested(
    CreateHumanRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.createHuman(event.human);
    result.fold(
      (failure) =>
          emit(CreateHumanFailure(ErrorMessageHelper.getMessage(failure))),
      (human) => emit(CreateHumanSuccess(human)),
    );
  }

  Future<void> _onGetHumansRequested(
    GetHumansRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.getHumans();
    result.fold(
      (failure) =>
          emit(GetHumansFailure(ErrorMessageHelper.getMessage(failure))),
      (humans) => emit(GetHumansSuccess(humans)),
    );
  }

  Future<void> _onSearchHumansRequested(
    SearchHumansRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.searchHumans(name: event.name);
    result.fold(
      (failure) =>
          emit(SearchHumansFailure(ErrorMessageHelper.getMessage(failure))),
      (humans) => emit(SearchHumansSuccess(humans)),
    );
  }

  Future<void> _onUpdateHumanRequested(
    UpdateHumanRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.updateHuman(event.id, event.human);
    result.fold(
      (failure) =>
          emit(UpdateHumanFailure(ErrorMessageHelper.getMessage(failure))),
      (human) => emit(UpdateHumanSuccess(human)),
    );
  }

  Future<void> _onDeleteHumanRequested(
    DeleteHumanRequested event,
    Emitter<AviaState> emit,
  ) async {
    emit(AviaLoading());
    final result = await repository.deleteHuman(event.id);
    result.fold(
      (failure) =>
          emit(DeleteHumanFailure(ErrorMessageHelper.getMessage(failure))),
      (_) => emit(const DeleteHumanSuccess()),
    );
  }
}
