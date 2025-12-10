import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'policy_info_model.dart';
import 'download_urls_model.dart';

part 'check_payment_response.g.dart';

@JsonSerializable()
class CheckPaymentResponse extends Equatable {
  @JsonKey(name: 'status_payment')
  final int statusPayment;
  @JsonKey(name: 'status_policy')
  final int statusPolicy;
  @JsonKey(name: 'payment_type')
  final String? paymentType;
  @JsonKey(name: 'policy_info')
  final PolicyInfoModel? policyInfo;
  @JsonKey(name: 'download_urls')
  final DownloadUrlsModel? downloadUrls;

  const CheckPaymentResponse({
    required this.statusPayment,
    required this.statusPolicy,
    this.paymentType,
    this.policyInfo,
    this.downloadUrls,
  });

  factory CheckPaymentResponse.fromJson(Map<String, dynamic> json) {
    // Null safety: status_payment va status_policy ni tekshirish
    final statusPaymentValue = json['status_payment'];
    if (statusPaymentValue == null) {
      throw FormatException('status_payment is null in CheckPaymentResponse');
    }
    
    final statusPolicyValue = json['status_policy'];
    if (statusPolicyValue == null) {
      throw FormatException('status_policy is null in CheckPaymentResponse');
    }
    
    return _$CheckPaymentResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CheckPaymentResponseToJson(this);

  @override
  List<Object?> get props => [
        statusPayment,
        statusPolicy,
        paymentType,
        policyInfo,
        downloadUrls,
      ];
}

