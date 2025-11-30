import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import 'model_utils.dart';

part 'insurance_model.freezed.dart';
part 'insurance_model.g.dart';

@freezed
class InsuranceModel with _$InsuranceModel {
  const factory InsuranceModel({
    required String provider,
    @JsonKey(name: 'company_name') required String companyName,
    @JsonKey(name: 'period_id') required String periodId,
    @JsonKey(name: 'number_drivers_id') required String numberDriversId,
    @JsonKey(
      name: 'start_date',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate,
    )
    required DateTime startDate,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    @JsonKey(name: 'owner__inn') String? ownerInn,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isUnlimited,
  }) = _InsuranceModel;

  factory InsuranceModel.fromJson(Map<String, dynamic> json) =>
      _$InsuranceModelFromJson(json);
}
