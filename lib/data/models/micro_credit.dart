class MicroCredit {
  const MicroCredit({
    required this.bank,
    this.rate,
    this.termMonths,
    this.amount,
    this.opening,
  });

  final String bank;
  final double? rate;
  final int? termMonths;
  final double? amount;
  final String? opening;

  factory MicroCredit.fromJson(Map<String, dynamic> json) => MicroCredit(
        bank: json['bank'] as String? ?? '',
        rate: (json['rate'] as num?)?.toDouble(),
        termMonths: json['term_months'] as int?,
        amount: (json['amount'] as num?)?.toDouble(),
        opening: json['opening'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'bank': bank,
        'rate': rate,
        'term_months': termMonths,
        'amount': amount,
        'opening': opening,
      };
}

