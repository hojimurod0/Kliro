import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import 'model_utils.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

@freezed
class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String brand,
    required String model,
    @JsonKey(name: 'gos_number') required String gosNumber,
    @JsonKey(name: 'tech_sery') required String techSeria,
    @JsonKey(name: 'tech_number') required String techNumber,
    @JsonKey(name: 'owner__pass_seria') required String ownerPassportSeria,
    @JsonKey(name: 'owner__pass_number') required String ownerPassportNumber,
    @JsonKey(
      name: 'owner_birth_date',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate,
    )
    required DateTime ownerBirthDate,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(true)
    bool isOwner,
  }) = _VehicleModel;

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
}
