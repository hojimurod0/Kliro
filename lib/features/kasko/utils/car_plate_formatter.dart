import 'package:flutter/services.dart';

/// Avtomobil raqami uchun avtomatik formatlash formatter
/// Format: A 000 AA (1 harf + 3 raqam + 2 harf)
class CarPlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Faqat harflar va raqamlarni qoldiramiz
    String text = newValue.text.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
    
    // Maksimal 6 ta belgi (1 harf + 3 raqam + 2 harf)
    if (text.length > 6) {
      text = text.substring(0, 6);
    }
    
    // Formatlash: A 000 AA
    String formatted = '';
    
    if (text.isNotEmpty) {
      // Birinchi harf
      formatted = text[0];
      
      if (text.length > 1) {
        // Bo'shliq qo'shamiz
        formatted += ' ';
        
        // Keyingi 3 ta belgi (raqamlar)
        int numStart = 1;
        int numEnd = text.length > 4 ? 4 : text.length;
        formatted += text.substring(numStart, numEnd);
        
        if (text.length > 4) {
          // Bo'shliq qo'shamiz
          formatted += ' ';
          
          // Oxirgi 2 ta harf
          int letterStart = 4;
          int letterEnd = text.length > 6 ? 6 : text.length;
          formatted += text.substring(letterStart, letterEnd);
        }
      }
    }
    
    // Cursor pozitsiyasini to'g'rilash
    int selectionIndex = formatted.length;
    
    // Eski va yangi matn uzunligini solishtiramiz
    int oldTextLength = oldValue.text.replaceAll(' ', '').length;
    int newTextLength = text.length;
    
    if (newTextLength > oldTextLength) {
      // Yangi belgi qo'shildi
      if (newTextLength <= 1) {
        selectionIndex = 1;
      } else if (newTextLength <= 4) {
        selectionIndex = newTextLength + 1; // +1 bo'shliq uchun
      } else if (newTextLength <= 6) {
        selectionIndex = newTextLength + 2; // +2 bo'shliq uchun
      } else {
        selectionIndex = formatted.length;
      }
    } else if (newTextLength < oldTextLength) {
      // Belgi o'chirildi - cursor pozitsiyasini saqlaymiz
      int cursorPos = newValue.selection.baseOffset;
      if (cursorPos > formatted.length) {
        cursorPos = formatted.length;
      }
      selectionIndex = cursorPos;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

