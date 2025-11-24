import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/bank_service_model.dart';

class BankLocalDataSource {
  const BankLocalDataSource();

  List<BankServiceModel> fetchServices() {
    return [
      BankServiceModel(
        title: 'bank.currency'.tr(),
        subtitle: 'bank.currency_subtitle'.tr(),
        description: 'bank.currency_description'.tr(),
        features: const [
          'Real-time kurslar',
          'Tezkor konvertatsiya',
          'Barcha valyutalar',
        ],
        color: const Color(0xFF0094FF),
        icon: Icons.attach_money,
        titleKey: 'currency',
      ),
      BankServiceModel(
        title: 'bank.micro_loan'.tr(),
        subtitle: 'bank.micro_loan_subtitle'.tr(),
        description: 'bank.micro_loan_description'.tr(),
        features: const [
          'Tezkor rasmiylashtirish',
          'Minimal hujjatlar',
          'Onlayn monitoring',
        ],
        color: const Color(0xFF10B981),
        icon: Icons.incomplete_circle,
        titleKey: 'micro_loan',
      ),
      BankServiceModel(
        title: 'bank.deposit'.tr(),
        subtitle: 'bank.deposit_subtitle'.tr(),
        description: 'bank.deposit_description'.tr(),
        features: const [
          'Yuqori foiz',
          'Turli muddatlar',
          'Ishonchli banklar',
        ],
        color: const Color(0xFF8B5CF6),
        icon: Icons.diamond_outlined,
        titleKey: 'deposit',
      ),
      BankServiceModel(
        title: 'bank.mortgage'.tr(),
        subtitle: 'bank.mortgage_subtitle'.tr(),
        description: 'bank.mortgage_description'.tr(),
        features: const [
          'Uzoq muddat',
          'Qulay to\'lov',
          'Konsultatsiya',
        ],
        color: const Color(0xFFF59E0B),
        icon: Icons.home_outlined,
        titleKey: 'mortgage',
      ),
      BankServiceModel(
        title: 'bank.cards'.tr(),
        subtitle: 'bank.cards_subtitle'.tr(),
        description: 'bank.cards_description'.tr(),
        features: const [
          'Bepul yetkazish',
          'Tezkor rasmiylashtirish',
          'Cashback',
        ],
        color: const Color(0xFFEF4444),
        icon: Icons.credit_card,
        titleKey: 'cards',
      ),
      BankServiceModel(
        title: 'bank.auto_credit'.tr(),
        subtitle: 'bank.auto_credit_subtitle'.tr(),
        description: 'bank.auto_credit_description'.tr(),
        features: const [
          'Boshlang\'ich to\'lov 15%',
          'Tezkor tasdiq',
          '5 yilgacha muddat',
        ],
        color: const Color(0xFF6366F1),
        icon: Icons.directions_car_outlined,
        titleKey: 'auto_credit',
      ),
      BankServiceModel(
        title: 'bank.transfers'.tr(),
        subtitle: 'bank.transfers_subtitle'.tr(),
        description: 'bank.transfers_description'.tr(),
        features: const [
          'Bir daqiqada',
          'Barcha banklar',
          'Minimal komissiya',
        ],
        color: const Color(0xFFEC4899),
        icon: Icons.swap_horiz,
        titleKey: 'transfers',
      ),
    ];
  }
}
