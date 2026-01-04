import '../entities/hotel_filter.dart';
import '../entities/hotel_search_result.dart';
import '../entities/hotel_booking.dart';
import '../entities/city.dart';
import '../entities/hotel.dart';
import '../entities/reference_data.dart';

abstract class HotelRepository {
  // Search methods
  Future<HotelSearchResult> searchHotels({
    HotelFilter filter = HotelFilter.empty,
  });

  Future<Hotel> getHotelDetails({required String hotelId});
  
  /// Get hotels list (lightweight list for selection)
  Future<List<Hotel>> getHotelsList({int? hotelTypeId, int? countryId, int? regionId, int? cityId});

  Future<List<String>> getCities({String? query});

  /// Get cities with IDs - для mapping city name → city_id
  Future<List<City>> getCitiesWithIds({int? countryId});

  // Booking Flow methods
  /// Get quote - актуальные цены для выбранного отеля
  Future<HotelQuote> getQuote({
    required List<String> optionRefIds,
  });

  /// Create booking - создать бронирование
  Future<HotelBooking> createBooking({
    required CreateHotelBookingRequest request,
  });

  /// Confirm booking - подтвердить бронирование после оплаты
  Future<HotelBooking> confirmBooking({
    required String bookingId,
    required PaymentInfo paymentInfo,
  });

  /// Cancel booking - отменить бронирование
  Future<HotelBooking> cancelBooking({
    required String bookingId,
    String? cancellationReason,
  });

  /// Read booking - получить детали бронирования
  Future<HotelBooking> readBooking({
    required String bookingId,
  });

  /// Get user bookings - получить список бронирований пользователя
  Future<List<HotelBooking>> getUserBookings();

  // Reference Data methods
  /// Get countries list
  Future<List<Country>> getCountries();

  /// Get regions list
  Future<List<Region>> getRegions({int? countryId});

  /// Get hotel types list
  Future<List<HotelType>> getHotelTypes();

  /// Get facilities list
  Future<List<Facility>> getFacilities();

  /// Get hotel facilities list
  Future<List<Facility>> getHotelFacilities({required int hotelId});

  /// Get equipment list
  Future<List<Equipment>> getEquipment();

  /// Get room type equipment list
  Future<List<Equipment>> getRoomTypeEquipment({required int roomTypeId, int? hotelId});

  /// Get currencies list
  Future<List<Currency>> getCurrencies();

  /// Get stars list
  Future<List<Star>> getStars();

  /// Get hotel photos
  Future<List<HotelPhoto>> getHotelPhotos({required int hotelId});

  /// Get hotel room types
  Future<List<RoomType>> getHotelRoomTypes({required int hotelId});

  /// Get hotel room photos
  Future<List<HotelPhoto>> getHotelRoomPhotos({
    int? hotelId,
    int? roomTypeId,
  });

  /// Get price range
  Future<PriceRange> getPriceRange();

  /// Get nearby places types
  Future<List<NearbyPlaceType>> getNearbyPlacesTypes();

  /// Get hotel nearby places
  Future<List<NearbyPlace>> getHotelNearbyPlaces({required int hotelId});

  /// Get services in room list
  Future<List<ServiceInRoom>> getServicesInRoom();

  /// Get hotel services in room
  Future<List<ServiceInRoom>> getHotelServicesInRoom({required int hotelId});

  /// Get bed types list
  Future<List<BedType>> getBedTypes();
}
