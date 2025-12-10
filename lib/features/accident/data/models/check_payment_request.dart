import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'check_payment_request.g.dart';

@JsonSerializable()
class CheckPaymentRequest extends Equatable {
  @JsonKey(name: 'anketa_id')
  final int anketaId;
  final String lan;

  const CheckPaymentRequest({
    required this.anketaId,
    required this.lan,
  });

  factory CheckPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckPaymentRequestToJson(this);

  @override
  List<Object?> get props => [anketaId, lan];
}

