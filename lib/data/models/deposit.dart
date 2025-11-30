class Deposit {
  const Deposit({
    required this.bank,
    this.rate,
    this.termMonths,
    this.amount,
  });

  final String bank;
  final double? rate;
  final int? termMonths;
  final double? amount;

  factory Deposit.fromJson(Map<String, dynamic> json) => Deposit(
        bank: json['bank'] as String? ?? '',
        rate: (json['rate'] as num?)?.toDouble(),
        termMonths: json['term_months'] as int?,
        amount: (json['amount'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'bank': bank,
        'rate': rate,
        'term_months': termMonths,
        'amount': amount,
      };
}

