import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import 'insurance_model.dart';
import 'vehicle_model.dart';

part 'calc_response.freezed.dart';
part 'calc_response.g.dart';

@freezed
class CalcResponse with _$CalcResponse {
  const factory CalcResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'currency') required String currency,
    @JsonKey(name: 'provider') String? provider,
    @JsonKey(name: 'vehicle') VehicleModel? vehicle,
    @JsonKey(name: 'insurance') InsuranceModel? insurance,
    @JsonKey(name: 'available_providers')
    @Default(<InsuranceModel>[])
    List<InsuranceModel> availableProviders,
    @JsonKey(name: 'owner_name') String? ownerName,
    @JsonKey(name: 'number_drivers_id') String? numberDriversId,
  }) = _CalcResponse;

  factory CalcResponse.fromJson(Map<String, dynamic> json) =>
      _$CalcResponseFromJson(json);
}
