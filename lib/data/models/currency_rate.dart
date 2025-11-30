class CurrencyRate {
  const CurrencyRate({
    required this.code,
    this.buyRate,
    this.sellRate,
    this.date,
  });

  final String code;
  final double? buyRate;
  final double? sellRate;
  final DateTime? date;

  factory CurrencyRate.fromJson(Map<String, dynamic> json) => CurrencyRate(
        code: json['code'] as String? ?? '',
        buyRate: (json['buy_rate'] as num?)?.toDouble(),
        sellRate: (json['sell_rate'] as num?)?.toDouble(),
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'buy_rate': buyRate,
        'sell_rate': sellRate,
        'date': date?.toIso8601String(),
      };
}

