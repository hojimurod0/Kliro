import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
import '../../data/models/schedule_model.dart';
import '../../data/models/visa_type_model.dart';
import '../../data/models/service_class_model.dart';
import '../../data/models/passenger_type_model.dart';
import '../../data/models/health_model.dart';
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

    // PDF Receipt
    on<PdfReceiptRequested>(_onPdfReceiptRequested);

    // Schedule
    on<ScheduleRequested>(_onScheduleRequested);

    // Visa Types
    on<VisaTypesRequested>(_onVisaTypesRequested);

    // Service Classes
    on<ServiceClassesRequested>(_onServiceClassesRequested);

    // Passenger Types
    on<PassengerTypesRequested>(_onPassengerTypesRequested);

    // Health
    on<HealthRequested>(_onHealthRequested);

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
    final currentState = state;
    emit(AviaLoginLoading(previousState: currentState));
    final result = await repository.login(event.request);
    result.fold(
      (failure) => emit(
        AviaLoginFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) {
        // DioClient'da token'ni yangilash (agar mavjud bo'lsa)
        final token = response.accessToken ?? response.token;
        if (token != null && token.isNotEmpty && dioClient != null) {
          dioClient!.updateToken(token);
        }
        emit(AviaLoginSuccess(response, previousState: currentState));
      },
    );
  }

  // Balance
  Future<void> _onCheckBalanceRequested(
    CheckBalanceRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaBalanceLoading(previousState: currentState));
    final result = await repository.checkBalance();
    result.fold(
      (failure) => emit(
        AviaBalanceFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaBalanceSuccess(response, previousState: currentState),
      ),
    );
  }

  // Search
  Future<void> _onSearchOffersRequested(
    SearchOffersRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    // Preserve previous offers if available
    List<OfferModel>? previousOffers;
    if (currentState is AviaSearchSuccess) {
      previousOffers = currentState.offers;
    } else if (currentState is AviaSearchFailure) {
      previousOffers = currentState.cachedOffers;
    }

    emit(AviaSearchLoading(event.request, previousState: currentState));
    final result = await repository.searchOffers(event.request);
    result.fold(
      (failure) {
        AppLogger.error(
            'Search Offers Error: ${ErrorMessageHelper.getMessage(failure)}');
        emit(
          AviaSearchFailure(
            ErrorMessageHelper.getMessage(failure),
            cachedOffers: previousOffers,
            previousState: currentState,
          ),
        );
      },
      (response) {
        final offers = response.offers ?? [];
        if (kDebugMode) {
          AppLogger.success(
              'Search Offers Success: Found ${offers.length} offers');
          if (offers.isEmpty) {
            AppLogger.warning('Search Offers: Offers list is empty');
          } else {
            AppLogger.debug(
                'Search Offers: First offer ID: ${offers.first.id}');
          }
          AppLogger.debug('AviaBloc: AviaSearchSuccess emit qilmoqda...');
          AppLogger.debug('AviaBloc: Offers soni: ${offers.length}');
          AppLogger.debug('🔥 EMIT bloc hash: ${hashCode}');
        }
        emit(
          AviaSearchSuccess(
            offers,
            searchRequest: event.request,
            previousState: currentState,
          ),
        );
        if (kDebugMode) {
          AppLogger.debug('AviaBloc: AviaSearchSuccess emit qilindi');
        }
      },
    );
  }

  Future<void> _onAviaStateReset(
    AviaStateReset event,
    Emitter<AviaState> emit,
  ) async {
    // Aniq previousState: null qilish - state'ni to'liq reset qilish
    emit(const AviaInitial(previousState: null));
  }

  // Offer Detail
  Future<void> _onOfferDetailRequested(
    OfferDetailRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaOfferDetailLoading(previousState: currentState));
    final result = await repository.checkOffer(event.offerId);
    result.fold(
      (failure) => emit(
        AviaOfferDetailFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (offer) => emit(
        AviaOfferDetailSuccess(offer, previousState: currentState),
      ),
    );
  }

  Future<void> _onFareFamilyRequested(
    FareFamilyRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaFareFamilyLoading(previousState: currentState));
    final result = await repository.fareFamily(event.offerId);
    result.fold(
      (failure) => emit(
        AviaFareFamilyFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaFareFamilySuccess(
          response.families ?? [],
          previousState: currentState,
        ),
      ),
    );
  }

  Future<void> _onFareRulesRequested(
    FareRulesRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaFareRulesLoading(previousState: currentState));
    final result = await repository.fareRules(event.offerId);
    result.fold(
      (failure) => emit(
        AviaFareRulesFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (rules) => emit(
        AviaFareRulesSuccess(rules, previousState: currentState),
      ),
    );
  }

  // Booking
  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaBookingLoading(previousState: currentState));
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

        emit(
          AviaCreateBookingFailure(
            errorMessage,
            existingBookingId: existingBookingId,
            previousState: currentState,
          ),
        );
      },
      (booking) {
        AppLogger.success('Booking created successfully: ${booking.id}');
        emit(
          AviaCreateBookingSuccess(booking, previousState: currentState),
        );
      },
    );
  }

  Future<void> _onBookingInfoRequested(
    BookingInfoRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaBookingInfoLoading(previousState: currentState));
    final result = await repository.getBooking(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaBookingInfoFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (booking) => emit(
        AviaBookingInfoSuccess(booking, previousState: currentState),
      ),
    );
  }

  Future<void> _onBookingRulesRequested(
    BookingRulesRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaBookingRulesLoading(previousState: currentState));
    final result = await repository.bookingRules(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaBookingRulesFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (rules) => emit(
        AviaBookingRulesSuccess(rules, previousState: currentState),
      ),
    );
  }

  // Payment
  Future<void> _onCheckPriceRequested(
    CheckPriceRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaCheckPriceLoading(previousState: currentState));
    final result = await repository.checkPrice(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaCheckPriceFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (priceCheck) => emit(
        AviaCheckPriceSuccess(priceCheck, previousState: currentState),
      ),
    );
  }

  Future<void> _onPaymentPermissionRequested(
    PaymentPermissionRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaPaymentPermissionLoading(previousState: currentState));
    final result = await repository.paymentPermission(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaPaymentPermissionFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (permission) => emit(
        AviaPaymentPermissionSuccess(permission, previousState: currentState),
      ),
    );
  }

  Future<void> _onPaymentRequested(
    PaymentRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaPaymentLoading(previousState: currentState));
    final result = await repository.payBooking(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaPaymentFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaPaymentSuccess(response, previousState: currentState),
      ),
    );
  }

  // Cancel
  Future<void> _onCancelUnpaidRequested(
    CancelUnpaidRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaCancelUnpaidLoading(previousState: currentState));
    final result = await repository.cancelUnpaid(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaCancelUnpaidFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaCancelUnpaidSuccess(response, previousState: currentState),
      ),
    );
  }

  Future<void> _onVoidTicketRequested(
    VoidTicketRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaVoidLoading(previousState: currentState));
    final result = await repository.voidTicket(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaVoidFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaVoidSuccess(response, previousState: currentState),
      ),
    );
  }

  // Refund
  Future<void> _onRefundAmountsRequested(
    RefundAmountsRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaRefundAmountsLoading(previousState: currentState));
    final result = await repository.getRefundAmounts(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaRefundAmountsFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (amounts) => emit(
        AviaRefundAmountsSuccess(amounts, previousState: currentState),
      ),
    );
  }

  Future<void> _onAutoCancelRequested(
    AutoCancelRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaAutoCancelLoading(previousState: currentState));
    final result = await repository.autoCancel(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaAutoCancelFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaAutoCancelSuccess(response, previousState: currentState),
      ),
    );
  }

  Future<void> _onManualRefundRequested(
    ManualRefundRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaManualRefundLoading(previousState: currentState));
    final result = await repository.manualRefund(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaManualRefundFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (response) => emit(
        AviaManualRefundSuccess(response, previousState: currentState),
      ),
    );
  }

  // Airport Hints
  Future<void> _onAirportHintsRequested(
    AirportHintsRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    if (event.phrase.isEmpty) {
      emit(AviaAirportHintsSuccess([], previousState: currentState));
      return;
    }

    final result = await repository.getAirportHints(
      phrase: event.phrase,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(
        AviaAirportHintsFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (airports) => emit(
        AviaAirportHintsSuccess(airports, previousState: currentState),
      ),
    );
  }

  // PDF Receipt
  Future<void> _onPdfReceiptRequested(
    PdfReceiptRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaPdfReceiptLoading(previousState: currentState));
    final result = await repository.getPdfReceipt(event.bookingId);
    result.fold(
      (failure) => emit(
        AviaPdfReceiptFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (pdfUrl) => emit(
        AviaPdfReceiptSuccess(pdfUrl, previousState: currentState),
      ),
    );
  }

  // Schedule
  Future<void> _onScheduleRequested(
    ScheduleRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaScheduleLoading(previousState: currentState));
    final result = await repository.getSchedule(
      departureFrom: event.departureFrom,
      departureTo: event.departureTo,
      airportFrom: event.airportFrom,
    );
    result.fold(
      (failure) => emit(
        AviaScheduleFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (schedules) => emit(
        AviaScheduleSuccess(schedules, previousState: currentState),
      ),
    );
  }

  // Visa Types
  Future<void> _onVisaTypesRequested(
    VisaTypesRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaVisaTypesLoading(previousState: currentState));
    final result = await repository.getVisaTypes(
      countries: event.countries,
    );
    result.fold(
      (failure) => emit(
        AviaVisaTypesFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (visaTypes) => emit(
        AviaVisaTypesSuccess(visaTypes, previousState: currentState),
      ),
    );
  }

  // Service Classes
  Future<void> _onServiceClassesRequested(
    ServiceClassesRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaServiceClassesLoading(previousState: currentState));
    final result = await repository.getServiceClasses();
    result.fold(
      (failure) => emit(
        AviaServiceClassesFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (serviceClasses) => emit(
        AviaServiceClassesSuccess(serviceClasses, previousState: currentState),
      ),
    );
  }

  // Passenger Types
  Future<void> _onPassengerTypesRequested(
    PassengerTypesRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaPassengerTypesLoading(previousState: currentState));
    final result = await repository.getPassengerTypes();
    result.fold(
      (failure) => emit(
        AviaPassengerTypesFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (passengerTypes) => emit(
        AviaPassengerTypesSuccess(passengerTypes, previousState: currentState),
      ),
    );
  }

  // Health
  Future<void> _onHealthRequested(
    HealthRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaHealthLoading(previousState: currentState));
    final result = await repository.getHealth();
    result.fold(
      (failure) => emit(
        AviaHealthFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (health) => emit(
        AviaHealthSuccess(health, previousState: currentState),
      ),
    );
  }

  // User Humans Handlers
  Future<void> _onCreateHumanRequested(
    CreateHumanRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaCreateHumanLoading(previousState: currentState));
    final result = await repository.createHuman(event.human);
    result.fold(
      (failure) => emit(
        AviaCreateHumanFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (human) => emit(
        AviaCreateHumanSuccess(human, previousState: currentState),
      ),
    );
  }

  Future<void> _onGetHumansRequested(
    GetHumansRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaGetHumansLoading(previousState: currentState));
    final result = await repository.getHumans();
    result.fold(
      (failure) => emit(
        AviaGetHumansFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (humans) => emit(
        AviaGetHumansSuccess(humans, previousState: currentState),
      ),
    );
  }

  Future<void> _onSearchHumansRequested(
    SearchHumansRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaSearchHumansLoading(previousState: currentState));
    final result = await repository.searchHumans(name: event.name);
    result.fold(
      (failure) => emit(
        AviaSearchHumansFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (humans) => emit(
        AviaSearchHumansSuccess(humans, previousState: currentState),
      ),
    );
  }

  Future<void> _onUpdateHumanRequested(
    UpdateHumanRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaUpdateHumanLoading(previousState: currentState));
    final result = await repository.updateHuman(event.id, event.human);
    result.fold(
      (failure) => emit(
        AviaUpdateHumanFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (human) => emit(
        AviaUpdateHumanSuccess(human, previousState: currentState),
      ),
    );
  }

  Future<void> _onDeleteHumanRequested(
    DeleteHumanRequested event,
    Emitter<AviaState> emit,
  ) async {
    final currentState = state;
    emit(AviaDeleteHumanLoading(previousState: currentState));
    final result = await repository.deleteHuman(event.id);
    result.fold(
      (failure) => emit(
        AviaDeleteHumanFailure(
          ErrorMessageHelper.getMessage(failure),
          previousState: currentState,
        ),
      ),
      (_) => emit(
        // currentState ni previousState sifatida berish - boshqa success state'lar bilan mos kelishi uchun
        AviaDeleteHumanSuccess(previousState: currentState),
      ),
    );
  }
}
