import '../../domain/entities/osago_type.dart';

class OsagoTypeModel extends OsagoType {
  const OsagoTypeModel({
    required super.id,
    required super.name,
  });

  factory OsagoTypeModel.fromJson(Map<String, dynamic> json) {
    return OsagoTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

