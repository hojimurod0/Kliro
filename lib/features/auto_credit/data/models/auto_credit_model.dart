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

  factory AutoCredit.fromJson(Map<String, dynamic> json) {
    return AutoCredit(
      bank: json['bank'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble(),
      rateText: json['rate_text'] as String?,
      termMonths: json['term_months'] as int?,
      termText: json['term_text'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      amountText: json['amount_text'] as String?,
      opening: json['opening'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank': bank,
      if (rate != null) 'rate': rate,
      if (rateText != null) 'rate_text': rateText,
      if (termMonths != null) 'term_months': termMonths,
      if (termText != null) 'term_text': termText,
      if (amount != null) 'amount': amount,
      if (amountText != null) 'amount_text': amountText,
      if (opening != null) 'opening': opening,
    };
  }
}

