import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'tariff_model.g.dart';

@JsonSerializable()
class TariffModel extends Equatable {
  final int id;
  @JsonKey(name: 'insurance_premium')
  final double insurancePremium;
  @JsonKey(name: 'insurance_otv')
  final double insuranceOtv;

  const TariffModel({
    required this.id,
    required this.insurancePremium,
    required this.insuranceOtv,
  });

  factory TariffModel.fromJson(Map<String, dynamic> json) =>
      _$TariffModelFromJson(json);

  Map<String, dynamic> toJson() => _$TariffModelToJson(this);

  @override
  List<Object?> get props => [id, insurancePremium, insuranceOtv];
}

