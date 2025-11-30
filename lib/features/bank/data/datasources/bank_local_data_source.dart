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
        features: [
          'bank.currency_feature_1'.tr(),
          'bank.currency_feature_2'.tr(),
          'bank.currency_feature_3'.tr(),
        ],
        color: const Color(0xFF0094FF),
        icon: Icons.attach_money,
        titleKey: 'currency',
      ),
      BankServiceModel(
        title: 'bank.micro_loan'.tr(),
        subtitle: 'bank.micro_loan_subtitle'.tr(),
        description: 'bank.micro_loan_description'.tr(),
        features: [
          'bank.micro_loan_feature_1'.tr(),
          'bank.micro_loan_feature_2'.tr(),
          'bank.micro_loan_feature_3'.tr(),
        ],
        color: const Color(0xFF10B981),
        icon: Icons.incomplete_circle,
        titleKey: 'micro_loan',
      ),
      BankServiceModel(
        title: 'bank.deposit'.tr(),
        subtitle: 'bank.deposit_subtitle'.tr(),
        description: 'bank.deposit_description'.tr(),
        features: [
          'bank.deposit_feature_1'.tr(),
          'bank.deposit_feature_2'.tr(),
          'bank.deposit_feature_3'.tr(),
        ],
        color: const Color(0xFF8B5CF6),
        icon: Icons.diamond_outlined,
        titleKey: 'deposit',
      ),
      BankServiceModel(
        title: 'bank.mortgage'.tr(),
        subtitle: 'bank.mortgage_subtitle'.tr(),
        description: 'bank.mortgage_description'.tr(),
        features: [
          'bank.mortgage_feature_1'.tr(),
          'bank.mortgage_feature_2'.tr(),
          'bank.mortgage_feature_3'.tr(),
        ],
        color: const Color(0xFFF59E0B),
        icon: Icons.home_outlined,
        titleKey: 'mortgage',
      ),
      BankServiceModel(
        title: 'bank.cards'.tr(),
        subtitle: 'bank.cards_subtitle'.tr(),
        description: 'bank.cards_description'.tr(),
        features: [
          'bank.cards_feature_1'.tr(),
          'bank.cards_feature_2'.tr(),
          'bank.cards_feature_3'.tr(),
        ],
        color: const Color(0xFFEF4444),
        icon: Icons.credit_card,
        titleKey: 'cards',
      ),
      BankServiceModel(
        title: 'bank.auto_credit'.tr(),
        subtitle: 'bank.auto_credit_subtitle'.tr(),
        description: 'bank.auto_credit_description'.tr(),
        features: [
          'bank.auto_credit_feature_1'.tr(),
          'bank.auto_credit_feature_2'.tr(),
          'bank.auto_credit_feature_3'.tr(),
        ],
        color: const Color(0xFF6366F1),
        icon: Icons.directions_car_outlined,
        titleKey: 'auto_credit',
      ),
      BankServiceModel(
        title: 'bank.transfers'.tr(),
        subtitle: 'bank.transfers_subtitle'.tr(),
        description: 'bank.transfers_description'.tr(),
        features: [
          'bank.transfers_feature_1'.tr(),
          'bank.transfers_feature_2'.tr(),
          'bank.transfers_feature_3'.tr(),
        ],
        color: const Color(0xFFEC4899),
        icon: Icons.swap_horiz,
        titleKey: 'transfers',
      ),
    ];
  }
}
