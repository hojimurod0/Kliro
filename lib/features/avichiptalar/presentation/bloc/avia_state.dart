part of 'avia_bloc.dart';

abstract class AviaState extends Equatable {
  const AviaState();

  @override
  List<Object?> get props => [];
}

class AviaInitial extends AviaState {}

class AviaLoading extends AviaState {}

// Search Loading State with search parameters
class AviaSearchLoading extends AviaState {
  final SearchOffersRequestModel searchRequest;
  const AviaSearchLoading(this.searchRequest);
  @override
  List<Object?> get props => [searchRequest];
}

// Login States
class AviaLoginSuccess extends AviaState {
  final LoginResponseModel response;
  const AviaLoginSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaLoginFailure extends AviaState {
  final String message;
  const AviaLoginFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Balance States
class AviaBalanceSuccess extends AviaState {
  final BalanceResponseModel response;
  const AviaBalanceSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaBalanceFailure extends AviaState {
  final String message;
  const AviaBalanceFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Search States
class AviaSearchSuccess extends AviaState {
  final List<OfferModel> offers;
  final SearchOffersRequestModel? searchRequest;
  const AviaSearchSuccess(this.offers, {this.searchRequest});
  @override
  List<Object?> get props => [offers, searchRequest];
}

class AviaSearchFailure extends AviaState {
  final String message;
  const AviaSearchFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Offer Detail States
class AviaOfferDetailSuccess extends AviaState {
  final OfferModel offer;
  const AviaOfferDetailSuccess(this.offer);
  @override
  List<Object?> get props => [offer];
}

class AviaOfferDetailFailure extends AviaState {
  final String message;
  const AviaOfferDetailFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Fare Family States
class AviaFareFamilySuccess extends AviaState {
  final List<FareFamilyModel> families;
  const AviaFareFamilySuccess(this.families);
  @override
  List<Object?> get props => [families];
}

class AviaFareFamilyFailure extends AviaState {
  final String message;
  const AviaFareFamilyFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Fare Rules States
class AviaFareRulesSuccess extends AviaState {
  final FareRulesModel rules;
  const AviaFareRulesSuccess(this.rules);
  @override
  List<Object?> get props => [rules];
}

class AviaFareRulesFailure extends AviaState {
  final String message;
  const AviaFareRulesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Booking States
class AviaCreateBookingSuccess extends AviaState {
  final BookingModel booking;
  const AviaCreateBookingSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class AviaCreateBookingFailure extends AviaState {
  final String message;
  final String? existingBookingId;
  const AviaCreateBookingFailure(
    this.message, {
    this.existingBookingId,
  });
  @override
  List<Object?> get props => [message, existingBookingId];
}

class AviaBookingInfoSuccess extends AviaState {
  final BookingModel booking;
  const AviaBookingInfoSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class AviaBookingInfoFailure extends AviaState {
  final String message;
  const AviaBookingInfoFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AviaBookingRulesSuccess extends AviaState {
  final FareRulesModel rules;
  const AviaBookingRulesSuccess(this.rules);
  @override
  List<Object?> get props => [rules];
}

class AviaBookingRulesFailure extends AviaState {
  final String message;
  const AviaBookingRulesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Payment States
class AviaCheckPriceSuccess extends AviaState {
  final PriceCheckModel priceCheck;
  const AviaCheckPriceSuccess(this.priceCheck);
  @override
  List<Object?> get props => [priceCheck];
}

class AviaCheckPriceFailure extends AviaState {
  final String message;
  const AviaCheckPriceFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AviaPaymentPermissionSuccess extends AviaState {
  final PaymentPermissionModel permission;
  const AviaPaymentPermissionSuccess(this.permission);
  @override
  List<Object?> get props => [permission];
}

class AviaPaymentPermissionFailure extends AviaState {
  final String message;
  const AviaPaymentPermissionFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AviaPaymentSuccess extends AviaState {
  final PaymentResponseModel response;
  const AviaPaymentSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaPaymentFailure extends AviaState {
  final String message;
  const AviaPaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Cancel States
class AviaCancelUnpaidSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaCancelUnpaidSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaCancelUnpaidFailure extends AviaState {
  final String message;
  const AviaCancelUnpaidFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AviaVoidSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaVoidSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaVoidFailure extends AviaState {
  final String message;
  const AviaVoidFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Refund States
class AviaRefundAmountsSuccess extends AviaState {
  final RefundAmountsModel amounts;
  const AviaRefundAmountsSuccess(this.amounts);
  @override
  List<Object?> get props => [amounts];
}

class AviaRefundAmountsFailure extends AviaState {
  final String message;
  const AviaRefundAmountsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AviaAutoCancelSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaAutoCancelSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaAutoCancelFailure extends AviaState {
  final String message;
  const AviaAutoCancelFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AviaManualRefundSuccess extends AviaState {
  final CancelResponseModel response;
  const AviaManualRefundSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AviaManualRefundFailure extends AviaState {
  final String message;
  const AviaManualRefundFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Airport Hints States
class AviaAirportHintsSuccess extends AviaState {
  final List<AirportHintModel> airports;
  const AviaAirportHintsSuccess(this.airports);
  @override
  List<Object?> get props => [airports];
}

class AviaAirportHintsFailure extends AviaState {
  final String message;
  const AviaAirportHintsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// User Humans States
class CreateHumanSuccess extends AviaState {
  final HumanModel human;
  const CreateHumanSuccess(this.human);
  @override
  List<Object?> get props => [human];
}

class CreateHumanFailure extends AviaState {
  final String message;
  const CreateHumanFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class GetHumansSuccess extends AviaState {
  final List<HumanModel> humans;
  const GetHumansSuccess(this.humans);
  @override
  List<Object?> get props => [humans];
}

class GetHumansFailure extends AviaState {
  final String message;
  const GetHumansFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchHumansSuccess extends AviaState {
  final List<HumanModel> humans;
  const SearchHumansSuccess(this.humans);
  @override
  List<Object?> get props => [humans];
}

class SearchHumansFailure extends AviaState {
  final String message;
  const SearchHumansFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class UpdateHumanSuccess extends AviaState {
  final HumanModel human;
  const UpdateHumanSuccess(this.human);
  @override
  List<Object?> get props => [human];
}

class UpdateHumanFailure extends AviaState {
  final String message;
  const UpdateHumanFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class DeleteHumanSuccess extends AviaState {
  const DeleteHumanSuccess();
}

class DeleteHumanFailure extends AviaState {
  final String message;
  const DeleteHumanFailure(this.message);
  @override
  List<Object?> get props => [message];
}
