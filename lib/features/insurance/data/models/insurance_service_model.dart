import 'package:flutter/material.dart';

import '../../domain/entities/insurance_service.dart';

class InsuranceServiceModel extends InsuranceService {
  const InsuranceServiceModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.features,
    required super.primaryColor,
    required super.lightColor,
    required super.iconData,
    required super.buttonText,
    super.tag,
  });

  factory InsuranceServiceModel.fromData({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required List<String> features,
    required Color primaryColor,
    required Color lightColor,
    required IconData iconData,
    required String buttonText,
    String? tag,
  }) {
    return InsuranceServiceModel(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      features: features,
      primaryColor: primaryColor,
      lightColor: lightColor,
      iconData: iconData,
      buttonText: buttonText,
      tag: tag,
    );
  }
}

