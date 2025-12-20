import '../entities/car_entity.dart';
import '../entities/car_page.dart';
import '../entities/calculate_entity.dart';
import '../entities/car_price_entity.dart';
import '../entities/check_payment_entity.dart';
import '../entities/image_upload_entity.dart';
import '../entities/payment_link_entity.dart';
import '../entities/rate_entity.dart';
import '../entities/save_order_entity.dart';

abstract class KaskoRepository {
  Future<List<CarEntity>> getCars();
  Future<CarPage> getCarsPaginated({
    required int page,
    required int size,
  });
  Future<List<CarEntity>> getCarsMinimal(); // Faqat brand, model, position uchun
  Future<List<RateEntity>> getRates();
  Future<CarPriceEntity> calculateCarPrice({
    required int carId, // Bu aslida car_position_id
    required int tarifId,
    required int year,
  });
  Future<CalculateEntity> calculatePolicy({
    required int carId,
    required int year,
    required double price,
    required DateTime beginDate,
    required DateTime endDate,
    required int driverCount,
    required double franchise,
    int? selectedRateId,
  });
  Future<SaveOrderEntity> saveOrder({
    required int carId,
    required int year,
    required double price,
    required DateTime beginDate,
    required DateTime endDate,
    required int driverCount,
    required double franchise,
    required double premium,
    required String ownerName,
    required String ownerPhone,
    required String ownerPassport,
    required String carNumber,
    required String vin,
    required String birthDate,
    required int tarifId,
    required int tarifType,
  });
  Future<PaymentLinkEntity> getPaymentLink({
    required String orderId,
    String? contractId,
    required double amount,
    required String returnUrl,
    required String callbackUrl,
  });
  Future<CheckPaymentEntity> checkPaymentStatus({
    required String orderId,
    required String transactionId,
  });
  Future<ImageUploadEntity> uploadImage({
    required String filePath,
    required String orderId,
    required String imageType,
  });
}
