import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'payment_urls_model.dart';

part 'create_insurance_response.g.dart';

@JsonSerializable()
class CreateInsuranceResponse extends Equatable {
  @JsonKey(name: 'anketa_id')
  final int anketaId;
  @JsonKey(name: 'payment_urls')
  final PaymentUrlsModel paymentUrls;
  @JsonKey(name: 'insurance_premium')
  final int? insurancePremium;

  const CreateInsuranceResponse({
    required this.anketaId,
    required this.paymentUrls,
    this.insurancePremium,
  });

  factory CreateInsuranceResponse.fromJson(Map<String, dynamic> json) {
    // Null safety: anketa_id va payment_urls ni tekshirish
    final anketaIdValue = json['anketa_id'];
    if (anketaIdValue == null) {
      throw FormatException('anketa_id is null in CreateInsuranceResponse');
    }
    
    final paymentUrlsValue = json['payment_urls'];
    if (paymentUrlsValue == null) {
      throw FormatException('payment_urls is null in CreateInsuranceResponse');
    }
    
    return _$CreateInsuranceResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CreateInsuranceResponseToJson(this);

  @override
  List<Object?> get props => [anketaId, paymentUrls];
}

