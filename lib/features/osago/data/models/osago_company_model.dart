import '../../domain/entities/osago_company.dart';

class OsagoCompanyModel extends OsagoCompany {
  const OsagoCompanyModel({
    required super.id,
    required super.name,
  });

  factory OsagoCompanyModel.fromJson(Map<String, dynamic> json) {
    return OsagoCompanyModel(
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

