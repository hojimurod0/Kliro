import '../entities/hotel.dart';
import '../entities/hotel_filter.dart';
import '../entities/hotel_search_result.dart';

abstract class HotelRepository {
  // Search methods
  Future<HotelSearchResult> searchHotels({
    HotelFilter filter = HotelFilter.empty,
  });

  Future<Hotel> getHotelDetails({required String hotelId});

  Future<List<String>> getCities({String? query});
}

