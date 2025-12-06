import 'package:freezed_annotation/freezed_annotation.dart';

import 'rate_model.dart';

part 'calculate_response.freezed.dart';
part 'calculate_response.g.dart';

@freezed
class CalculateResponse with _$CalculateResponse {
  const factory CalculateResponse({
    required double premium,
    @JsonKey(name: 'car_id') required int carId,
    required int year,
    required double price,
    @JsonKey(name: 'begin_date') required String beginDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'driver_count') required int driverCount,
    required double franchise,
    String? currency,
    // Tariflar - calculate response'da keladi
    @Default([]) @JsonKey(name: 'rates') List<RateModel> rates,
  }) = _CalculateResponse;

  factory CalculateResponse.fromJson(Map<String, dynamic> json) =>
      _$CalculateResponseFromJson(json);
}
