import 'package:easy_localization/easy_localization.dart';

String formatCompactAmount(String raw) {
  final match = RegExp(r'[0-9][0-9\s.,]*').firstMatch(raw);
  if (match == null) return raw;

  final numericPart = match.group(0)!;
  final digitsOnly = numericPart.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) return raw;

  final amount = double.tryParse(digitsOnly);
  if (amount == null) return raw;

  final suffix = raw.substring(match.end).trim();
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

