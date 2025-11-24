import 'package:flutter/material.dart';

class BankService {
  const BankService({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.color,
    required this.icon,
    required this.titleKey,
  });

  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final Color color;
  final IconData icon;
  final String titleKey;
}
