import 'package:intl/intl.dart';

/// Утилиты для работы с датами в формате DD-MM-YYYY
class DateUtils {
  DateUtils._();

  /// Формат даты DD-MM-YYYY
  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  /// Парсинг строки в формате DD-MM-YYYY в DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Форматирование DateTime в строку DD-MM-YYYY
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Проверка валидности даты в формате DD-MM-YYYY
  static bool isValidDate(String dateString) {
    return parseDate(dateString) != null;
  }

  /// Проверка, что дата не раньше минимальной даты (01-01-1900)
  static bool isDateAfterMinDate(String dateString) {
    final date = parseDate(dateString);
    if (date == null) return false;
    final minDate = DateTime(1900, 1, 1);
    return date.isAfter(minDate) || date.isAtSameMomentAs(minDate);
  }

  /// Проверка, что startDate <= endDate
  static bool isStartDateBeforeEndDate(String startDate, String endDate) {
    final start = parseDate(startDate);
    final end = parseDate(endDate);
    if (start == null || end == null) return false;
    return start.isBefore(end) || start.isAtSameMomentAs(end);
  }

  /// Вычисление возраста по дате рождения
  static int? calculateAge(String birthDate) {
    final birth = parseDate(birthDate);
    if (birth == null) return null;
    
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month || 
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }
}

