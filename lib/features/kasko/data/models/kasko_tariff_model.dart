import '../../domain/entities/kasko_tariff.dart';

class KaskoTariffModel extends KaskoTariff {
  const KaskoTariffModel({
    required super.id,
    required super.title,
    required super.duration,
    required super.description,
    required super.price,
  });

  factory KaskoTariffModel.fromJson(Map<String, dynamic> json) {
    return KaskoTariffModel(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: json['duration'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'description': description,
      'price': price,
    };
  }
}

