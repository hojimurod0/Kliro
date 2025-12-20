import 'package:flutter/services.dart';

/// Passport formatter: AA1234567 -> AA 1234567
class PassportFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase().replaceAll(' ', '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Extract letters and numbers
    final letters = text.replaceAll(RegExp(r'[^A-Z]'), '');
    final numbers = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Format: AA 1234567 (2 letters, space, 7 numbers)
    String formatted = '';
    
    if (letters.isNotEmpty) {
      formatted = letters.substring(0, letters.length > 2 ? 2 : letters.length);
    }
    
    if (numbers.isNotEmpty && letters.length >= 2) {
      formatted += ' ${numbers.substring(0, numbers.length > 7 ? 7 : numbers.length)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Phone formatter: 998991234567 -> +998 99 123-45-67
/// Limits to 12 digits (998 + 9 digits) to prevent extra digits
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Limit to 12 digits maximum (998 + 9 digits)
    final limitedText = text.length > 12 ? text.substring(0, 12) : text;
    
    String formatted = '+';
    
    // Add country code (998)
    if (limitedText.isNotEmpty) {
      final countryCode = limitedText.substring(0, limitedText.length > 3 ? 3 : limitedText.length);
      formatted += countryCode;
    }
    
    // Add operator code (99)
    if (limitedText.length > 3) {
      formatted += ' ${limitedText.substring(3, limitedText.length > 5 ? 5 : limitedText.length)}';
    }
    
    // Add first part (123)
    if (limitedText.length > 5) {
      formatted += ' ${limitedText.substring(5, limitedText.length > 8 ? 8 : limitedText.length)}';
    }
    
    // Add second part (45)
    if (limitedText.length > 8) {
      formatted += '-${limitedText.substring(8, limitedText.length > 10 ? 10 : limitedText.length)}';
    }
    
    // Add third part (67)
    if (limitedText.length > 10) {
      formatted += '-${limitedText.substring(10, limitedText.length > 12 ? 12 : limitedText.length)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Date formatter: 16122000 -> 16/12/2000
class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = '';
    
    // Add day (16)
    if (text.isNotEmpty) {
      formatted = text.substring(0, text.length > 2 ? 2 : text.length);
    }
    
    // Add month (12)
    if (text.length > 2) {
      formatted += '/${text.substring(2, text.length > 4 ? 4 : text.length)}';
    }
    
    // Add year (2000)
    if (text.length > 4) {
      formatted += '/${text.substring(4, text.length > 8 ? 8 : text.length)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
