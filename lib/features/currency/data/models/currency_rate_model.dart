import 'package:flutter/material.dart';

import '../../domain/entities/currency_rate.dart';

class CurrencyRateModel extends CurrencyRate {
  const CurrencyRateModel({
    required super.bankName,
    required super.location,
    required super.rating,
    required super.schedule,
    required super.isOnline,
    required super.buyRate,
    required super.sellRate,
    required super.icon,
    required super.iconBackground,
  });

  factory CurrencyRateModel.fromData({
    required String bankName,
    required String location,
    required double rating,
    required String schedule,
    required bool isOnline,
    required double buyRate,
    required double sellRate,
    required IconData icon,
    required Color iconBackground,
  }) {
    return CurrencyRateModel(
      bankName: bankName,
      location: location,
      rating: rating,
      schedule: schedule,
      isOnline: isOnline,
      buyRate: buyRate,
      sellRate: sellRate,
      icon: icon,
      iconBackground: iconBackground,
    );
  }
}
