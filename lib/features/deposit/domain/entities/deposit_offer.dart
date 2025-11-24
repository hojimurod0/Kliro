import 'package:flutter/material.dart';

class DepositOffer {
  const DepositOffer({
    required this.bankName,
    required this.currency,
    required this.rating,
    required this.interestRate,
    required this.term,
    required this.amount,
    required this.logoColor,
    required this.logoIcon,
  });

  final String bankName;
  final String currency;
  final double rating;
  final String interestRate;
  final String term;
  final String amount;
  final Color logoColor;
  final IconData logoIcon;
}
