import 'package:equatable/equatable.dart';

class OsagoCheckResult extends Equatable {
  const OsagoCheckResult({
    required this.sessionId,
    required this.status,
    this.policyNumber,
    this.issuedAt,
    this.amount,
    this.currency,
    this.downloadUrl,
  });

  final String sessionId;
  final String status;
  final String? policyNumber;
  final DateTime? issuedAt;
  final double? amount;
  final String? currency;
  final String? downloadUrl;

  bool get isReady {
    final normalized = status.toLowerCase();
    return normalized == 'success' ||
        normalized == 'issued' ||
        normalized == 'completed';
  }

  @override
  List<Object?> get props => [
    sessionId,
    status,
    policyNumber,
    issuedAt,
    amount,
    currency,
    downloadUrl,
  ];
}
