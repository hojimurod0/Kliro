/// OSAGO yordamchi funksiyalar
class OsagoUtils {
  /// Telefon raqamini normalizatsiya qilish
  /// Input: "90 123 45 67" yoki "901234567"
  /// Output: "998901234567"
  static String normalizePhoneNumber(String phone) {
    // Barcha bo'sh joylar va belgilarni olib tashlash
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Agar 9 ta raqam bo'lsa, 998 qo'shamiz
    if (digitsOnly.length == 9) {
      return '998$digitsOnly';
    }
    
    // Agar 12 ta raqam bo'lsa (998 bilan), qaytaramiz
    if (digitsOnly.length == 12 && digitsOnly.startsWith('998')) {
      return digitsOnly;
    }
    
    // Boshqa holatlar uchun faqat raqamlarni qaytaramiz
    return digitsOnly;
  }

  /// GosNumber ni normalizatsiya qilish
  /// Input: "01 A 000 AA" yoki "01A000AA"
  /// Output: "01A000AA"
  static String normalizeGosNumber(String region, String number) {
    final cleanNumber = number.replaceAll(' ', '').toUpperCase();
    return '$region$cleanNumber';
  }

  /// Passport seriyasini normalizatsiya qilish
  /// Input: "aa" yoki "AA"
  /// Output: "AA"
  static String normalizePassportSeria(String seria) {
    return seria.trim().toUpperCase();
  }

  /// Passport raqamini normalizatsiya qilish
  /// Input: "1234567" yoki " 1234567 "
  /// Output: "1234567"
  static String normalizePassportNumber(String number) {
    return number.trim();
  }

  /// Tex passport seriyasini normalizatsiya qilish
  /// Input: "aaa" yoki "AAA"
  /// Output: "AAA"
  static String normalizeTechPassportSeria(String seria) {
    return seria.trim().toUpperCase();
  }

  /// Sana formatini API uchun tayyorlash (yyyy-MM-dd)
  /// Input: DateTime
  /// Output: "1990-01-01"
  static String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Sana formatini ko'rsatish uchun (dd.MM.yyyy)
  /// Input: DateTime
  /// Output: "01.01.1990"
  static String formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Period mapping: локализованные строки -> ID
  /// Поддерживает: uz, ru, en, uz-cyr
  /// "6 oy" / "6 месяцев" / "6 months" / "6 ой" -> "6"
  /// "12 oy" / "12 месяцев" / "12 months" / "12 ой" -> "12"
  static String? mapPeriodToId(String? period) {
    if (period == null || period.isEmpty) return null;
    
    final periodLower = period.toLowerCase().trim();
    
    // 6 месяцев варианты
    if (periodLower.contains('6') && 
        (periodLower.contains('oy') || 
         periodLower.contains('месяц') || 
         periodLower.contains('month') ||
         periodLower.contains('ой'))) {
      return '6';
    }
    
    // 12 месяцев варианты
    if (periodLower.contains('12') && 
        (periodLower.contains('oy') || 
         periodLower.contains('месяц') || 
         periodLower.contains('month') ||
         periodLower.contains('ой'))) {
      return '12';
    }
    
    // Fallback: точное совпадение для обратной совместимости
    final periodMap = {
      '6 oy': '6',
      '12 oy': '12',
      '6 месяцев': '6',
      '12 месяцев': '12',
      '6 months': '6',
      '12 months': '12',
      '6 ой': '6',
      '12 ой': '12',
    };
    
    return periodMap[period] ?? periodMap[periodLower];
  }

  /// Period ID dan period nomiga: "6" -> "6 oy", "12" -> "12 oy"
  static String? mapIdToPeriod(String? periodId) {
    if (periodId == null || periodId.isEmpty) return null;
    
    final idMap = {
      '6': '6 oy',
      '12': '12 oy',
    };
    
    return idMap[periodId];
  }

  /// Number drivers ID mapping: OSAGO type va provider ga qarab '0' (unlimited) yoki '5' (limited)
  /// API faqat 0 yoki 5 qabul qiladi
  /// Input: "Cheklanmagan" -> "0", boshqa hollar -> "5"
  static String mapNumberDriversId(String? osagoType, {String? provider}) {
    // Provider ga qarab mapping (ustunlik)
    if (provider != null && provider.isNotEmpty) {
      final providerLower = provider.toLowerCase();
      // NEO -> cheklanmagan (0) - nechta bo'lsa, hammasini qo'shadi
      if (providerLower == 'neo') {
        return '0';
      }
      // GUSTO -> cheklangan (5) - 5 tagacha
      if (providerLower == 'gusto') {
        return '5';
      }
      // GROSS -> default (5)
      if (providerLower == 'gross') {
        return '5';
      }
    }
    
    // OSAGO type ga qarab mapping
    if (osagoType == null || osagoType.isEmpty) {
      return '5'; // Default: limited to 5 drivers
    }
    
    // "Cheklanmagan" -> unlimited (0)
    if (osagoType.toLowerCase().contains('cheklanmagan') || 
        osagoType.toLowerCase().contains('unlimited')) {
      return '0';
    }
    
    // Boshqa hollar: "VIP", "Oddiy" -> limited (5)
    return '5';
  }

  /// Number drivers ID ni validate qilish: faqat '0' yoki '5' bo'lishi kerak
  static String? validateNumberDriversId(String? numberDriversId) {
    if (numberDriversId == null || numberDriversId.isEmpty) {
      return null;
    }
    
    // Faqat '0' yoki '5' qabul qilinadi
    if (numberDriversId == '0' || numberDriversId == '5') {
      return numberDriversId;
    }
    
    // Noto'g'ri qiymat bo'lsa, null qaytar (fallback kerak)
    return null;
  }

  /// GosNumber formatini tekshirish
  /// Format: Region (2 raqam) + Raqam (1 harf + 3 raqam + 2 harf)
  /// Example: "01A000AA"
  static bool isValidGosNumber(String gosNumber) {
    if (gosNumber.length < 8) return false;
    
    final pattern = RegExp(r'^\d{2}[A-Z]\d{3}[A-Z]{2}$');
    return pattern.hasMatch(gosNumber);
  }

  /// Passport seriyasini tekshirish (2 ta harf, A-Z)
  static bool isValidPassportSeria(String seria) {
    final pattern = RegExp(r'^[A-Z]{2}$');
    return pattern.hasMatch(seria.toUpperCase());
  }

  /// Passport raqamini tekshirish (7 ta raqam)
  static bool isValidPassportNumber(String number) {
    final pattern = RegExp(r'^\d{7}$');
    return pattern.hasMatch(number);
  }

  /// Tex passport seriyasini tekshirish (3 ta harf, A-Z)
  static bool isValidTechPassportSeria(String seria) {
    final pattern = RegExp(r'^[A-Z]{3}$');
    return pattern.hasMatch(seria.toUpperCase());
  }

  /// Tex passport raqamini tekshirish (7 ta raqam)
  static bool isValidTechPassportNumber(String number) {
    final pattern = RegExp(r'^\d{7}$');
    return pattern.hasMatch(number);
  }

  /// Telefon raqamini tekshirish (9 ta raqam)
  static bool isValidPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    // 9 ta raqam yoki 12 ta raqam (998 bilan)
    return digitsOnly.length == 9 || (digitsOnly.length == 12 && digitsOnly.startsWith('998'));
  }

  /// API xatoliklarini boshqarish
  static String handleApiError(Object error) {
    if (error.toString().contains('network') || error.toString().contains('connection')) {
      return 'Internet aloqasi yo\'q. Iltimos, qayta urinib ko\'ring.';
    }
    if (error.toString().contains('timeout')) {
      return 'So\'rov vaqti tugadi. Iltimos, qayta urinib ko\'ring.';
    }
    if (error.toString().contains('401') || error.toString().contains('unauthorized')) {
      return 'Autentifikatsiya xatosi. Iltimos, qayta kirib ko\'ring.';
    }
    if (error.toString().contains('404')) {
      return 'Ma\'lumot topilmadi.';
    }
    if (error.toString().contains('500') || error.toString().contains('server')) {
      return 'Server xatosi. Iltimos, keyinroq urinib ko\'ring.';
    }
    return 'Xatolik yuz berdi: ${error.toString()}';
  }

  /// PINFL dan tug'ilgan sanani olish
  /// PINFL format: YYMMDDXXXXXX (14 raqam)
  /// Birinchi 6 ta raqam: YYMMDD (yil, oy, kun)
  /// Yil: O'zbekistonda PINFL da yil 1900-2099 orasida bo'lishi mumkin
  /// Agar YY + 2000 > hozirgi yil bo'lsa, 1900 + YY, aks holda 2000 + YY
  static DateTime? parseBirthDateFromPinfl(String? pinfl) {
    if (pinfl == null || pinfl.isEmpty) return null;
    
    // Faqat raqamlarni olish
    final digitsOnly = pinfl.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 6) return null;
    
    try {
      // Birinchi 6 ta raqamni olish
      final yearStr = digitsOnly.substring(0, 2);
      final monthStr = digitsOnly.substring(2, 4);
      final dayStr = digitsOnly.substring(4, 6);
      
      final year = int.parse(yearStr);
      final month = int.parse(monthStr);
      final day = int.parse(dayStr);
      
      // Sana validatsiyasi
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 31) return null;
      
      // Yilni aniqlash: O'zbekistonda PINFL formatida
      // Agar YY < 50 bo'lsa, 2000 + YY (masalan: 33 -> 2033, lekin bu kelajak, shuning uchun 1933)
      // Agar YY >= 50 bo'lsa, 1900 + YY (masalan: 95 -> 1995)
      // Lekin agar 2000 + YY > hozirgi yil bo'lsa, 1900 + YY
      final currentYear = DateTime.now().year;
      int fullYear;
      
      if (year >= 50) {
        // 50-99 -> 1900-1949
        fullYear = 1900 + year;
      } else {
        // 0-49 -> 2000-2049 yoki 1900-1949
        final year2000 = 2000 + year;
        // Agar kelajak bo'lsa (hozirgi yildan katta), 1900 + YY
        fullYear = year2000 > currentYear ? 1900 + year : year2000;
      }
      
      // Qo'shimcha validatsiya: yil 1900-2099 orasida bo'lishi kerak
      if (fullYear < 1900 || fullYear > 2099) return null;
      
      // Yilni tekshirish: agar 1900 yildan oldin yoki kelajakda (hozirgi yildan 10 yil keyin) bo'lsa, noto'g'ri
      if (fullYear < 1900 || fullYear > currentYear + 10) return null;
      
      return DateTime(fullYear, month, day);
    } catch (e) {
      return null;
    }
  }
}

/// Mashina brendlari va modellari
class VehicleBrands {
  static const Map<String, List<String>> brandsAndModels = {
    'Toyota': [
      'Camry',
      'Corolla',
      'RAV4',
      'Land Cruiser',
      'Highlander',
      'Prius',
      'Avalon',
    ],
    'Chevrolet': [
      'Gentra',
      'Cobalt',
      'Malibu',
      'Cruze',
      'Equinox',
      'Tahoe',
      'Traverse',
      'Silverado',
    ],
    'Hyundai': [
      'Elantra',
      'Sonata',
      'Tucson',
      'Santa Fe',
      'Palisade',
      'Accent',
    ],
    'Kia': [
      'Optima',
      'Rio',
      'Sportage',
      'Sorento',
      'Telluride',
      'Cerato',
    ],
    'Nissan': [
      'Altima',
      'Sentra',
      'Rogue',
      'Pathfinder',
      'Armada',
      'Maxima',
    ],
    'Ford': [
      'Focus',
      'Fusion',
      'Escape',
      'Explorer',
      'F-150',
      'Mustang',
    ],
    'Mercedes-Benz': [
      'C-Class',
      'E-Class',
      'S-Class',
      'GLE',
      'GLC',
      'A-Class',
    ],
    'BMW': [
      '3 Series',
      '5 Series',
      '7 Series',
      'X3',
      'X5',
      'X7',
    ],
    'Audi': [
      'A4',
      'A6',
      'A8',
      'Q5',
      'Q7',
      'Q3',
    ],
    'Volkswagen': [
      'Jetta',
      'Passat',
      'Tiguan',
      'Atlas',
      'Golf',
      'Polo',
    ],
    'Lexus': [
      'ES',
      'RX',
      'GX',
      'LX',
      'IS',
      'NX',
    ],
    'Mazda': [
      'Mazda3',
      'Mazda6',
      'CX-5',
      'CX-9',
      'CX-30',
    ],
    'Honda': [
      'Accord',
      'Civic',
      'CR-V',
      'Pilot',
      'Odyssey',
    ],
  };

  static List<String> get brands => brandsAndModels.keys.toList();

  static List<String>? getModelsForBrand(String brand) {
    return brandsAndModels[brand];
  }
}

