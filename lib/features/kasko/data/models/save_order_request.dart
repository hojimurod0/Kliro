import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_order_request.freezed.dart';
part 'save_order_request.g.dart';

@freezed
class SaveOrderRequest with _$SaveOrderRequest {
  const factory SaveOrderRequest({
    @JsonKey(name: 'car_id') required int carId,
    required int year,
    required double price,
    @JsonKey(name: 'begin_date') required String beginDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'driver_count') required int driverCount,
    required double franchise,
    required double premium,
    @JsonKey(name: 'owner_name') required String ownerName,
    @JsonKey(name: 'owner_phone') required String ownerPhone,
    @JsonKey(name: 'owner_passport') required String ownerPassport,
    @JsonKey(name: 'car_number') required String carNumber,
    required String vin,
  }) = _SaveOrderRequest;

  factory SaveOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveOrderRequestFromJson(json);
}
