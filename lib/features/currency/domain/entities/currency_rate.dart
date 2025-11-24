import 'package:flutter/material.dart';

class CurrencyRate {
  const CurrencyRate({
    required this.bankName,
    required this.location,
    required this.rating,
    required this.schedule,
    required this.isOnline,
    required this.buyRate,
    required this.sellRate,
    required this.icon,
    required this.iconBackground,
  });

  final String bankName;
  final String location;
  final double rating;
  final String schedule;
  final bool isOnline;
  final double buyRate;
  final double sellRate;
  final IconData icon;
  final Color iconBackground;
}
