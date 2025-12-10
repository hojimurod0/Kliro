import 'package:easy_localization/easy_localization.dart';

/// Localizes API text strings by replacing hardcoded words like "dan", "gacha", "yil", "oy", "UZS", "so'm"
/// with their translated equivalents
String localizeApiText(String text) {
  if (text.isEmpty) return text;

  String localized = text;

  // Replace "UZS" currency - case insensitive
  localized = localized.replaceAllMapped(
    RegExp(r'\bUZS\b', caseSensitive: false),
    (match) => tr('common.uzs'),
  );

  // Replace "so'm" currency - case insensitive
  localized = localized.replaceAllMapped(
    RegExp(r"so'?m", caseSensitive: false),
    (match) => tr('common.soum'),
  );
  
  // Replace "som" (without apostrophe) - case insensitive
  localized = localized.replaceAllMapped(
    RegExp(r'\bsom\b', caseSensitive: false),
    (match) => tr('common.soum'),
  );

  // Replace "dan" (from) - case insensitive, but preserve context
  // Match "dan" that appears after numbers or at the start
  localized = localized.replaceAllMapped(
    RegExp(r'(\d+\.?\d*)\s*(dan|до|from)\b', caseSensitive: false),
    (match) {
      final number = match.group(1)!;
      return '$number ${tr('common.from')}';
    },
  );
  
  // Also replace standalone "dan" (from)
  localized = localized.replaceAllMapped(
    RegExp(r'\b(dan|до|from)\b', caseSensitive: false),
    (match) => tr('common.from'),
  );

  // Replace "gacha" (to/until) - case insensitive
  // Match "gacha" that appears after numbers or standalone
  localized = localized.replaceAllMapped(
    RegExp(r'(\d+\.?\d*)\s*(gacha|до|to|up to)\b', caseSensitive: false),
    (match) {
      final number = match.group(1)!;
      return '$number ${tr('common.to')}';
    },
  );
  
  // Also replace standalone "gacha" (to)
  localized = localized.replaceAllMapped(
    RegExp(r'\b(gacha|до|to|up to)\b', caseSensitive: false),
    (match) => tr('common.to'),
  );

  // Replace "yil" (year) with number - case insensitive
  // Matches patterns like "1 yil", "5 yil", "1 год", "5 years"
  localized = localized.replaceAllMapped(
    RegExp(r'(\d+)\s*(yil|год|year|years)\b', caseSensitive: false),
    (match) {
      final number = match.group(1)!;
      return '$number ${tr('common.year')}';
    },
  );

  // Replace "oy" (month) with number - case insensitive
  // Matches patterns like "12 oy", "6 oy", "12 месяц", "6 months"
  localized = localized.replaceAllMapped(
    RegExp(r'(\d+)\s*(oy|месяц|month|months)\b', caseSensitive: false),
    (match) {
      final number = match.group(1)!;
      return '$number ${tr('common.month')}';
    },
  );

  // Replace standalone "yil" (year) - case insensitive
  // Only if not already replaced (not preceded by a number)
  localized = localized.replaceAllMapped(
    RegExp(r'(?<!\d)\s*\b(yil|год|year)\b(?!\d)', caseSensitive: false),
    (match) => tr('common.year'),
  );

  // Replace standalone "oy" (month) - case insensitive
  // Only if not already replaced (not preceded by a number)
  localized = localized.replaceAllMapped(
    RegExp(r'(?<!\d)\s*\b(oy|месяц|month)\b(?!\d)', caseSensitive: false),
    (match) => tr('common.month'),
  );

  // Replace month names - case insensitive
  // Uzbek, Russian, and English months
  final monthMap = {
    // Uzbek months
    'yanvar': tr('common.january'),
    'fevral': tr('common.february'),
    'mart': tr('common.march'),
    'aprel': tr('common.april'),
    'iyun': tr('common.june'),
    'iyul': tr('common.july'),
    'avgust': tr('common.august'),
    'sentabr': tr('common.september'),
    'oktabr': tr('common.october'),
    'noyabr': tr('common.november'),
    'dekabr': tr('common.december'),
    // Russian months
    'январь': tr('common.january'),
    'февраль': tr('common.february'),
    'март': tr('common.march'),
    'апрель': tr('common.april'),
    'май': tr('common.may'),
    'июнь': tr('common.june'),
    'июль': tr('common.july'),
    'август': tr('common.august'),
    'сентябрь': tr('common.september'),
    'октябрь': tr('common.october'),
    'ноябрь': tr('common.november'),
    'декабрь': tr('common.december'),
    // English months (may is same in Uzbek and English, so only one entry)
    'january': tr('common.january'),
    'february': tr('common.february'),
    'march': tr('common.march'),
    'april': tr('common.april'),
    'may': tr('common.may'),
    'june': tr('common.june'),
    'july': tr('common.july'),
    'august': tr('common.august'),
    'september': tr('common.september'),
    'october': tr('common.october'),
    'november': tr('common.november'),
    'december': tr('common.december'),
  };

  for (final entry in monthMap.entries) {
    localized = localized.replaceAllMapped(
      RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false),
      (match) => entry.value,
    );
  }

  // Improve "dan ... gacha" pattern handling
  // Pattern: "X dan Y gacha" -> "X dan Y gacha" (already translated)
  // But also handle: "dan X gacha Y" -> "dan X gacha Y"
  // And: "X dan gacha Y" -> "X dan gacha Y"
  // This is already handled by previous replacements, but we ensure proper spacing
  localized = localized.replaceAllMapped(
    RegExp(r'\b(dan|до|from)\s+([^\s]+)\s+(gacha|до|to|up to)\s+([^\s]+)\b', caseSensitive: false),
    (match) {
      final fromWord = tr('common.from');
      final toWord = tr('common.to');
      final firstPart = match.group(2) ?? '';
      final secondPart = match.group(4) ?? '';
      return '$firstPart $fromWord $secondPart $toWord';
    },
  );

  // Clean up multiple spaces
  localized = localized.replaceAll(RegExp(r'\s+'), ' ');

  return localized.trim();
}
