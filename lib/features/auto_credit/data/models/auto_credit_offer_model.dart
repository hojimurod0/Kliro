import '../../domain/entities/auto_credit_offer.dart';

class AutoCreditOfferModel extends AutoCreditOffer {
  const AutoCreditOfferModel({
    required super.bankName,
    required super.rating,
    required super.monthlyPayment,
    required super.interestRate,
    required super.term,
    required super.maxSum,
    required super.applicationMethod,
    required super.applicationIcon,
    required super.applicationColor,
    required super.advantages,
  });
}

