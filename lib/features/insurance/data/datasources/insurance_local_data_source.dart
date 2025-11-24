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

    return [
      InsuranceServiceModel(
        title: "OSAGO",
        subtitle: "Majburiy sug'urta",
        description:
            "Yo'l harakati ishtirokchilarining fuqarolik javobgarligini sug'urtalash",
        features: const [
          "Majburiy",
          "Onlayn rasmiylashtirish",
          "Tez ko'rib chiqish",
        ],
        primaryColor: bluePrimary,
        lightColor: lightBlue,
        iconData: Icons.directions_car_filled,
        buttonText: "Rasmiylashtirish",
      ),
      InsuranceServiceModel(
        title: "KASKO",
        subtitle: "To'liq himoya",
        description: "Transport vositasini barcha xavflardan to'liq himoyalash",
        features: const [
          "To'liq himoya",
          "O'g'irlilikdan",
          "Tabiiy ofatlardan",
          "Baxtsiz hodisalardan",
        ],
        primaryColor: orangePrimary,
        lightColor: lightOrange,
        iconData: Icons.shield,
        buttonText: "Rasmiylashtirish",
        tag: "Ommabop",
      ),
      InsuranceServiceModel(
        title: "Sayohat sug'urtasi",
        subtitle: "Xavfsiz sayohat",
        description:
            "Xorijda bo'lish davomida tibbiy yordam va boshqa xavflardan himoya",
        features: const [
          "Tibbiy yordam",
          "Bagaj yo'qolishi",
          "Parvoz bekor qilish",
        ],
        primaryColor: greenPrimary,
        lightColor: lightGreen,
        iconData: Icons.airplanemode_active,
        buttonText: "Rasmiylashtirish",
      ),
    ];
  }
}

