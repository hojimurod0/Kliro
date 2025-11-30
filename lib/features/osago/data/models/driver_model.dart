import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import 'model_utils.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    @JsonKey(name: 'passport__seria') required String passportSeria,
    @JsonKey(name: 'passport__number') required String passportNumber,
    @JsonKey(
      name: 'driver_birthday',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate,
    )
    required DateTime driverBirthday,
    @JsonKey(name: 'relative') @Default(0) int relative,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'license__seria') String? licenseSeria,
    @JsonKey(name: 'license__number') String? licenseNumber,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}
