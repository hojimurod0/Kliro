import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/card_offer.dart';
import '../models/card_offer_model.dart';

class CardLocalDataSource {
  const CardLocalDataSource();

  Future<List<CardOfferModel>> fetchCardOffers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      CardOfferModel(
        bankName: "Ipak Yuli Bank",
        cardName: "Premium Visa",
        currency: "USD",
        rating: 4.8,
        cardTag: "Visa",
        typeTag: "Kredit",
        typeTagColor: AppColors.primaryBlue,
        metrics: [
          const CardMetric(
            icon: Icons.percent,
            label: 'Cashback',
            value: '5%',
            valueColor: AppColors.accentGreen,
          ),
          CardMetric(
            icon: Icons.calendar_today_outlined,
            label: 'Yillik',
            value: 'Bepul',
            valueColor: AppColors.accentGreen,
          ),
          CardMetric(
            icon: Icons.ssid_chart,
            label: 'Limit',
            value: '\$5,000',
            valueColor: AppColors.primaryBlue,
          ),
          CardMetric(
            icon: Icons.auto_awesome,
            label: 'Grace',
            value: '60 kun',
            valueColor: AppColors.accentPurple,
          ),
        ],
        advantagesCount: 3,
        isPrimaryCard: true,
      ),
      CardOfferModel(
        bankName: "Xalq Banki",
        cardName: "Gold Humo",
        currency: "UZS",
        rating: 4.5,
        cardTag: "Humo",
        typeTag: "Debit",
        typeTagColor: AppColors.primaryBlue,
        metrics: [
          const CardMetric(
            icon: Icons.percent,
            label: 'Cashback',
            value: '2%',
            valueColor: AppColors.accentGreen,
          ),
          CardMetric(
            icon: Icons.calendar_today_outlined,
            label: 'Yillik',
            value: '50,000 so\'m',
            valueColor: AppColors.darkText,
          ),
        ],
        advantagesCount: 3,
        isPrimaryCard: false,
      ),
    ];
  }
}

