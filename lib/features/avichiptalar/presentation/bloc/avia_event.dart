part of 'avia_bloc.dart';

abstract class AviaEvent extends Equatable {
  const AviaEvent();

  @override
  List<Object?> get props => [];
}

// Login Events
class LoginRequested extends AviaEvent {
  final LoginRequestModel request;
  const LoginRequested(this.request);
  @override
  List<Object?> get props => [request];
}

// Balance Events
class CheckBalanceRequested extends AviaEvent {}


// Search Events
class SearchOffersRequested extends AviaEvent {
  final SearchOffersRequestModel request;
  const SearchOffersRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class AviaStateReset extends AviaEvent {
  const AviaStateReset();
}

// Offer Events
class OfferDetailRequested extends AviaEvent {
  final String offerId;
  const OfferDetailRequested(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

class FareFamilyRequested extends AviaEvent {
  final String offerId;
  const FareFamilyRequested(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

class FareRulesRequested extends AviaEvent {
  final String offerId;
  const FareRulesRequested(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

// Booking Events
class CreateBookingRequested extends AviaEvent {
  final String offerId;
  final CreateBookingRequestModel request;
  const CreateBookingRequested({required this.offerId, required this.request});
  @override
  List<Object?> get props => [offerId, request];
}

class BookingInfoRequested extends AviaEvent {
  final String bookingId;
  const BookingInfoRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class BookingRulesRequested extends AviaEvent {
  final String bookingId;
  const BookingRulesRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// Payment Events
class CheckPriceRequested extends AviaEvent {
  final String bookingId;
  const CheckPriceRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class PaymentPermissionRequested extends AviaEvent {
  final String bookingId;
  const PaymentPermissionRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class PaymentRequested extends AviaEvent {
  final String bookingId;
  const PaymentRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// Cancel Events
class CancelUnpaidRequested extends AviaEvent {
  final String bookingId;
  const CancelUnpaidRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class VoidTicketRequested extends AviaEvent {
  final String bookingId;
  const VoidTicketRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// Refund Events
class RefundAmountsRequested extends AviaEvent {
  final String bookingId;
  const RefundAmountsRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class AutoCancelRequested extends AviaEvent {
  final String bookingId;
  const AutoCancelRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class ManualRefundRequested extends AviaEvent {
  final String bookingId;
  const ManualRefundRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// Airport Hints Events
class AirportHintsRequested extends AviaEvent {
  final String phrase;
  final int limit;
  const AirportHintsRequested({
    required this.phrase,
    this.limit = 10,
  });
  @override
  List<Object?> get props => [phrase, limit];
}

// PDF Receipt Events
class PdfReceiptRequested extends AviaEvent {
  final String bookingId;
  const PdfReceiptRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// Schedule Events
class ScheduleRequested extends AviaEvent {
  final String departureFrom;
  final String departureTo;
  final String airportFrom;
  const ScheduleRequested({
    required this.departureFrom,
    required this.departureTo,
    required this.airportFrom,
  });
  @override
  List<Object?> get props => [departureFrom, departureTo, airportFrom];
}

// Visa Types Events
class VisaTypesRequested extends AviaEvent {
  final List<String> countries;
  const VisaTypesRequested(this.countries);
  @override
  List<Object?> get props => [countries];
}

// Service Classes Events
class ServiceClassesRequested extends AviaEvent {
  const ServiceClassesRequested();
}

// Passenger Types Events
class PassengerTypesRequested extends AviaEvent {
  const PassengerTypesRequested();
}

// Health Events
class HealthRequested extends AviaEvent {
  const HealthRequested();
}

// User Humans Events
class CreateHumanRequested extends AviaEvent {
  final HumanModel human;
  const CreateHumanRequested(this.human);
  @override
  List<Object?> get props => [human];
}

class GetHumansRequested extends AviaEvent {}

class SearchHumansRequested extends AviaEvent {
  final String name;
  const SearchHumansRequested(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdateHumanRequested extends AviaEvent {
  final String id;
  final HumanModel human;
  const UpdateHumanRequested({required this.id, required this.human});
  @override
  List<Object?> get props => [id, human];
}

class DeleteHumanRequested extends AviaEvent {
  final String id;
  const DeleteHumanRequested(this.id);
  @override
  List<Object?> get props => [id];
}