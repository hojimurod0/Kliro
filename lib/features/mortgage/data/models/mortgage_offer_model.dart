import '../../domain/entities/mortgage_offer.dart';

class MortgageOfferModel extends MortgageOffer {
  const MortgageOfferModel({
    required super.bankName,
    required super.rating,
    required super.interestRate,
    required super.term,
    required super.maxSum,
    required super.downPayment,
    required super.advantages,
  });
}

