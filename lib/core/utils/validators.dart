import 'package:easy_localization/easy_localization.dart';

/// Validation funksiyalari
class KaskoValidators {
  /// Passport seriyasi va raqamini tekshirish
  static String? validatePassport({
    String? series,
    String? number,
  }) {
    if (series == null || series.trim().isEmpty) {
      return 'insurance.kasko.personal_data.errors.enter_passport_series'.tr();
    }
    if (series.length != 2 || !RegExp(r'^[A-Za-z]{2}$').hasMatch(series.trim())) {
      return 'insurance.kasko.personal_data.errors.series_2_letters'.tr();
    }
    if (number == null || number.trim().isEmpty) {
      return 'insurance.kasko.personal_data.errors.enter_passport_number'.tr();
    }
    if (number.length != 7 || !RegExp(r'^[0-9]{7}$').hasMatch(number.trim())) {
      return 'insurance.kasko.personal_data.errors.number_7_digits'.tr();
    }
    return null;
  }

  /// Avtomobil raqamini tekshirish
  /// Format: Region (2 raqam) + Raqam (1 harf + 3 raqam + 2 harf)
  /// Example: "01A000AA" yoki "01 A 000 AA"
  static String? validateCarNumber({
    String? region,
    String? number,
  }) {
    if (region == null || region.trim().isEmpty) {
      return 'insurance.kasko.document_data.errors.enter_region'.tr();
    }
    // Viloyat kodi 2 ta raqamdan iborat bo'lishi kerak
    if (!RegExp(r'^[0-9]{2}$').hasMatch(region.trim())) {
      return 'insurance.kasko.document_data.errors.region_2_digits'.tr();
    }
    
    if (number == null || number.trim().isEmpty) {
      return 'insurance.kasko.document_data.errors.enter_car_number'.tr();
    }
    
    // Bo'shliqlarni olib tashlash va katta harflarga o'tkazish
    final cleanNumber = number.trim().replaceAll(' ', '').toUpperCase();
    
    // Format: 1 harf + 3 raqam + 2 harf (jami 6 belgi)
    if (cleanNumber.length < 6) {
      return 'insurance.kasko.document_data.errors.invalid_car_number'.tr();
    }
    
    // Format tekshiruvi: A000AA (1 harf + 3 raqam + 2 harf)
    if (!RegExp(r'^[A-Z][0-9]{3}[A-Z]{2}$').hasMatch(cleanNumber)) {
      return 'insurance.kasko.document_data.errors.invalid_car_number_format'.tr();
    }
    
    return null;
  }

  /// Tex passport seriyasi va raqamini tekshirish
  static String? validateTechPassport({
    String? series,
    String? number,
  }) {
    if (series == null || series.trim().isEmpty) {
      return 'insurance.kasko.document_data.errors.enter_tech_passport_series'.tr();
    }
    if (series.length != 3 || !RegExp(r'^[A-Za-z]{3}$').hasMatch(series.trim())) {
      return 'insurance.kasko.document_data.errors.series_3_letters'.tr();
    }
    if (number == null || number.trim().isEmpty) {
      return 'insurance.kasko.document_data.errors.enter_tech_passport_number'.tr();
    }
    if (number.length != 7 || !RegExp(r'^[0-9]{7}$').hasMatch(number.trim())) {
      return 'insurance.kasko.document_data.errors.number_7_digits'.tr();
    }
    return null;
  }
}

