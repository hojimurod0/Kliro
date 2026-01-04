part of 'hotel_bloc.dart';

abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object?> get props => [];
}

// Search Events
class SearchHotelsRequested extends HotelEvent {
  final HotelFilter filter;
  const SearchHotelsRequested(this.filter);
  @override
  List<Object?> get props => [filter];
}

class HotelStateReset extends HotelEvent {
  const HotelStateReset();
}

// Hotel Details Events
class GetHotelDetailsRequested extends HotelEvent {
  final String hotelId;
  const GetHotelDetailsRequested(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

// Cities Events
class GetCitiesRequested extends HotelEvent {
  final String query;
  const GetCitiesRequested(this.query);
  @override
  List<Object?> get props => [query];
}

class GetCitiesWithIdsRequested extends HotelEvent {
  final int? countryId;
  const GetCitiesWithIdsRequested({this.countryId});
  @override
  List<Object?> get props => [countryId];
}

// Booking Flow Events
class GetQuoteRequested extends HotelEvent {
  final List<String> optionRefIds;
  const GetQuoteRequested(this.optionRefIds);
  @override
  List<Object?> get props => [optionRefIds];
}

class CreateBookingRequested extends HotelEvent {
  final CreateHotelBookingRequest request;
  const CreateBookingRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class ConfirmBookingRequested extends HotelEvent {
  final String bookingId;
  final PaymentInfo paymentInfo;
  const ConfirmBookingRequested({
    required this.bookingId,
    required this.paymentInfo,
  });
  @override
  List<Object?> get props => [bookingId, paymentInfo];
}

class CancelBookingRequested extends HotelEvent {
  final String bookingId;
  final String? cancellationReason;
  const CancelBookingRequested({
    required this.bookingId,
    this.cancellationReason,
  });
  @override
  List<Object?> get props => [bookingId, cancellationReason];
}

class ReadBookingRequested extends HotelEvent {
  final String bookingId;
  const ReadBookingRequested(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// User Bookings Events
class GetUserBookingsRequested extends HotelEvent {
  const GetUserBookingsRequested();
}

// Reference Data Events
class GetCountriesRequested extends HotelEvent {
  const GetCountriesRequested();
}

class GetHotelsListRequested extends HotelEvent {
  final int? hotelTypeId;
  final int? countryId;
  final int? regionId;
  final int? cityId;
  const GetHotelsListRequested({this.hotelTypeId, this.countryId, this.regionId, this.cityId});
  @override
  List<Object?> get props => [hotelTypeId, countryId, regionId, cityId];
}

class GetRegionsRequested extends HotelEvent {
  final int? countryId;
  const GetRegionsRequested({this.countryId});
  @override
  List<Object?> get props => [countryId];
}

class GetHotelTypesRequested extends HotelEvent {
  const GetHotelTypesRequested();
}

class GetFacilitiesRequested extends HotelEvent {
  const GetFacilitiesRequested();
}

class GetHotelFacilitiesRequested extends HotelEvent {
  final int hotelId;
  const GetHotelFacilitiesRequested(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

class GetEquipmentRequested extends HotelEvent {
  const GetEquipmentRequested();
}

class GetRoomTypeEquipmentRequested extends HotelEvent {
  final int roomTypeId;
  const GetRoomTypeEquipmentRequested(this.roomTypeId);
  @override
  List<Object?> get props => [roomTypeId];
}

class GetCurrenciesRequested extends HotelEvent {
  const GetCurrenciesRequested();
}

class GetStarsRequested extends HotelEvent {
  const GetStarsRequested();
}

class GetHotelPhotosRequested extends HotelEvent {
  final int hotelId;
  const GetHotelPhotosRequested(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

class GetHotelRoomTypesRequested extends HotelEvent {
  final int hotelId;
  const GetHotelRoomTypesRequested(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

class GetHotelRoomPhotosRequested extends HotelEvent {
  final int? hotelId;
  final int? roomTypeId;
  const GetHotelRoomPhotosRequested({this.hotelId, this.roomTypeId});
  @override
  List<Object?> get props => [hotelId, roomTypeId];
}

class GetPriceRangeRequested extends HotelEvent {
  const GetPriceRangeRequested();
}

class GetNearbyPlacesTypesRequested extends HotelEvent {
  const GetNearbyPlacesTypesRequested();
}

class GetHotelNearbyPlacesRequested extends HotelEvent {
  final int hotelId;
  const GetHotelNearbyPlacesRequested(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

class GetServicesInRoomRequested extends HotelEvent {
  const GetServicesInRoomRequested();
}

class GetHotelServicesInRoomRequested extends HotelEvent {
  final int hotelId;
  const GetHotelServicesInRoomRequested(this.hotelId);
  @override
  List<Object?> get props => [hotelId];
}

class GetBedTypesRequested extends HotelEvent {
  const GetBedTypesRequested();
}

