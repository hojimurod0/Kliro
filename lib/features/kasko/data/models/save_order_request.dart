import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_order_request.freezed.dart';
part 'save_order_request.g.dart';

@freezed
class Sugurtalovchi with _$Sugurtalovchi {
  const factory Sugurtalovchi({
    @JsonKey(name: 'passportSeries') required String passportSeries,
    @JsonKey(name: 'passportNumber') required String passportNumber,
    required String birthday,
    required String phone,
  }) = _Sugurtalovchi;

  factory Sugurtalovchi.fromJson(Map<String, dynamic> json) =>
      _$SugurtalovchiFromJson(json);
}

@freezed
class CarData with _$CarData {
  const factory CarData({
    @JsonKey(name: 'car_nomer') required String carNomer,
    required String seria,
    required String number,
    @JsonKey(name: 'price_of_car') required String priceOfCar,
  }) = _CarData;

  factory CarData.fromJson(Map<String, dynamic> json) =>
      _$CarDataFromJson(json);
}

@freezed
class SaveOrderRequest with _$SaveOrderRequest {
  const factory SaveOrderRequest({
    required Sugurtalovchi sugurtalovchi,
    required CarData car,
    @JsonKey(name: 'begin_date') required String beginDate,
    required int liability,
    required int premium,
    @JsonKey(name: 'tarif_id') required int tarifId,
    @JsonKey(name: 'tarif_type') required int tarifType,
  }) = _SaveOrderRequest;

  factory SaveOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveOrderRequestFromJson(json);
}
