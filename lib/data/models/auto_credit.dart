class AutoCredit {
  const AutoCredit({
    required this.bank,
    this.rate,
    this.rateText,
    this.termMonths,
    this.termText,
    this.amount,
    this.amountText,
    this.opening,
  });

  final String bank;
  final double? rate;
  final String? rateText;
  final int? termMonths;
  final String? termText;
  final double? amount;
  final String? amountText;
  final String? opening;

  factory AutoCredit.fromJson(Map<String, dynamic> json) => AutoCredit(
        bank: (json['bank_name'] ?? json['bank']) as String? ?? '',
        rate: _parseDouble(json['rate']),
        rateText: _stringOrNull(json['rate']),
        termMonths: _parseTermMonths(json['term'] ?? json['term_months']),
        termText: _stringOrNull(json['term'] ?? json['term_months']),
        amount: _parseDouble(json['amount']),
        amountText: _stringOrNull(json['amount']),
        opening: (json['channel'] ?? json['opening']) as String?,
      );

  Map<String, dynamic> toJson() => {
        'bank': bank,
        'rate': rate,
        'rate_text': rateText,
        'term_months': termMonths,
        'term_text': termText,
        'amount': amount,
        'amount_text': amountText,
        'opening': opening,
      };
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final str = value.toLowerCase().trim();
    // Игнорируем строки типа "Ko'rsatilmagan", "не показано" и т.д.
    if (str.contains("ko'rsatilmagan") ||
        str.contains("не показано") ||
        str.contains("not shown") ||
        str.isEmpty) {
      return null;
    }
    final cleaned = str.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
  return null;
}

int? _parseTermMonths(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final str = value.toLowerCase();
    // Парсим "5 yil" -> 60 месяцев
    // Парсим "4 yil - 5 yil" -> берем максимум (60 месяцев)
    // Парсим "12 oy" -> 12 месяцев
    
    int? maxMonths;
    
    // Ищем все годы (yil) в строке, включая диапазоны
    final yearMatches = RegExp(r'(\d+)\s*yil').allMatches(str);
    for (final match in yearMatches) {
      final years = int.tryParse(match.group(1) ?? '');
      if (years != null) {
        final months = years * 12;
        maxMonths = maxMonths == null ? months : (maxMonths > months ? maxMonths : months);
      }
    }
    
    if (maxMonths != null) return maxMonths;
    
    // Ищем все месяцы (oy) в строке
    final monthMatches = RegExp(r'(\d+)\s*oy').allMatches(str);
    for (final match in monthMatches) {
      final months = int.tryParse(match.group(1) ?? '');
      if (months != null) {
        maxMonths = maxMonths == null ? months : (maxMonths > months ? maxMonths : months);
      }
    }
    
    if (maxMonths != null) return maxMonths;
    
    // Если просто число - считаем месяцами
    final cleaned = str.replaceAll(RegExp(r'[^0-9\-]'), '');
    if (cleaned.isNotEmpty) {
      return int.tryParse(cleaned);
    }
  }
  return null;
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString().trim();
  if (stringValue.isEmpty) return null;
  return stringValue;
}

