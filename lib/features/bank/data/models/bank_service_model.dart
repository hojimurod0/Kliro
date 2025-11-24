import 'package:flutter/material.dart';

import '../../domain/entities/bank_service.dart';

class BankServiceModel extends BankService {
  const BankServiceModel({
    required super.title,
    required super.subtitle,
    required super.description,
    required super.features,
    required super.color,
    required super.icon,
    required super.titleKey,
  });

  factory BankServiceModel.fromData({
    required String title,
    required String subtitle,
    required String description,
    required List<String> features,
    required Color color,
    required IconData icon,
    required String titleKey,
  }) {
    return BankServiceModel(
      title: title,
      subtitle: subtitle,
      description: description,
      features: features,
      color: color,
      icon: icon,
      titleKey: titleKey,
    );
  }
}
