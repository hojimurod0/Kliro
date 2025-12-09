import '../entities/save_order_entity.dart';
import '../repositories/kasko_repository.dart';

class SaveOrder {
  SaveOrder(this._repository);

  final KaskoRepository _repository;

  Future<SaveOrderEntity> call({
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
  }) {
    return _repository.saveOrder(
      carId: carId,
      year: year,
      price: price,
      beginDate: beginDate,
      endDate: endDate,
      driverCount: driverCount,
      franchise: franchise,
      premium: premium,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      ownerPassport: ownerPassport,
      carNumber: carNumber,
      vin: vin,
      birthDate: birthDate,
      tarifId: tarifId,
      tarifType: tarifType,
    );
  }
}

