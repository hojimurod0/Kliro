import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import 'driver_model.dart';
import 'model_utils.dart';

part 'create_request.freezed.dart';
part 'create_request.g.dart';

@freezed
class CreateRequest with _$CreateRequest {
  const factory CreateRequest({
    required String provider,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'drivers') required List<DriverModel> drivers,
    @JsonKey(name: 'applicant_is_driver') @Default(false) bool applicantIsDriver,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    @JsonKey(name: 'owner__inn') String? ownerInn,
    @JsonKey(name: 'applicant__license_seria') String? applicantLicenseSeria,
    @JsonKey(name: 'applicant__license_number') String? applicantLicenseNumber,
    @JsonKey(
      name: 'start_date',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate,
    )
    required DateTime startDate,
  }) = _CreateRequest;

  factory CreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRequestFromJson(json);
}
