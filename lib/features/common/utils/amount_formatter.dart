import 'package:easy_localization/easy_localization.dart';

String formatCompactAmount(String raw) {
  if (raw.isEmpty) return raw;
  
  // Проверяем, было ли в исходной строке слово "миллион" или "million" (включая все варианты)
  final hadMillion = RegExp(r'миллион|million|milion|миллиона|миллионов|миллионда|миллиондан', caseSensitive: false).hasMatch(raw);
  
  // Простая и надежная замена: заменяем все вхождения "миллион" и его склонения на "млн"
  String normalized = raw
      .replaceAll(RegExp(r'миллион[а-я]*', caseSensitive: false), 'mln')
      .replaceAll(RegExp(r'million\s*', caseSensitive: false), 'mln')
      .replaceAll(RegExp(r'milion\s*', caseSensitive: false), 'mln')
      .replaceAll(RegExp(r'миллиард[а-я]*', caseSensitive: false), 'млрд')
      .replaceAll(RegExp(r'billion\s*', caseSensitive: false), 'млрд')
      .replaceAll(RegExp(r'тысяча[а-я]*', caseSensitive: false), 'тыс')
      .replaceAll(RegExp(r'thousand\s*', caseSensitive: false), 'тыс');
  
  // Убираем валюту (сум, so'm, сўм, UZS и т.д.) из строки
  normalized = normalized
      .replaceAll(RegExp(r'\s*сум\s*', caseSensitive: false), '')
      .replaceAll(RegExp('\\s*so\\s*\'?\\s*m\\s*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*сўм\s*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*uzs\s*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*u\.?z\.?s\.?\s*', caseSensitive: false), '')
      .trim();
  
  // Если в исходной строке было "миллион", ВСЕГДА возвращаем нормализованную версию без дальнейшего форматирования
  if (hadMillion) {
    return normalized;
  }
  
  // Если строка уже содержит сокращения (млн, млрд, тыс), просто возвращаем нормализованную версию
  if (RegExp(r'(млн|mln|млрд|mlrd|тыс)', caseSensitive: false).hasMatch(normalized)) {
    return normalized;
  }
  
  // Если нет сокращений, используем стандартное форматирование
  final match = RegExp(r'[0-9][0-9\s.,]*').firstMatch(normalized);
  if (match == null) return normalized;

  final numericPart = match.group(0)!;
  final digitsOnly = numericPart.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) return normalized;

  final amount = double.tryParse(digitsOnly);
  if (amount == null) return normalized;

  final suffix = normalized.substring(match.end).trim();
  final formatted = _formatNumberWithUnit(amount);
  return suffix.isEmpty ? formatted : '$formatted $suffix';
}

String _formatNumberWithUnit(double amount) {
  if (amount >= 1000000000) {
    return '${_trimTrailingZeros(amount / 1000000000)} ${tr('common.billion')}';
  }
  if (amount >= 1000000) {
    return '${_trimTrailingZeros(amount / 1000000)} ${tr('common.million')}';
  }
  if (amount >= 1000) {
    return '${_trimTrailingZeros(amount / 1000)} ${tr('common.thousand')}';
  }
  return _trimTrailingZeros(amount);
}

String _trimTrailingZeros(double value) {
  final needsDecimal = value % 1 != 0;
  final formatted =
      needsDecimal ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
  return formatted.replaceAll(RegExp(r'\.0$'), '');
}

