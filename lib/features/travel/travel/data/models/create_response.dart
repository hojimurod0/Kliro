class CreateResponse {
  const CreateResponse({
    required this.sessionId,
    this.policyNumber,
    this.paymentUrl,
    this.amount = 0.0,
    this.currency = 'UZS',
    this.pay,
    this.resultCode,
    this.resultMessage,
    this.provider,
  });

  final String sessionId;
  final String? policyNumber;
  final String? paymentUrl;
  final double amount;
  final String currency;
  final Map<String, dynamic>? pay;
  final int? resultCode;
  final String? resultMessage;
  final String? provider;

  factory CreateResponse.fromJson(Map<String, dynamic> json) {
    // Response format: {result: {provider: "apex", response: {result: -18, result_message: "..."}, session_id: "..."}, success: true}
    final result = json['result'] as Map<String, dynamic>?;
    
    if (result == null) {
      throw Exception('Missing result in response');
    }
    
    final responseObj = result['response'] as Map<String, dynamic>?;
    final resultCode = responseObj?['result'] as int?;
    final resultMessage = responseObj?['result_message'] as String?;
    
    // Agar xatolik bo'lsa (result < 0), exception throw qilish
    if (resultCode != null && resultCode < 0) {
      throw Exception(resultMessage ?? 'Xatolik yuz berdi');
    }
    
    final amountUzs = responseObj?['stoimost_uzs'] as num? ?? responseObj?['amount_uzs'] as num? ?? json['amount'] as num?;
    
    // click_link va payme_link ni parse qilish
    final clickLink = responseObj?['click_link'] as String?;
    final paymeLink = responseObj?['payme_link'] as String?;
    
    // pay map'ni yaratish (click va payme linklarini qo'shish)
    Map<String, dynamic>? payMap;
    if (clickLink != null || paymeLink != null) {
      payMap = {};
      if (clickLink != null) {
        payMap['click'] = clickLink;
      }
      if (paymeLink != null) {
        payMap['payme'] = paymeLink;
      }
    } else {
      // Eski format uchun fallback
      payMap = responseObj?['pay'] as Map<String, dynamic>? ?? json['pay'] as Map<String, dynamic>?;
    }
    
    return CreateResponse(
      sessionId: result['session_id'] as String? ?? json['session_id'] as String? ?? '',
      policyNumber: responseObj?['policy_number'] as String? ?? json['policy_number'] as String?,
      paymentUrl: responseObj?['payment_url'] as String? ?? json['payment_url'] as String?,
      amount: (amountUzs ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'UZS',
      pay: payMap,
      resultCode: resultCode,
      resultMessage: resultMessage,
      provider: result['provider'] as String?,
    );
  }
}

