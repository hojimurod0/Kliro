import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculate_request.freezed.dart';
part 'calculate_request.g.dart';

@freezed
class CalculateRequest with _$CalculateRequest {
  const factory CalculateRequest({
    @JsonKey(name: 'car_id') required int carId,
    required int year,
    required double price,
    @JsonKey(name: 'begin_date') required String beginDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'driver_count') required int driverCount,
    required double franchise,
  }) = _CalculateRequest;

  factory CalculateRequest.fromJson(Map<String, dynamic> json) =>
      _$CalculateRequestFromJson(json);
}
