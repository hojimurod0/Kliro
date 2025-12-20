import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

class GetHotelDetails {
  GetHotelDetails(this._repository);

  final HotelRepository _repository;

  Future<Hotel> call({required String hotelId}) {
    return _repository.getHotelDetails(hotelId: hotelId);
  }
}

