import '../../domain/entities/transfer_app.dart';

class TransferAppModel extends TransferApp {
  const TransferAppModel({
    required super.name,
    required super.bank,
    required super.rating,
    required super.users,
    required super.commission,
    required super.limit,
    required super.tags,
    super.speed,
    super.advantages,
  });

  factory TransferAppModel.fromJson(Map<String, dynamic> json) {
    return TransferAppModel(
      name: json['name'] as String,
      bank: json['bank'] as String,
      rating: json['rating'] as String,
      users: json['users'] as String,
      commission: json['commission'] as String,
      limit: json['limit'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      speed: json['speed'] as String? ?? 'Tezkor',
      advantages: json['advantages'] != null
          ? (json['advantages'] as List<dynamic>).map((e) => e as String).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bank': bank,
      'rating': rating,
      'users': users,
      'commission': commission,
      'limit': limit,
      'tags': tags,
      'speed': speed,
      'advantages': advantages,
    };
  }
}

