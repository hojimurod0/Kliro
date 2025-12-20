import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../entities/avichipta.dart';
import '../entities/avichipta_filter.dart';
import '../entities/avichipta_search_result.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/balance_response_model.dart';
import '../../data/models/search_offers_request_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/create_booking_request_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/fare_family_model.dart';
import '../../data/models/fare_rules_model.dart';
import '../../data/models/price_check_model.dart';
import '../../data/models/payment_permission_model.dart';
import '../../data/models/payment_response_model.dart';
import '../../data/models/refund_amounts_model.dart';
import '../../data/models/cancel_response_model.dart';
import '../../data/models/airport_hint_model.dart';
import '../../data/models/human_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/visa_type_model.dart';
import '../../data/models/service_class_model.dart';
import '../../data/models/passenger_type_model.dart';
import '../../data/models/health_model.dart';

abstract class AvichiptalarRepository {
  // Search methods
  Future<AvichiptaSearchResult> searchFlights({
    AvichiptaFilter filter = AvichiptaFilter.empty,
  });

  Future<Avichipta> getFlightDetails({required String flightId});

  Future<List<String>> getCities({String? query});

  // Auth methods
  Future<Either<AppException, LoginResponseModel>> login(
    LoginRequestModel request,
  );

  Future<Either<AppException, BalanceResponseModel>> checkBalance();

  // Offers methods
  Future<Either<AppException, OffersResponseModel>> searchOffers(
    SearchOffersRequestModel request,
  );

  Future<Either<AppException, OfferModel>> checkOffer(String offerId);

  Future<Either<AppException, FareFamilyResponseModel>> fareFamily(
    String offerId,
  );

  Future<Either<AppException, FareRulesModel>> fareRules(String offerId);

  // Booking methods
  Future<Either<AppException, BookingModel>> createBooking(
    String offerId,
    CreateBookingRequestModel request,
  );

  Future<Either<AppException, BookingModel>> getBooking(String bookingId);

  Future<Either<AppException, FareRulesModel>> bookingRules(String bookingId);

  // Payment methods
  Future<Either<AppException, PriceCheckModel>> checkPrice(String bookingId);

  Future<Either<AppException, PaymentPermissionModel>> paymentPermission(
    String bookingId,
  );

  Future<Either<AppException, PaymentResponseModel>> payBooking(
    String bookingId,
  );

  // Cancel methods
  Future<Either<AppException, CancelResponseModel>> cancelUnpaid(
    String bookingId,
  );

  Future<Either<AppException, CancelResponseModel>> voidTicket(
    String bookingId,
  );

  // Refund methods
  Future<Either<AppException, RefundAmountsModel>> getRefundAmounts(
    String bookingId,
  );

  Future<Either<AppException, CancelResponseModel>> autoCancel(
    String bookingId,
  );

  Future<Either<AppException, CancelResponseModel>> manualRefund(
    String bookingId,
  );

  // Airport Hints
  Future<Either<AppException, List<AirportHintModel>>> getAirportHints({
    required String phrase,
    int limit = 10,
  });

  // Documents and Services
  Future<Either<AppException, String>> getPdfReceipt(String bookingId);

  Future<Either<AppException, List<ScheduleModel>>> getSchedule({
    required String departureFrom,
    required String departureTo,
    required String airportFrom,
  });

  Future<Either<AppException, List<VisaTypeModel>>> getVisaTypes({
    required List<String> countries,
  });

  // Additional methods
  Future<Either<AppException, List<ServiceClassModel>>> getServiceClasses();

  Future<Either<AppException, List<PassengerTypeModel>>> getPassengerTypes();

  Future<Either<AppException, HealthModel>> getHealth();

  // User Humans methods
  Future<Either<AppException, HumanModel>> createHuman(HumanModel human);

  Future<Either<AppException, List<HumanModel>>> getHumans();

  Future<Either<AppException, List<HumanModel>>> searchHumans({
    required String name,
  });

  Future<Either<AppException, HumanModel>> updateHuman(
    String id,
    HumanModel human,
  );

  Future<Either<AppException, void>> deleteHuman(String id);
}

