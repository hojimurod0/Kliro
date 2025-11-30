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

  factory BankServiceModel.fromJson(Map<String, dynamic> json) {
    // Получаем titleKey из JSON или определяем по title
    final titleKey =
        json['title_key'] ??
        json['key'] ??
        _getTitleKeyFromTitle(json['title'] ?? '');

    // Парсим features из API - может быть как 'features', так и 'advantages'
    // Если features пустые, репозиторий дополнит их из локальных данных с переводами
    final featuresData = json['features'] ?? json['advantages'] ?? [];
    final List<String> features = _parseFeaturesList(featuresData);

    // Получаем цвет и иконку по titleKey
    final color = _getColorByTitleKey(titleKey);
    final icon = _getIconByTitleKey(titleKey);

    return BankServiceModel(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      features:
          features, // Могут быть пустыми - репозиторий дополнит из локальных данных
      color: color,
      icon: icon,
      titleKey: titleKey,
    );
  }

  static List<String> _parseFeaturesList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) {
      // Если это строка, попробуем разделить по запятой или новой строке
      return value
          .split(RegExp(r'[,;\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static String _getTitleKeyFromTitle(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('valyuta') || titleLower.contains('currency'))
      return 'currency';
    if (titleLower.contains('mikro') || titleLower.contains('micro'))
      return 'micro_loan';
    if (titleLower.contains('omonat') || titleLower.contains('deposit'))
      return 'deposit';
    if (titleLower.contains('ipoteka') || titleLower.contains('mortgage'))
      return 'mortgage';
    if (titleLower.contains('karta') || titleLower.contains('card'))
      return 'cards';
    if (titleLower.contains('avto') || titleLower.contains('auto'))
      return 'auto_credit';
    if (titleLower.contains('otkazma') || titleLower.contains('transfer'))
      return 'transfers';
    return 'currency'; // default
  }

  static Color _getColorByTitleKey(String titleKey) {
    switch (titleKey) {
      case 'currency':
        return const Color(0xFF0094FF);
      case 'micro_loan':
        return const Color(0xFF10B981);
      case 'deposit':
        return const Color(0xFF8B5CF6);
      case 'mortgage':
        return const Color(0xFFF59E0B);
      case 'cards':
        return const Color(0xFFEF4444);
      case 'auto_credit':
        return const Color(0xFF6366F1);
      case 'transfers':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF0094FF);
    }
  }

  static IconData _getIconByTitleKey(String titleKey) {
    switch (titleKey) {
      case 'currency':
        return Icons.attach_money;
      case 'micro_loan':
        return Icons.incomplete_circle;
      case 'deposit':
        return Icons.diamond_outlined;
      case 'mortgage':
        return Icons.home_outlined;
      case 'cards':
        return Icons.credit_card;
      case 'auto_credit':
        return Icons.directions_car_outlined;
      case 'transfers':
        return Icons.swap_horiz;
      default:
        return Icons.attach_money;
    }
  }
}
