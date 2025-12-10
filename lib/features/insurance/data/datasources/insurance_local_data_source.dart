import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/insurance_service_model.dart';

class InsuranceLocalDataSource {
  const InsuranceLocalDataSource();

  Future<List<InsuranceServiceModel>> fetchInsuranceServices() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Asosiy ranglar
    const Color bluePrimary = Color(0xFF0090FF);
    const Color orangePrimary = Color(0xFFFF9800);
    const Color greenPrimary = Color(0xFF4CAF50);

    // Ikonka fon ranglari (pastel ranglar)
    const Color lightBlue = Color(0xFFE5F5FF); // OSAGO
    const Color lightOrange = Color(0xFFFFEBD5); // KASKO
    const Color lightGreen = Color(0xFFE8F5E9); // Sayohat

    // Helper function to safely get translations
    String safeTr(String key) {
      try {
        final result = key.tr();
        // Check if result is null or empty, return key as fallback
        if (result.isEmpty) {
          debugPrint('Translation empty for key: $key');
          return key;
        }
        return result;
      } catch (e) {
        // Fallback to key if translation fails
        debugPrint('Translation error for key $key: $e');
        return key;
      }
    }

    return [
      InsuranceServiceModel(
        id: 'osago',
        title: safeTr('insurance.osago.title'),
        subtitle: safeTr('insurance.osago.subtitle'),
        description: safeTr('insurance.osago.description'),
        features: [
          safeTr('insurance.osago.feature_1'),
          safeTr('insurance.osago.feature_2'),
          safeTr('insurance.osago.feature_3'),
        ],
        primaryColor: bluePrimary,
        lightColor: lightBlue,
        iconData: Icons.directions_car_filled,
        buttonText: safeTr('insurance.osago.button_text'),
        imagePath: 'assets/images/car.png',
      ),
      InsuranceServiceModel(
        id: 'kasko',
        title: safeTr('insurance.kasko.title'),
        subtitle: safeTr('insurance.kasko.subtitle'),
        description: safeTr('insurance.kasko.description'),
        features: [
          safeTr('insurance.kasko.feature_1'),
          safeTr('insurance.kasko.feature_2'),
          safeTr('insurance.kasko.feature_3'),
          safeTr('insurance.kasko.feature_4'),
        ],
        primaryColor: orangePrimary,
        lightColor: lightOrange,
        iconData: Icons.shield,
        buttonText: safeTr('insurance.kasko.button_text'),
        tag: safeTr('insurance.kasko.tag'),
        imagePath: 'assets/images/kasko.png',
      ),
      InsuranceServiceModel(
        id: 'travel',
        title: safeTr('travel.title'),
        subtitle: safeTr('travel.subtitle'),
        description: safeTr('travel.description'),
        features: [
          safeTr('travel.feature_1'),
          safeTr('travel.feature_2'),
          safeTr('travel.feature_3'),
        ],
        primaryColor: greenPrimary,
        lightColor: lightGreen,
        iconData: Icons.airplanemode_active,
        buttonText: safeTr('travel.button_text'),
        imagePath: 'assets/images/sugurtapilot.png',
      ),
    ];
  }
}

