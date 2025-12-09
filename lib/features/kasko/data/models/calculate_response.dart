import 'package:freezed_annotation/freezed_annotation.dart';

import 'rate_model.dart';

part 'calculate_response.freezed.dart';
part 'calculate_response.g.dart';

@freezed
class CalculateResponse with _$CalculateResponse {
  const factory CalculateResponse({
    double? premium,
    @JsonKey(name: 'car_id') int? carId,
    int? year,
    double? price,
    @JsonKey(name: 'begin_date') String? beginDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'driver_count') int? driverCount,
    double? franchise,
    String? currency,
    // API response format: {result: true, tarif_1: 2310000, tarif_2: 3464000, tarif_3: 5774000, konstruktor: 0}
    @JsonKey(name: 'tarif_1') double? tarif1,
    @JsonKey(name: 'tarif_2') double? tarif2,
    @JsonKey(name: 'tarif_3') double? tarif3,
    double? konstruktor,
    // Tariflar - calculate response'da keladi
    @Default([]) @JsonKey(name: 'rates') List<RateModel>? rates,
  }) = _CalculateResponse;

  factory CalculateResponse.fromJson(Map<String, dynamic> json) =>
      _$CalculateResponseFromJson(json);
}
