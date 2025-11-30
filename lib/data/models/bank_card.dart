class BankCard {
  const BankCard({
    required this.bank,
    required this.cardType,
  });

  final String bank;
  final String cardType;

  factory BankCard.fromJson(Map<String, dynamic> json) => BankCard(
        bank: json['bank'] as String? ?? '',
        cardType: json['card_type'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'bank': bank,
        'card_type': cardType,
      };
}

