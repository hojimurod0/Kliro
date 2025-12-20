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

