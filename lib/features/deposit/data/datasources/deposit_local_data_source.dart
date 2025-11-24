import 'package:flutter/material.dart';

import '../models/deposit_offer_model.dart';

class DepositLocalDataSource {
  const DepositLocalDataSource();

  List<DepositOfferModel> fetchOffers() {
    return const [
      DepositOfferModel(
        bankName: 'Ipak Yuli Bank',
        currency: 'UZS',
        rating: 4.7,
        interestRate: '24%',
        term: '12 oygacha',
        amount: '30 mln so\'m',
        logoColor: Color(0xFFF0F9FF),
        logoIcon: Icons.apartment_rounded,
      ),
      DepositOfferModel(
        bankName: 'Kapitalbank',
        currency: 'USD',
        rating: 4.9,
        interestRate: '6%',
        term: '24 oygacha',
        amount: '10 ming USD',
        logoColor: Color(0xFFEFF6FF),
        logoIcon: Icons.account_balance,
      ),
      DepositOfferModel(
        bankName: 'Asaka bank',
        currency: 'UZS',
        rating: 4.5,
        interestRate: '22%',
        term: '18 oygacha',
        amount: '25 mln so\'m',
        logoColor: Color(0xFFF4F3FF),
        logoIcon: Icons.domain,
      ),
      DepositOfferModel(
        bankName: 'Hamkorbank',
        currency: 'USD',
        rating: 4.6,
        interestRate: '5.5%',
        term: '36 oygacha',
        amount: '15 ming USD',
        logoColor: Color(0xFFFFFBEB),
        logoIcon: Icons.monetization_on_outlined,
      ),
      DepositOfferModel(
        bankName: 'Agrobank',
        currency: 'UZS',
        rating: 4.3,
        interestRate: '21%',
        term: '9 oygacha',
        amount: '20 mln so\'m',
        logoColor: Color(0xFFEFFDF3),
        logoIcon: Icons.agriculture,
      ),
    ];
  }
}
