/// Константы эндпоинтов Hotelios API
class HotelEndpoints {
  HotelEndpoints._();

  // Справочные API (v1.0)
  static const String getCountries = '/hotels/countries';
  static const String getRegions = '/hotels/regions';
  static const String getCities = '/hotels/cities';
  static const String getHotelTypes = '/hotels/types';
  static const String getHotelList = '/hotels/list';
  static const String getHotelPhotos = '/hotels/photos';
  static const String getHotelRoomTypes = '/hotels/room-types';
  static const String getHotelRoomPhotos = '/hotels/room-photos';
  static const String getFacilities = '/hotels/facilities';
  static const String getHotelFacilities = '/hotels/hotel-facilities';
  static const String getEquipment = '/hotels/equipment';
  static const String getRoomTypeEquipment = '/hotels/room-equipment';
  static const String getPriceRange = '/hotels/price-range';
  static const String getCurrencies = '/hotels/currencies';
  static const String getStars = '/hotels/stars';
  static const String getNearbyPlacesTypes = '/hotels/nearby-places-types';
  static const String getHotelNearbyPlaces = '/hotels/hotel-nearby-places';
  static const String getServicesInRoom = '/hotels/services-in-room';
  static const String getHotelServicesInRoom = '/hotels/hotel-services-in-room';
  static const String getBedTypes = '/hotels/bed-types';

  // Booking-Flow API (v1.1.0)
  static const String searchHotels = '/hotels/search';
  static const String getQuote = '/hotels/quote';
  static const String createBooking = '/hotels/booking/create';
  static const String confirmBooking = '/hotels/booking/confirm';
  static const String cancelBooking = '/hotels/booking/cancel';
  static const String readBooking = '/hotels/booking/read';
  static const String getUserBookings = '/hotels/booking/list';
}

