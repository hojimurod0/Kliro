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
  const HotelSearchFailure(this.message);
  @override
  List<Object?> get props => [message];
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

