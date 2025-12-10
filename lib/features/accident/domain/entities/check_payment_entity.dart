import 'policy_info_entity.dart';
import 'download_urls_entity.dart';

class CheckPaymentEntity {
  final int statusPayment;
  final int statusPolicy;
  final String? paymentType;
  final PolicyInfoEntity? policyInfo;
  final DownloadUrlsEntity? downloadUrls;

  const CheckPaymentEntity({
    required this.statusPayment,
    required this.statusPolicy,
    this.paymentType,
    this.policyInfo,
    this.downloadUrls,
  });
}
