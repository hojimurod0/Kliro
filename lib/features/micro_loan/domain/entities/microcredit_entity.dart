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

