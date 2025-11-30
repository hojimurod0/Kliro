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
    this.propertyType,
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
  final String? propertyType;
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
        propertyType,
        createdAt,
      ];
}

Map<String, dynamic> mortgageEntityToMap(MortgageEntity entity) {
  return <String, dynamic>{
    'id': entity.id,
    'bankName': entity.bankName,
    'description': entity.description,
    'interestRate': entity.interestRate,
    'term': entity.term,
    'maxSum': entity.maxSum,
    'downPayment': entity.downPayment,
    'currency': entity.currency,
    'rating': entity.rating,
    'advantages': entity.advantages,
    'propertyType': entity.propertyType,
    'createdAt': entity.createdAt?.toIso8601String(),
  };
}

MortgageEntity mortgageEntityFromMap(Map<String, dynamic> map) {
  return MortgageEntity(
    id: map['id'] as int,
    bankName: map['bankName'] as String,
    description: map['description'] as String,
    interestRate: map['interestRate'] as String,
    term: map['term'] as String,
    maxSum: map['maxSum'] as String,
    downPayment: map['downPayment'] as String,
    currency: map['currency'] as String?,
    rating: (map['rating'] as num?)?.toDouble(),
    advantages: (map['advantages'] as List<dynamic>?)
        ?.map((dynamic e) => e.toString())
        .toList(),
    propertyType: map['propertyType'] as String?,
    createdAt: map['createdAt'] == null
        ? null
        : DateTime.tryParse(map['createdAt'] as String),
  );
}

