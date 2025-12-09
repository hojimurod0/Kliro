class CreateResponse {
  const CreateResponse({
    required this.sessionId,
    required this.policyNumber,
    required this.paymentUrl,
    required this.amount,
    this.currency = 'UZS',
    this.pay,
  });

  final String sessionId;
  final String policyNumber;
  final String paymentUrl;
  final double amount;
  final String currency;
  final Map<String, dynamic>? pay;

  factory CreateResponse.fromJson(Map<String, dynamic> json) {
    final responseObj = json['response'] as Map<String, dynamic>?;
    final amountUzs = responseObj?['amount_uzs'] as num? ?? json['amount'] as num?;
    
    return CreateResponse(
      sessionId: json['session_id'] as String? ?? json['sessionId'] as String,
      policyNumber: json['policy_number'] as String? ?? json['policyNumber'] as String,
      paymentUrl: json['payment_url'] as String? ?? json['paymentUrl'] as String,
      amount: (amountUzs ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'UZS',
      pay: json['pay'] as Map<String, dynamic>?,
    );
  }
}

