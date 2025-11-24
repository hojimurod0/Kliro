import 'package:flutter/material.dart';

import '../../domain/entities/deposit_offer.dart';

class DepositOfferModel extends DepositOffer {
  const DepositOfferModel({
    required super.bankName,
    required super.currency,
    required super.rating,
    required super.interestRate,
    required super.term,
    required super.amount,
    required super.logoColor,
    required super.logoIcon,
  });

  factory DepositOfferModel.fromData({
    required String bankName,
    required String currency,
    required double rating,
    required String interestRate,
    required String term,
    required String amount,
    required Color logoColor,
    required IconData logoIcon,
  }) {
    return DepositOfferModel(
      bankName: bankName,
      currency: currency,
      rating: rating,
      interestRate: interestRate,
      term: term,
      amount: amount,
      logoColor: logoColor,
      logoIcon: logoIcon,
    );
  }
}
