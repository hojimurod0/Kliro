import 'package:equatable/equatable.dart';

class MortgageEntity extends Equatable {
  const MortgageEntity({
    required this.id,
    required this.bankName,
    required this.description,
    required this.interestRate,
    required this.term,
    required this.maxSum,
    required this.downPayment,
    this.currency,
    this.rating,
    this.advantages,
    this.createdAt,
  });

  final int id;
  final String bankName;
  final String description;
  final String interestRate;
  final String term;
  final String maxSum;
  final String downPayment;
  final String? currency;
  final double? rating;
  final List<String>? advantages;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        bankName,
        description,
        interestRate,
        term,
        maxSum,
        downPayment,
        currency,
        rating,
        advantages,
        createdAt,
      ];
}

