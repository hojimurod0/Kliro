import 'package:equatable/equatable.dart';

class MicrocreditEntity extends Equatable {
  const MicrocreditEntity({
    required this.id,
    required this.bankName,
    required this.description,
    required this.rate,
    required this.term,
    required this.amount,
    required this.channel,
    required this.url,
    this.createdAt,
  });

  final int id;
  final String bankName;
  final String description;
  final String rate;
  final String term;
  final String amount;
  final String channel;
  final String url;
  final DateTime? createdAt;

  bool get isOnline => channel.toLowerCase().contains('onlayn');

  @override
  List<Object?> get props => [
        id,
        bankName,
        description,
        rate,
        term,
        amount,
        channel,
        url,
        createdAt,
      ];
}

Map<String, dynamic> microcreditEntityToMap(MicrocreditEntity entity) {
  return <String, dynamic>{
    'id': entity.id,
    'bankName': entity.bankName,
    'description': entity.description,
    'rate': entity.rate,
    'term': entity.term,
    'amount': entity.amount,
    'channel': entity.channel,
    'url': entity.url,
    'createdAt': entity.createdAt?.toIso8601String(),
  };
}

MicrocreditEntity microcreditEntityFromMap(Map<String, dynamic> map) {
  return MicrocreditEntity(
    id: map['id'] as int,
    bankName: map['bankName'] as String,
    description: map['description'] as String,
    rate: map['rate'] as String,
    term: map['term'] as String,
    amount: map['amount'] as String,
    channel: map['channel'] as String,
    url: map['url'] as String,
    createdAt: map['createdAt'] == null
        ? null
        : DateTime.tryParse(map['createdAt'] as String),
  );
}

