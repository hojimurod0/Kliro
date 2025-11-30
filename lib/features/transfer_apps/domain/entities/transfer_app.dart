import 'package:equatable/equatable.dart';

class TransferApp extends Equatable {
  const TransferApp({
    required this.id,
    required this.name,
    required this.bank,
    this.commission,
    this.limit,
    this.speed,
    this.tags = const [],
    this.advantages = const [],
    this.rating,
    this.users,
    this.channel,
    this.downloadUrl,
    this.logo,
    this.description,
    this.platforms = const [],
    this.createdAt,
  });

  final int id;
  final String name;
  final String bank;
  final String? commission;
  final String? limit;
  final String? speed;
  final List<String> tags;
  final List<String> advantages;
  final String? rating;
  final String? users;
  final String? channel;
  final String? downloadUrl;
  final String? logo;
  final String? description;
  final List<String> platforms;
  final DateTime? createdAt;

  String get displayCommission =>
      (commission == null || commission!.isEmpty) ? '—' : commission!;

  String get displayLimit => (limit == null || limit!.isEmpty) ? '—' : limit!;

  String get displaySpeed => speed ?? 'Tezkor';

  String get displayRating => rating?.isNotEmpty == true ? rating! : '—';

  String get displayUsers => users?.isNotEmpty == true ? users! : '—';

  bool get hasAdvantages => advantages.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        bank,
        commission,
        limit,
        speed,
        tags,
        advantages,
        rating,
        users,
        channel,
        downloadUrl,
        logo,
        description,
        platforms,
        createdAt,
      ];
}

