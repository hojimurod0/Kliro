class CalcResponse {
  const CalcResponse({
    required this.sessionId,
    required this.amount,
    this.currency = 'UZS',
    this.provider,
    this.availableProviders = const [],
  });

  final String sessionId;
  final double amount;
  final String currency;
  final String? provider;
  final List<Map<String, dynamic>> availableProviders;

  factory CalcResponse.fromJson(Map<String, dynamic> json) {
    final calcData = json['calc'] as Map<String, dynamic>?;
    final amountUzs = calcData?['amount_uzs'] as num? ?? json['amount'] as num?;
    
    return CalcResponse(
      sessionId: json['session_id'] as String,
      amount: (amountUzs ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'UZS',
      provider: json['provider'] as String?,
      availableProviders: json['available_providers'] as List<Map<String, dynamic>>? ?? [],
    );
  }
}

