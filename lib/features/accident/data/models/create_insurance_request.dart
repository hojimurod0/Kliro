import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'person_model.dart';

part 'create_insurance_request.g.dart';

@JsonSerializable()
class CreateInsuranceRequest extends Equatable {
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'tariff_id')
  final int tariffId;
  final PersonModel person;

  const CreateInsuranceRequest({
    required this.startDate,
    required this.tariffId,
    required this.person,
  });

  factory CreateInsuranceRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInsuranceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInsuranceRequestToJson(this);

  @override
  List<Object?> get props => [startDate, tariffId, person];
}

