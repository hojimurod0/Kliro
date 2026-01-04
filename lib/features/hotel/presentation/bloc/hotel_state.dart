part of 'hotel_bloc.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

// Search Loading State with search parameters
class HotelSearchLoading extends HotelState {
  final HotelFilter filter;
  const HotelSearchLoading(this.filter);
  @override
  List<Object?> get props => [filter];
}

// Search States
class HotelSearchSuccess extends HotelState {
  final HotelSearchResult result;
  final HotelFilter? filter;
  const HotelSearchSuccess(this.result, {this.filter});
  @override
  List<Object?> get props => [result, filter];
}

class HotelSearchFailure extends HotelState {
  final String message;
  final HotelFilter? filter; // Last filter for retry
  const HotelSearchFailure(this.message, {this.filter});
  @override
  List<Object?> get props => [message, filter];
}

// Hotel Details States
class HotelDetailsSuccess extends HotelState {
  final Hotel hotel;
  const HotelDetailsSuccess(this.hotel);
  @override
  List<Object?> get props => [hotel];
}

class HotelDetailsFailure extends HotelState {
  final String message;
  const HotelDetailsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Cities States
class HotelCitiesSuccess extends HotelState {
  final List<String> cities;
  const HotelCitiesSuccess(this.cities);
  @override
  List<Object?> get props => [cities];
}

class HotelCitiesFailure extends HotelState {
  final String message;
  const HotelCitiesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class HotelCitiesWithIdsSuccess extends HotelState {
  final List<City> cities;
  const HotelCitiesWithIdsSuccess(this.cities);
  @override
  List<Object?> get props => [cities];
}

class HotelCitiesWithIdsFailure extends HotelState {
  final String message;
  const HotelCitiesWithIdsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Booking Flow States
class HotelQuoteSuccess extends HotelState {
  final HotelQuote quote;
  const HotelQuoteSuccess(this.quote);
  @override
  List<Object?> get props => [quote];
}

class HotelQuoteFailure extends HotelState {
  final String message;
  const HotelQuoteFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class HotelBookingCreateSuccess extends HotelState {
  final HotelBooking booking;
  const HotelBookingCreateSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class HotelBookingCreateFailure extends HotelState {
  final String message;
  const HotelBookingCreateFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class HotelBookingConfirmSuccess extends HotelState {
  final HotelBooking booking;
  const HotelBookingConfirmSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class HotelBookingConfirmFailure extends HotelState {
  final String message;
  const HotelBookingConfirmFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class HotelBookingCancelSuccess extends HotelState {
  final HotelBooking booking;
  const HotelBookingCancelSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class HotelBookingCancelFailure extends HotelState {
  final String message;
  const HotelBookingCancelFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class HotelBookingReadSuccess extends HotelState {
  final HotelBooking booking;
  const HotelBookingReadSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class HotelBookingReadFailure extends HotelState {
  final String message;
  const HotelBookingReadFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// User Bookings States
class HotelUserBookingsLoading extends HotelState {}

class HotelUserBookingsSuccess extends HotelState {
  final List<HotelBooking> bookings;
  const HotelUserBookingsSuccess(this.bookings);
  @override
  List<Object?> get props => [bookings];
}

class HotelUserBookingsFailure extends HotelState {
  final String message;
  const HotelUserBookingsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Reference Data States
// Countries
class HotelCountriesLoading extends HotelState {}

class HotelCountriesSuccess extends HotelState {
  final List<Country> countries;
  const HotelCountriesSuccess(this.countries);
  @override
  List<Object?> get props => [countries];
}

class HotelCountriesFailure extends HotelState {
  final String message;
  const HotelCountriesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotels list (for selection)
class HotelHotelsListSuccess extends HotelState {
  final List<Hotel> hotels;
  const HotelHotelsListSuccess(this.hotels);
  @override
  List<Object?> get props => [hotels];
}

class HotelHotelsListFailure extends HotelState {
  final String message;
  const HotelHotelsListFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Regions
class HotelRegionsLoading extends HotelState {}

class HotelRegionsSuccess extends HotelState {
  final List<Region> regions;
  const HotelRegionsSuccess(this.regions);
  @override
  List<Object?> get props => [regions];
}

class HotelRegionsFailure extends HotelState {
  final String message;
  const HotelRegionsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Types
class HotelTypesLoading extends HotelState {}

class HotelTypesSuccess extends HotelState {
  final List<HotelType> types;
  const HotelTypesSuccess(this.types);
  @override
  List<Object?> get props => [types];
}

class HotelTypesFailure extends HotelState {
  final String message;
  const HotelTypesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Facilities
class HotelFacilitiesLoading extends HotelState {}

class HotelFacilitiesSuccess extends HotelState {
  final List<Facility> facilities;
  const HotelFacilitiesSuccess(this.facilities);
  @override
  List<Object?> get props => [facilities];
}

class HotelFacilitiesFailure extends HotelState {
  final String message;
  const HotelFacilitiesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Facilities
class HotelHotelFacilitiesLoading extends HotelState {}

class HotelHotelFacilitiesSuccess extends HotelState {
  final List<Facility> facilities;
  const HotelHotelFacilitiesSuccess(this.facilities);
  @override
  List<Object?> get props => [facilities];
}

class HotelHotelFacilitiesFailure extends HotelState {
  final String message;
  const HotelHotelFacilitiesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Equipment
class HotelEquipmentLoading extends HotelState {}

class HotelEquipmentSuccess extends HotelState {
  final List<Equipment> equipment;
  const HotelEquipmentSuccess(this.equipment);
  @override
  List<Object?> get props => [equipment];
}

class HotelEquipmentFailure extends HotelState {
  final String message;
  const HotelEquipmentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Room Type Equipment
class HotelRoomTypeEquipmentLoading extends HotelState {}

class HotelRoomTypeEquipmentSuccess extends HotelState {
  final List<Equipment> equipment;
  const HotelRoomTypeEquipmentSuccess(this.equipment);
  @override
  List<Object?> get props => [equipment];
}

class HotelRoomTypeEquipmentFailure extends HotelState {
  final String message;
  const HotelRoomTypeEquipmentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Currencies
class HotelCurrenciesLoading extends HotelState {}

class HotelCurrenciesSuccess extends HotelState {
  final List<Currency> currencies;
  const HotelCurrenciesSuccess(this.currencies);
  @override
  List<Object?> get props => [currencies];
}

class HotelCurrenciesFailure extends HotelState {
  final String message;
  const HotelCurrenciesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Stars
class HotelStarsLoading extends HotelState {}

class HotelStarsSuccess extends HotelState {
  final List<Star> stars;
  const HotelStarsSuccess(this.stars);
  @override
  List<Object?> get props => [stars];
}

class HotelStarsFailure extends HotelState {
  final String message;
  const HotelStarsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Photos
class HotelPhotosLoading extends HotelState {}

class HotelPhotosSuccess extends HotelState {
  final List<HotelPhoto> photos;
  const HotelPhotosSuccess(this.photos);
  @override
  List<Object?> get props => [photos];
}

class HotelPhotosFailure extends HotelState {
  final String message;
  const HotelPhotosFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Room Types
class HotelRoomTypesLoading extends HotelState {}

class HotelRoomTypesSuccess extends HotelState {
  final List<RoomType> roomTypes;
  const HotelRoomTypesSuccess(this.roomTypes);
  @override
  List<Object?> get props => [roomTypes];
}

class HotelRoomTypesFailure extends HotelState {
  final String message;
  const HotelRoomTypesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Room Photos
class HotelRoomPhotosLoading extends HotelState {}

class HotelRoomPhotosSuccess extends HotelState {
  final List<HotelPhoto> photos;
  const HotelRoomPhotosSuccess(this.photos);
  @override
  List<Object?> get props => [photos];
}

class HotelRoomPhotosFailure extends HotelState {
  final String message;
  const HotelRoomPhotosFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Price Range
class HotelPriceRangeLoading extends HotelState {}

class HotelPriceRangeSuccess extends HotelState {
  final PriceRange priceRange;
  const HotelPriceRangeSuccess(this.priceRange);
  @override
  List<Object?> get props => [priceRange];
}

class HotelPriceRangeFailure extends HotelState {
  final String message;
  const HotelPriceRangeFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Nearby Places Types
class HotelNearbyPlacesTypesLoading extends HotelState {}

class HotelNearbyPlacesTypesSuccess extends HotelState {
  final List<NearbyPlaceType> types;
  const HotelNearbyPlacesTypesSuccess(this.types);
  @override
  List<Object?> get props => [types];
}

class HotelNearbyPlacesTypesFailure extends HotelState {
  final String message;
  const HotelNearbyPlacesTypesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Nearby Places
class HotelNearbyPlacesLoading extends HotelState {}

class HotelNearbyPlacesSuccess extends HotelState {
  final List<NearbyPlace> places;
  const HotelNearbyPlacesSuccess(this.places);
  @override
  List<Object?> get props => [places];
}

class HotelNearbyPlacesFailure extends HotelState {
  final String message;
  const HotelNearbyPlacesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Services In Room
class HotelServicesInRoomLoading extends HotelState {}

class HotelServicesInRoomSuccess extends HotelState {
  final List<ServiceInRoom> services;
  const HotelServicesInRoomSuccess(this.services);
  @override
  List<Object?> get props => [services];
}

class HotelServicesInRoomFailure extends HotelState {
  final String message;
  const HotelServicesInRoomFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Hotel Services In Room
class HotelHotelServicesInRoomLoading extends HotelState {}

class HotelHotelServicesInRoomSuccess extends HotelState {
  final List<ServiceInRoom> services;
  const HotelHotelServicesInRoomSuccess(this.services);
  @override
  List<Object?> get props => [services];
}

class HotelHotelServicesInRoomFailure extends HotelState {
  final String message;
  const HotelHotelServicesInRoomFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bed Types
class HotelBedTypesLoading extends HotelState {}

class HotelBedTypesSuccess extends HotelState {
  final List<BedType> bedTypes;
  const HotelBedTypesSuccess(this.bedTypes);
  @override
  List<Object?> get props => [bedTypes];
}

class HotelBedTypesFailure extends HotelState {
  final String message;
  const HotelBedTypesFailure(this.message);
  @override
  List<Object?> get props => [message];
}

