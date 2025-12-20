/// Константы эндпоинтов Hotel API
class HotelEndpoints {
  HotelEndpoints._();

  // Поиск отелей
  static const String searchHotels = '/hotel/search';
  static String getHotelDetails(String hotelId) => '/hotel/details/$hotelId';
  static const String getCities = '/hotel/cities';
}

