/// Validation utilities for aviachiptalar module
class ValidationUtils {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email majburiy maydon';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Noto\'g\'ri email formati';
    }
    
    return null;
  }

  /// Phone number validation (Uzbekistan format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqami majburiy maydon';
    }
    
    // Remove spaces, dashes, and plus signs
    final cleaned = value.replaceAll(RegExp(r'[\s\-+]'), '');
    
    // Check if it's a valid Uzbek phone number
    // Formats: 901234567, +998901234567, 998901234567
    final phoneRegex = RegExp(r'^(998|)?[0-9]{9}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Noto\'g\'ri telefon raqami formati';
    }
    
    return null;
  }

  /// Date validation (YYYY-MM-DD format)
  static String? validateDate(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Sana majburiy maydon' : null;
    }
    
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Noto\'g\'ri sana formati (YYYY-MM-DD)';
    }
    
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      
      // Check if the parsed date matches the input (catches invalid dates like 2024-02-30)
      if (date.year != year || date.month != month || date.day != day) {
        return 'Noto\'g\'ri sana';
      }
      
      // Check if date is not in the future (for birthdate)
      if (date.isAfter(DateTime.now())) {
        return 'Sana kelajakda bo\'lishi mumkin emas';
      }
      
      // Check if date is not too old (for birthdate, e.g., more than 150 years ago)
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 365 * 150)))) {
        return 'Sana juda eski';
      }
      
      return null;
    } catch (e) {
      return 'Noto\'g\'ri sana formati';
    }
  }

  /// Document number validation
  static String? validateDocumentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hujjat raqami majburiy maydon';
    }
    
    // Document number should be at least 6 characters
    if (value.length < 6) {
      return 'Hujjat raqami kamida 6 belgidan iborat bo\'lishi kerak';
    }
    
    // Document number should contain only alphanumeric characters
    final docRegex = RegExp(r'^[A-Za-z0-9]+$');
    if (!docRegex.hasMatch(value)) {
      return 'Hujjat raqami faqat harf va raqamlardan iborat bo\'lishi kerak';
    }
    
    return null;
  }

  /// Name validation
  static String? validateName(String? value, {String fieldName = 'Ism'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName majburiy maydon';
    }
    
    if (value.length < 2) {
      return '$fieldName kamida 2 belgidan iborat bo\'lishi kerak';
    }
    
    // Name should contain only letters and spaces
    final nameRegex = RegExp(r'^[A-Za-zА-Яа-яЁё\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName faqat harflardan iborat bo\'lishi kerak';
    }
    
    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Maydon'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName majburiy maydon';
    }
    return null;
  }
}

