import 'package:formz/formz.dart';
import '../../../../../../core/utils/date_utils.dart' as DateUtils;

/// Валидатор для серии паспорта (2 заглавные буквы)
class PassportSeriesInput extends FormzInput<String, String> {
  const PassportSeriesInput.pure() : super.pure('');
  const PassportSeriesInput.dirty([super.value = '']) : super.dirty();

  static final _passportSeriesRegex = RegExp(r'^[A-Z]{2}$');

  @override
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Серия паспорта обязательна';
    }
    if (!_passportSeriesRegex.hasMatch(value)) {
      return 'Серия паспорта должна состоять из 2 заглавных букв';
    }
    return null;
  }
}

/// Валидатор для номера паспорта (7 цифр)
class PassportNumberInput extends FormzInput<String, String> {
  const PassportNumberInput.pure() : super.pure('');
  const PassportNumberInput.dirty([super.value = '']) : super.dirty();

  static final _passportNumberRegex = RegExp(r'^\d{7}$');

  @override
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Номер паспорта обязателен';
    }
    if (!_passportNumberRegex.hasMatch(value)) {
      return 'Номер паспорта должен состоять из 7 цифр';
    }
    return null;
  }
}

/// Валидатор для ПИНФЛ (14 цифр)
class PinflInput extends FormzInput<String, String> {
  const PinflInput.pure() : super.pure('');
  const PinflInput.dirty([super.value = '']) : super.dirty();

  static final _pinflRegex = RegExp(r'^\d{14}$');

  @override
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'ПИНФЛ обязателен';
    }
    if (!_pinflRegex.hasMatch(value)) {
      return 'ПИНФЛ должен состоять из 14 цифр';
    }
    return null;
  }
}

/// Валидатор для телефона (9-15 цифр, может начинаться с +)
class PhoneInput extends FormzInput<String, String> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([super.value = '']) : super.dirty();

  static final _phoneRegex = RegExp(r'^\+?\d{9,15}$');

  @override
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Телефон обязателен';
    }
    // Убираем + для проверки длины цифр
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 9 || digitsOnly.length > 15) {
      return 'Телефон должен содержать от 9 до 15 цифр';
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Неверный формат телефона';
    }
    return null;
  }
}

/// Валидатор для даты в формате DD-MM-YYYY
class DateInput extends FormzInput<String, String> {
  const DateInput.pure() : super.pure('');
  const DateInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Дата обязательна';
    }
    if (!DateUtils.DateUtils.isValidDate(value)) {
      return 'Неверный формат даты (DD-MM-YYYY)';
    }
    if (!DateUtils.DateUtils.isDateAfterMinDate(value)) {
      return 'Дата не может быть раньше 01-01-1900';
    }
    return null;
  }
}

/// Валидатор для имени/фамилии
class NameInput extends FormzInput<String, String> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Поле обязательно';
    }
    if (value.length < 2) {
      return 'Минимум 2 символа';
    }
    return null;
  }
}
