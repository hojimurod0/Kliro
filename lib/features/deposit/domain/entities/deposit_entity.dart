import 'package:equatable/equatable.dart';

class DepositEntity extends Equatable {
  const DepositEntity({
    required this.id,
    required this.bankName,
    required this.description,
    required this.rate,
    required this.term,
    required this.amount,
    this.currency,
    this.createdAt,
  });

  final int id;
  final String bankName;
  final String description;
  final String rate;
  final String term;
  final String amount;
  final String? currency;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        bankName,
        description,
        rate,
        term,
        amount,
        currency,
        createdAt,
      ];
}

