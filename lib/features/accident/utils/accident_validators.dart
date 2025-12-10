import 'dart:core';
import 'package:easy_localization/easy_localization.dart';

class AccidentValidators {
  /// Валидация ПИНФЛ - должен быть 14 цифр
  static String? validatePinfl(String? value) {
    if (value == null || value.isEmpty) {
      return 'insurance.accident.validators.pinfl_required'.tr();
    }
    if (value.length != 14) {
      return 'insurance.accident.validators.pinfl_length'.tr();
    }
    if (!RegExp(r'^\d{14}$').hasMatch(value)) {
      return 'insurance.accident.validators.pinfl_digits_only'.tr();
    }
    return null;
  }

  /// Валидация серии паспорта - 2 заглавные буквы
  static String? validatePassportSeries(String? value) {
    if (value == null || value.isEmpty) {
      return 'insurance.accident.validators.passport_series_required'.tr();
    }
    if (value.length != 2) {
      return 'insurance.accident.validators.passport_series_length'.tr();
    }
    if (!RegExp(r'^[A-ZА-Я]{2}$').hasMatch(value.toUpperCase())) {
      return 'insurance.accident.validators.passport_series_letters'.tr();
    }
    return null;
  }

  /// Валидация номера паспорта - 7 цифр
  static String? validatePassportNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'insurance.accident.validators.passport_number_required'.tr();
    }
    if (value.length != 7) {
      return 'insurance.accident.validators.passport_number_length'.tr();
    }
    if (!RegExp(r'^\d{7}$').hasMatch(value)) {
      return 'insurance.accident.validators.passport_number_digits_only'.tr();
    }
    return null;
  }

  /// Валидация телефона - должен начинаться с 998 и быть 12 цифр
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'insurance.accident.validators.phone_required'.tr();
    }
    // Убираем все нецифровые символы для проверки
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 12) {
      return 'insurance.accident.validators.phone_length'.tr();
    }
    if (!digitsOnly.startsWith('998')) {
      return 'insurance.accident.validators.phone_starts_with_998'.tr();
    }
    return null;
  }

  /// Валидация обязательного поля
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'insurance.accident.validators.field_required'.tr(namedArgs: {'fieldName': fieldName});
    }
    return null;
  }

  /// Валидация даты рождения
  static String? validateDateBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'insurance.accident.validators.date_birth_required'.tr();
    }
    // Проверяем формат YYYY-MM-DD
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return 'insurance.accident.validators.date_birth_format'.tr();
    }
    return null;
  }

  /// Валидация даты начала страхования
  static String? validateStartDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'insurance.accident.validators.start_date_required'.tr();
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return 'insurance.accident.validators.start_date_format'.tr();
    }
    return null;
  }
}

