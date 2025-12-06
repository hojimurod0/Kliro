class RateEntity {
  final int id;
  final String name;
  final String description;
  final double? minPremium;
  final double? maxPremium;
  final double franchise;
  final double? percent; // API'dan keladigan percent field

  RateEntity({
    required this.id,
    required this.name,
    this.description = '',
    this.minPremium,
    this.maxPremium,
    this.franchise = 0,
    this.percent,
  });
}

