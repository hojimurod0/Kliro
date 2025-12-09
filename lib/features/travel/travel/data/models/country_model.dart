class CountryModel {
  const CountryModel({
    required this.code,
    required this.name,
    this.flag,
    this.en,
    this.ru,
    this.uz,
  });

  final String code;
  final String name;
  final String? flag;
  final String? en;
  final String? ru;
  final String? uz;

  factory CountryModel.fromJson(Map<String, dynamic> json) {
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
      name = json['code'] as String? ?? '';
    }

    return CountryModel(
      code: json['code'] as String,
      name: name,
      flag: json['flag'] as String?,
      en: json['en'] as String?,
      ru: json['ru'] as String?,
      uz: json['uz'] as String?,
    );
  }

  /// Получает локализованное имя страны
  String getLocalizedName(String locale) {
    switch (locale) {
      case 'uz':
      case 'uz_CYR':
        return uz ?? name;
      case 'ru':
        return ru ?? name;
      case 'en':
        return en ?? name;
      default:
        return name;
    }
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        if (flag != null) 'flag': flag,
        if (en != null) 'en': en,
        if (ru != null) 'ru': ru,
        if (uz != null) 'uz': uz,
      };
}

