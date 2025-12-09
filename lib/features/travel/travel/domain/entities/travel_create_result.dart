import 'package:equatable/equatable.dart';

class TravelCreateResult extends Equatable {
  const TravelCreateResult({
    required this.sessionId,
    required this.policyNumber,
    required this.paymentUrl,
    required this.amount,
    required this.currency,
    this.clickUrl,
    this.paymeUrl,
  });

  final String sessionId;
  final String policyNumber;
  final String paymentUrl;
  final double amount;
  final String currency;
  final String? clickUrl;
  final String? paymeUrl;

  @override
  List<Object?> get props => [
        sessionId,
        policyNumber,
        paymentUrl,
        amount,
        currency,
        clickUrl,
        paymeUrl,
      ];
}

