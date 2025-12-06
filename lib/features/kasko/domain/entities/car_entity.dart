class CarEntity {
  final int id;
  final String name;
  final String? brand;
  final String? model;
  final int? year;

  CarEntity({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    this.year,
  });
}

