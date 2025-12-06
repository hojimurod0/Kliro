class CarPriceEntity {
  final double price;
  final int carId;
  final int year;
  final String? currency;

  CarPriceEntity({
    required this.price,
    required this.carId,
    required this.year,
    this.currency,
  });
}

