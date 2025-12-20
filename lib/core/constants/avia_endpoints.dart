/// Avia API endpoint konstantalari
class AviaEndpoints {
  AviaEndpoints._();

  // Autentifikatsiya va hisob
  static const String login = '/avia/accounts/tokens';
  static const String checkBalance = '/avia/accounts/check-balance';

  // Qidiruv va takliflar
  static const String searchOffers = '/avia/offers';
  static String checkOffer(String offerId) => '/avia/offers/$offerId';
  static String fareFamily(String offerId) => '/avia/offers/$offerId/fare-family';
  static String offerRules(String offerId) => '/avia/offers/$offerId/rules';
  
  // Legacy qidiruv endpointlari (eski API)
  static const String searchFlights = '/avichiptalar/search';
  static String getFlightDetails(String flightId) => '/avichiptalar/details/$flightId';
  static const String getCities = '/avichiptalar/cities';

  // Bron qilish
  static String createBooking(String offerId) => '/avia/offers/$offerId/booking';
  static String getBooking(String bookingId) => '/avia/booking/$bookingId';
  static String bookingRules(String bookingId) => '/avia/booking/$bookingId/rules';

  // To'lov
  static String checkPrice(String bookingId) => '/avia/booking/$bookingId/check-price';
  static String paymentPermission(String bookingId) => '/avia/booking/$bookingId/payment-permission';
  static String payBooking(String bookingId) => '/avia/booking/$bookingId/payment';

  // Bekor qilish va qaytarishlar
  static String cancelUnpaid(String bookingId) => '/avia/booking/$bookingId/cancel-unpaid';
  static String voidTicket(String bookingId) => '/avia/booking/$bookingId/void';
  static String getRefundAmounts(String bookingId) => '/avia/booking/$bookingId/get-refund-amounts';
  static String autoCancel(String bookingId) => '/avia/booking/$bookingId/auto-cancel';
  static String manualRefund(String bookingId) => '/avia/booking/$bookingId/manual-refund';

  // Hujjatlar va servislar
  static String pdfReceipt(String bookingId) => '/avia/booking/$bookingId/pdf-receipt';
  static const String schedule = '/avia/services/schedule';
  static const String visaTypes = '/avia/visa-types';

  // Qo'shimcha metodlar
  static const String airportHints = '/avia/airport-hints';
  static const String serviceClasses = '/avia/service-classes';
  static const String passengerTypes = '/avia/passenger-types';
  static const String health = '/avia/health';

  // Foydalanuvchi shaxslari endpointlari
  static const String userHumans = '/user/humans';
  static String userHuman(String id) => '/user/humans/$id';
  static const String userHumansSearch = '/user/humans/search';
}

