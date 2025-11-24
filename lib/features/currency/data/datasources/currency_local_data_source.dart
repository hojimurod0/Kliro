import 'package:flutter/material.dart';

import '../models/currency_rate_model.dart';

class CurrencyLocalDataSource {
  const CurrencyLocalDataSource();

  List<CurrencyRateModel> fetchRates() {
    return const [
      CurrencyRateModel(
        bankName: 'Ipak Yuli Bank',
        location: 'Toshkent shahar',
        rating: 4.8,
        schedule: '9:00 - 17:00',
        isOnline: true,
        buyRate: 12430,
        sellRate: 12530,
        icon: Icons.apartment_rounded,
        iconBackground: Color(0xFFE0F2FE),
      ),
      CurrencyRateModel(
        bankName: 'Hamkorbank',
        location: 'Namangan vil.',
        rating: 4.6,
        schedule: '8:30 - 18:00',
        isOnline: false,
        buyRate: 12410,
        sellRate: 12510,
        icon: Icons.account_balance,
        iconBackground: Color(0xFFFCE7F3),
      ),
      CurrencyRateModel(
        bankName: 'Kapitalbank',
        location: 'Samarqand sh.',
        rating: 4.9,
        schedule: '9:00 - 18:30',
        isOnline: true,
        buyRate: 12450,
        sellRate: 12540,
        icon: Icons.savings_outlined,
        iconBackground: Color(0xFFEFF6FF),
      ),
      CurrencyRateModel(
        bankName: 'Asaka bank',
        location: 'Andijon sh.',
        rating: 4.5,
        schedule: '8:00 - 17:30',
        isOnline: true,
        buyRate: 12390,
        sellRate: 12480,
        icon: Icons.domain,
        iconBackground: Color(0xFFEFFDF3),
      ),
      CurrencyRateModel(
        bankName: 'Microkreditbank',
        location: 'Buxoro vil.',
        rating: 4.3,
        schedule: '9:00 - 16:00',
        isOnline: false,
        buyRate: 12420,
        sellRate: 12500,
        icon: Icons.apartment,
        iconBackground: Color(0xFFFFF7ED),
      ),
    ];
  }
}
