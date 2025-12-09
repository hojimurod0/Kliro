class PurposeModel {
  const PurposeModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameRu,
    this.nameUz,
  });

  final int id;
  final String name;
  final String? nameEn;
  final String? nameRu;
  final String? nameUz;

  factory PurposeModel.fromJson(Map<String, dynamic> json) {
    // Определяем имя в зависимости от доступных полей
    String name;
    if (json['name'] != null) {
      name = json['name'] as String;
    } else if (json['en'] != null) {
      name = json['en'] as String;
    } else if (json['ru'] != null) {
      name = json['ru'] as String;
    } else if (json['uz'] != null) {
      name = json['uz'] as String;
    } else {
      name = '';
    }

    return PurposeModel(
      id: json['id'] as int,
      name: name,
      nameEn: json['en'] as String?,
      nameRu: json['ru'] as String?,
      nameUz: json['uz'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nameEn != null) 'en': nameEn,
        if (nameRu != null) 'ru': nameRu,
        if (nameUz != null) 'uz': nameUz,
      };
}



