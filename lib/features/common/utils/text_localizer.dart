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

  return localized.trim();
}
