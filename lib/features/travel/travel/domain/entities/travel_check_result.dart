import 'package:equatable/equatable.dart';

class TravelCheckResult extends Equatable {
  const TravelCheckResult({
    required this.sessionId,
    required this.status,
    required this.policyNumber,
    required this.amount,
    required this.currency,
    this.issuedAt,
    this.downloadUrl,
  });

  final String sessionId;
  final String status;
  final String policyNumber;
  final double amount;
  final String currency;
  final DateTime? issuedAt;
  final String? downloadUrl;

  @override
  List<Object?> get props => [
        sessionId,
        status,
        policyNumber,
        amount,
        currency,
        issuedAt,
        downloadUrl,
      ];
}

