class CheckResponse {
  const CheckResponse({
    required this.sessionId,
    required this.status,
    required this.policyNumber,
    required this.amount,
    this.currency = 'UZS',
    this.issuedAt,
    this.downloadUrl,
  });

  final String sessionId;
  final String status;
  final String policyNumber;
  final double amount;
  final String currency;
  final String? issuedAt;
  final String? downloadUrl;

  factory CheckResponse.fromJson(Map<String, dynamic> json) {
    return CheckResponse(
      sessionId: json['session_id'] as String,
      status: json['status'] as String,
      policyNumber: json['policy_number'] as String? ?? json['policyNumber'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'UZS',
      issuedAt: json['issued_at'] as String? ?? json['issuedAt'] as String?,
      downloadUrl: json['download_url'] as String? ?? json['downloadUrl'] as String?,
    );
  }
}

