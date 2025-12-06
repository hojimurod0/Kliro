import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_model.freezed.dart';
part 'rate_model.g.dart';

@freezed
class RateModel with _$RateModel {
  const factory RateModel({
    required int id,
    required String name,
    @Default('') String description, // Optional, default empty
    @JsonKey(name: 'min_premium') double? minPremium,
    @JsonKey(name: 'max_premium') double? maxPremium,
    @Default(0) double franchise,
    double? percent, // API'dan keladigan percent field
  }) = _RateModel;

  factory RateModel.fromJson(Map<String, dynamic> json) =>
      _$RateModelFromJson(json);
}
