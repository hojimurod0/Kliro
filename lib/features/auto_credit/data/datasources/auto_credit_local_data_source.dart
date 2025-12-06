import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/auto_credit_offer_model.dart';

class AutoCreditLocalDataSource {
  const AutoCreditLocalDataSource();

  Future<List<AutoCreditOfferModel>> fetchAutoCreditOffers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      AutoCreditOfferModel(
        bankName: "Ipak Yuli Bank",
        rating: 4.7,
        monthlyPayment: "9.8 mln so'm",
        interestRate: "14%",
        term: "20 yil",
        maxSum: "2 mlrd so'm",
        applicationMethod: "Onlayn",
        applicationIcon: Icons.check_circle,
        applicationColor: AppColors.accentGreen,
        advantages: const [
          "Past foiz stavkasi",
          "Qisqa muddatda ko'rib chiqish",
          "Keng avtomobil tanlovi",
        ],
      ),
      AutoCreditOfferModel(
        bankName: "Ipak Yuli Bank",
        rating: 4.7,
        monthlyPayment: "9.8 mln so'm",
        interestRate: "14%",
        term: "15 yil",
        maxSum: "2 mlrd so'm",
        applicationMethod: "Bank",
        applicationIcon: Icons.business,
        applicationColor: AppColors.darkTextAutoCredit,
        advantages: const [
          "Past foiz stavkasi",
          "Qisqa muddatda ko'rib chiqish",
          "Keng avtomobil tanlovi",
        ],
      ),
      AutoCreditOfferModel(
        bankName: "Ipak Yuli Bank",
        rating: 4.7,
        monthlyPayment: "9.8 mln so'm",
        interestRate: "14%",
        term: "20 yil",
        maxSum: "2 mlrd so'm",
        applicationMethod: "Onlayn",
        applicationIcon: Icons.check_circle,
        applicationColor: AppColors.accentGreen,
        advantages: const [
          "Past foiz stavkasi",
          "Qisqa muddatda ko'rib chiqish",
          "Keng avtomobil tanlovi",
        ],
      ),
    ];
  }
}

