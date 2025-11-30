import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

part 'calc_request.freezed.dart';
part 'calc_request.g.dart';

@freezed
class CalcRequest with _$CalcRequest {
  const factory CalcRequest({
    @JsonKey(name: 'gos_number') required String gosNumber,
    @JsonKey(name: 'tech_sery') required String techSeria,
    @JsonKey(name: 'tech_number') required String techNumber,
    @JsonKey(name: 'owner__pass_seria') required String ownerPassSeria,
    @JsonKey(name: 'owner__pass_number') required String ownerPassNumber,
    @JsonKey(name: 'period_id') required String periodId,
    @JsonKey(name: 'number_drivers_id') required String numberDriversId,
  }) = _CalcRequest;

  factory CalcRequest.fromJson(Map<String, dynamic> json) =>
      _$CalcRequestFromJson(json);
}
