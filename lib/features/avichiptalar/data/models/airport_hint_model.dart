import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'airport_hint_model.g.dart';

@JsonSerializable()
class AirportHintModel extends Equatable {
  final String? code;
  final String? name;
  final String? city;
  final String? country;
  @JsonKey(name: 'name_intl')
  final InternationalNames? nameIntl;
  @JsonKey(name: 'city_intl')
  final InternationalNames? cityIntl;
  @JsonKey(name: 'country_intl')
  final InternationalNames? countryIntl;

  const AirportHintModel({
    this.code,
    this.name,
    this.city,
    this.country,
    this.nameIntl,
    this.cityIntl,
    this.countryIntl,
  });

  factory AirportHintModel.fromJson(Map<String, dynamic> json) =>
      _$AirportHintModelFromJson(json);

  Map<String, dynamic> toJson() => _$AirportHintModelToJson(this);

  // O'zbek tilida ko'rsatish uchun
  String get displayName {
    final nameUz = nameIntl?.uz ?? nameIntl?.en ?? name ?? '';
    final cityUz = cityIntl?.uz ?? cityIntl?.en ?? city ?? '';

    if (nameUz.isNotEmpty && cityUz.isNotEmpty) {
      return '$nameUz, $cityUz';
    }
    return nameUz.isNotEmpty ? nameUz : (name ?? code ?? '');
  }

  // To'liq ma'lumot
  String get fullDisplayName {
    final nameUz = nameIntl?.uz ?? nameIntl?.en ?? name ?? '';
    final cityUz = cityIntl?.uz ?? cityIntl?.en ?? city ?? '';
    final countryUz = countryIntl?.uz ?? countryIntl?.en ?? country ?? '';

    if (nameUz.isNotEmpty && cityUz.isNotEmpty && countryUz.isNotEmpty) {
      return '$nameUz, $cityUz, $countryUz';
    }
    return displayName;
  }

  @override
  List<Object?> get props => [
    code,
    name,
    city,
    country,
    nameIntl,
    cityIntl,
    countryIntl,
  ];
}

@JsonSerializable()
class InternationalNames extends Equatable {
  final String? en;
  final String? ru;
  final String? uz;

  const InternationalNames({this.en, this.ru, this.uz});

  factory InternationalNames.fromJson(Map<String, dynamic> json) =>
      _$InternationalNamesFromJson(json);

  Map<String, dynamic> toJson() => _$InternationalNamesToJson(this);

  @override
  List<Object?> get props => [en, ru, uz];
}
