part of 'avia_bloc.dart';

abstract class AviaState extends Equatable {
  final AviaState? previousState; // State preservation
  const AviaState({this.previousState});

  @override
  List<Object?> get props => [previousState];
}

class AviaInitial extends AviaState {
  const AviaInitial({super.previousState});
}

// Specific loading states instead of generic AviaLoading
class AviaLoginLoading extends AviaState {
  const AviaLoginLoading({super.previousState});
}

class AviaBalanceLoading extends AviaState {
  const AviaBalanceLoading({super.previousState});
}

class AviaOfferDetailLoading extends AviaState {
  const AviaOfferDetailLoading({super.previousState});
}

class AviaFareFamilyLoading extends AviaState {
  const AviaFareFamilyLoading({super.previousState});
}

class AviaFareRulesLoading extends AviaState {
  const AviaFareRulesLoading({super.previousState});
}

class AviaBookingLoading extends AviaState {
  const AviaBookingLoading({super.previousState});
}

class AviaBookingInfoLoading extends AviaState {
  const AviaBookingInfoLoading({super.previousState});
}

class AviaBookingRulesLoading extends AviaState {
  const AviaBookingRulesLoading({super.previousState});
}

class AviaCheckPriceLoading extends AviaState {
  const AviaCheckPriceLoading({super.previousState});
}

class AviaPaymentPermissionLoading extends AviaState {
  const AviaPaymentPermissionLoading({super.previousState});
}

class AviaPaymentLoading extends AviaState {
  const AviaPaymentLoading({super.previousState});
}

class AviaCancelUnpaidLoading extends AviaState {
  const AviaCancelUnpaidLoading({super.previousState});
}

class AviaVoidLoading extends AviaState {
  const AviaVoidLoading({super.previousState});
}

class AviaRefundAmountsLoading extends AviaState {
  const AviaRefundAmountsLoading({super.previousState});
}

class AviaAutoCancelLoading extends AviaState {
  const AviaAutoCancelLoading({super.previousState});
}

class AviaManualRefundLoading extends AviaState {
  const AviaManualRefundLoading({super.previousState});
}

class AviaPdfReceiptLoading extends AviaState {
  const AviaPdfReceiptLoading({super.previousState});
}

class AviaScheduleLoading extends AviaState {
  const AviaScheduleLoading({super.previousState});
}

class AviaVisaTypesLoading extends AviaState {
  const AviaVisaTypesLoading({super.previousState});
}

class AviaServiceClassesLoading extends AviaState {
  const AviaServiceClassesLoading({super.previousState});
}

class AviaPassengerTypesLoading extends AviaState {
  const AviaPassengerTypesLoading({super.previousState});
}

class AviaHealthLoading extends AviaState {
  const AviaHealthLoading({super.previousState});
}

class AviaCreateHumanLoading extends AviaState {
  const AviaCreateHumanLoading({super.previousState});
}

class AviaGetHumansLoading extends AviaState {
  const AviaGetHumansLoading({super.previousState});
}

class AviaSearchHumansLoading extends AviaState {
  const AviaSearchHumansLoading({super.previousState});
}

class AviaUpdateHumanLoading extends AviaState {
  const AviaUpdateHumanLoading({super.previousState});
}

class AviaDeleteHumanLoading extends AviaState {
  const AviaDeleteHumanLoading({super.previousState});
}

// Search Loading State with search parameters
class AviaSearchLoading extends AviaState {
  final SearchOffersRequestModel searchRequest;
  const AviaSearchLoading(this.searchRequest, {super.previousState});
  @override
  List<Object?> get props => [searchRequest, previousState];
}

// Login States
class AviaLoginSuccess extends AviaState {
  final LoginResponseModel response;
  const AviaLoginSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaLoginFailure extends AviaState {
  final String message;
  const AviaLoginFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Balance States
class AviaBalanceSuccess extends AviaState {
  final BalanceResponseModel response;
  const AviaBalanceSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaBalanceFailure extends AviaState {
  final String message;
  const AviaBalanceFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Search States
class AviaSearchSuccess extends AviaState {
  final List<OfferModel> offers;
  final SearchOffersRequestModel? searchRequest;
  const AviaSearchSuccess(
    this.offers, {
    this.searchRequest,
    super.previousState,
  });
  @override
  List<Object?> get props => [offers, searchRequest, previousState];
}

class AviaSearchFailure extends AviaState {
  final String message;
  final List<OfferModel>? cachedOffers; // Preserve previous offers on error
  const AviaSearchFailure(
    this.message, {
    this.cachedOffers,
    super.previousState,
  });
  @override
  List<Object?> get props => [message, cachedOffers, previousState];
}

// Offer Detail States
class AviaOfferDetailSuccess extends AviaState {
  final OfferModel offer;
  const AviaOfferDetailSuccess(this.offer, {super.previousState});
  @override
  List<Object?> get props => [offer, previousState];
}

class AviaOfferDetailFailure extends AviaState {
  final String message;
  const AviaOfferDetailFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Fare Family States
class AviaFareFamilySuccess extends AviaState {
  final List<FareFamilyModel> families;
  const AviaFareFamilySuccess(this.families, {super.previousState});
  @override
  List<Object?> get props => [families, previousState];
}

class AviaFareFamilyFailure extends AviaState {
  final String message;
  const AviaFareFamilyFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Fare Rules States
class AviaFareRulesSuccess extends AviaState {
  final FareRulesModel rules;
  const AviaFareRulesSuccess(this.rules, {super.previousState});
  @override
  List<Object?> get props => [rules, previousState];
}

class AviaFareRulesFailure extends AviaState {
  final String message;
  const AviaFareRulesFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Booking States
class AviaCreateBookingSuccess extends AviaState {
  final BookingModel booking;
  const AviaCreateBookingSuccess(this.booking, {super.previousState});
  @override
  List<Object?> get props => [booking, previousState];
}

class AviaCreateBookingFailure extends AviaState {
  final String message;
  final String? existingBookingId;
  const AviaCreateBookingFailure(
    this.message, {
    this.existingBookingId,
    super.previousState,
  });
  @override
  List<Object?> get props => [message, existingBookingId, previousState];
}

class AviaBookingInfoSuccess extends AviaState {
  final BookingModel booking;
  const AviaBookingInfoSuccess(this.booking, {super.previousState});
  @override
  List<Object?> get props => [booking, previousState];
}

class AviaBookingInfoFailure extends AviaState {
  final String message;
  const AviaBookingInfoFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaBookingRulesSuccess extends AviaState {
  final FareRulesModel rules;
  const AviaBookingRulesSuccess(this.rules, {super.previousState});
  @override
  List<Object?> get props => [rules, previousState];
}

class AviaBookingRulesFailure extends AviaState {
  final String message;
  const AviaBookingRulesFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Payment States
class AviaCheckPriceSuccess extends AviaState {
  final PriceCheckModel priceCheck;
  const AviaCheckPriceSuccess(this.priceCheck, {super.previousState});
  @override
  List<Object?> get props => [priceCheck, previousState];
}

class AviaCheckPriceFailure extends AviaState {
  final String message;
  const AviaCheckPriceFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaPaymentPermissionSuccess extends AviaState {
  final PaymentPermissionModel permission;
  const AviaPaymentPermissionSuccess(this.permission, {super.previousState});
  @override
  List<Object?> get props => [permission, previousState];
}

class AviaPaymentPermissionFailure extends AviaState {
  final String message;
  const AviaPaymentPermissionFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaPaymentSuccess extends AviaState {
  final PaymentResponseModel response;
  const AviaPaymentSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaPaymentFailure extends AviaState {
  final String message;
  const AviaPaymentFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Cancel States
class AviaCancelUnpaidSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaCancelUnpaidSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaCancelUnpaidFailure extends AviaState {
  final String message;
  const AviaCancelUnpaidFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaVoidSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaVoidSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaVoidFailure extends AviaState {
  final String message;
  const AviaVoidFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Refund States
class AviaRefundAmountsSuccess extends AviaState {
  final RefundAmountsModel amounts;
  const AviaRefundAmountsSuccess(this.amounts, {super.previousState});
  @override
  List<Object?> get props => [amounts, previousState];
}

class AviaRefundAmountsFailure extends AviaState {
  final String message;
  const AviaRefundAmountsFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaAutoCancelSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaAutoCancelSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaAutoCancelFailure extends AviaState {
  final String message;
  const AviaAutoCancelFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaManualRefundSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaManualRefundSuccess(this.response, {super.previousState});
  @override
  List<Object?> get props => [response, previousState];
}

class AviaManualRefundFailure extends AviaState {
  final String message;
  const AviaManualRefundFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Airport Hints States
class AviaAirportHintsSuccess extends AviaState {
  final List<AirportHintModel> airports;
  const AviaAirportHintsSuccess(this.airports, {super.previousState});
  @override
  List<Object?> get props => [airports, previousState];
}

class AviaAirportHintsFailure extends AviaState {
  final String message;
  const AviaAirportHintsFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// User Humans States (renamed with Avia prefix for consistency)
class AviaCreateHumanSuccess extends AviaState {
  final HumanModel human;
  const AviaCreateHumanSuccess(this.human, {super.previousState});
  @override
  List<Object?> get props => [human, previousState];
}

class AviaCreateHumanFailure extends AviaState {
  final String message;
  const AviaCreateHumanFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaGetHumansSuccess extends AviaState {
  final List<HumanModel> humans;
  const AviaGetHumansSuccess(this.humans, {super.previousState});
  @override
  List<Object?> get props => [humans, previousState];
}

class AviaGetHumansFailure extends AviaState {
  final String message;
  const AviaGetHumansFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaSearchHumansSuccess extends AviaState {
  final List<HumanModel> humans;
  const AviaSearchHumansSuccess(this.humans, {super.previousState});
  @override
  List<Object?> get props => [humans, previousState];
}

class AviaSearchHumansFailure extends AviaState {
  final String message;
  const AviaSearchHumansFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaUpdateHumanSuccess extends AviaState {
  final HumanModel human;
  const AviaUpdateHumanSuccess(this.human, {super.previousState});
  @override
  List<Object?> get props => [human, previousState];
}

class AviaUpdateHumanFailure extends AviaState {
  final String message;
  const AviaUpdateHumanFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

class AviaDeleteHumanSuccess extends AviaState {
  const AviaDeleteHumanSuccess({super.previousState});
  @override
  List<Object?> get props => [previousState];
}

class AviaDeleteHumanFailure extends AviaState {
  final String message;
  const AviaDeleteHumanFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// PDF Receipt States
class AviaPdfReceiptSuccess extends AviaState {
  final String pdfUrl;
  const AviaPdfReceiptSuccess(this.pdfUrl, {super.previousState});
  @override
  List<Object?> get props => [pdfUrl, previousState];
}

class AviaPdfReceiptFailure extends AviaState {
  final String message;
  const AviaPdfReceiptFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Schedule States
class AviaScheduleSuccess extends AviaState {
  final List<ScheduleModel> schedules;
  const AviaScheduleSuccess(this.schedules, {super.previousState});
  @override
  List<Object?> get props => [schedules, previousState];
}

class AviaScheduleFailure extends AviaState {
  final String message;
  const AviaScheduleFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Visa Types States
class AviaVisaTypesSuccess extends AviaState {
  final List<VisaTypeModel> visaTypes;
  const AviaVisaTypesSuccess(this.visaTypes, {super.previousState});
  @override
  List<Object?> get props => [visaTypes, previousState];
}

class AviaVisaTypesFailure extends AviaState {
  final String message;
  const AviaVisaTypesFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Service Classes States
class AviaServiceClassesSuccess extends AviaState {
  final List<ServiceClassModel> serviceClasses;
  const AviaServiceClassesSuccess(this.serviceClasses, {super.previousState});
  @override
  List<Object?> get props => [serviceClasses, previousState];
}

class AviaServiceClassesFailure extends AviaState {
  final String message;
  const AviaServiceClassesFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Passenger Types States
class AviaPassengerTypesSuccess extends AviaState {
  final List<PassengerTypeModel> passengerTypes;
  const AviaPassengerTypesSuccess(this.passengerTypes, {super.previousState});
  @override
  List<Object?> get props => [passengerTypes, previousState];
}

class AviaPassengerTypesFailure extends AviaState {
  final String message;
  const AviaPassengerTypesFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// Health States
class AviaHealthSuccess extends AviaState {
  final HealthModel health;
  const AviaHealthSuccess(this.health, {super.previousState});
  @override
  List<Object?> get props => [health, previousState];
}

class AviaHealthFailure extends AviaState {
  final String message;
  const AviaHealthFailure(this.message, {super.previousState});
  @override
  List<Object?> get props => [message, previousState];
}