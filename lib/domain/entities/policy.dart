import 'package:equatable/equatable.dart';

/// Сущность полиса
class Policy extends Equatable {
  final String? policyId;
  final String? policyNumber;
  final String? status;
  final Map<String, dynamic>? data;

  const Policy({
    this.policyId,
    this.policyNumber,
    this.status,
    this.data,
  });

  @override
  List<Object?> get props => [policyId, policyNumber, status, data];
}

