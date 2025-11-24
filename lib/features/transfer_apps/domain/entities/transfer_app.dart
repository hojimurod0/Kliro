class TransferApp {
  const TransferApp({
    required this.name,
    required this.bank,
    required this.rating,
    required this.users,
    required this.commission,
    required this.limit,
    required this.tags,
    this.speed = 'Tezkor',
    this.advantages = const [],
  });

  final String name;
  final String bank;
  final String rating;
  final String users;
  final String commission;
  final String limit;
  final List<String> tags;
  final String speed;
  final List<String> advantages;
}

