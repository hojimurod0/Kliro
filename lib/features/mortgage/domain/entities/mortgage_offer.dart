class MortgageOffer {
  const MortgageOffer({
    required this.bankName,
    required this.rating,
    required this.interestRate,
    required this.term,
    required this.maxSum,
    required this.downPayment,
    required this.advantages,
  });

  final String bankName;
  final double rating;
  final String interestRate;
  final String term;
  final String maxSum;
  final String downPayment;
  final List<String> advantages;
}

