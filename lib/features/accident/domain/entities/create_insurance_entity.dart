import 'payment_urls_entity.dart';

class CreateInsuranceEntity {
  final int anketaId;
  final PaymentUrlsEntity paymentUrls;
  final int? insurancePremium;

  const CreateInsuranceEntity({
    required this.anketaId,
    required this.paymentUrls,
    this.insurancePremium,
  });
}

