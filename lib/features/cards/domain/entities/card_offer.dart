import 'package:flutter/material.dart';

class CardMetric {
  const CardMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
}

class CardOffer {
  const CardOffer({
    required this.bankName,
    required this.cardName,
    required this.currency,
    required this.rating,
    required this.cardTag,
    required this.typeTag,
    required this.typeTagColor,
    required this.metrics,
    required this.advantagesCount,
    this.isPrimaryCard = false,
  });

  final String bankName;
  final String cardName;
  final String currency;
  final double rating;
  final String cardTag;
  final String typeTag;
  final Color typeTagColor;
  final List<CardMetric> metrics;
  final int advantagesCount;
  final bool isPrimaryCard;
}

