import 'package:flutter/material.dart';

class AutoCreditOffer {
  const AutoCreditOffer({
    required this.bankName,
    required this.rating,
    required this.monthlyPayment,
    required this.interestRate,
    required this.term,
    required this.maxSum,
    required this.applicationMethod,
    required this.applicationIcon,
    required this.applicationColor,
    required this.advantages,
  });

  final String bankName;
  final double rating;
  final String monthlyPayment;
  final String interestRate;
  final String term;
  final String maxSum;
  final String applicationMethod;
  final IconData applicationIcon;
  final Color applicationColor;
  final List<String> advantages;
}

