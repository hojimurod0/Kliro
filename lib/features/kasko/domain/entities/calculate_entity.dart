import 'rate_entity.dart';

class CalculateEntity {
  final double premium;
  final int carId;
  final int year;
  final double price;
  final DateTime beginDate;
  final DateTime endDate;
  final int driverCount;
  final double franchise;
  final String? currency;
  // Tariflar - calculate response'da keladi
  final List<RateEntity> rates;

  CalculateEntity({
    required this.premium,
    required this.carId,
    required this.year,
    required this.price,
    required this.beginDate,
    required this.endDate,
    required this.driverCount,
    required this.franchise,
    this.currency,
    this.rates = const [],
  });
}

