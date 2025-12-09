import 'package:flutter/material.dart';

class InsuranceService {
  const InsuranceService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.primaryColor,
    required this.lightColor,
    required this.iconData,
    required this.buttonText,
    this.tag,
    this.imagePath,
  });

  final String id; // 'osago', 'kasko', 'travel'
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final Color primaryColor;
  final Color lightColor;
  final IconData iconData;
  final String buttonText;
  final String? tag;
  final String? imagePath; // Assets dan rasm yo'li (masalan: 'assets/images/kasko.png')
}
