import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/transfer_app.dart';

part 'transfer_app_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TransferAppModel {
  TransferAppModel({
    required this.id,
    required this.name,
    required this.bank,
    this.commission,
    this.limit,
    this.speed,
    this.tags = const <String>[],
    this.advantages = const <String>[],
    this.rating,
    this.users,
    this.channel,
    this.downloadUrl,
    this.logo,
    this.description,
    this.platforms = const <String>[],
    this.createdAt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int id;

  @JsonKey(readValue: _readName, fromJson: _stringFromJson)
  final String name;

  @JsonKey(readValue: _readBank, fromJson: _stringFromJson)
  final String bank;

  @JsonKey(readValue: _readCommission, fromJson: _stringOrNull)
  final String? commission;

  @JsonKey(readValue: _readLimit, fromJson: _stringOrNull)
  final String? limit;

  @JsonKey(readValue: _readSpeed, fromJson: _stringOrNull)
  final String? speed;

  @JsonKey(
    readValue: _readTags,
    fromJson: _stringListFromJson,
    defaultValue: <String>[],
  )
  final List<String> tags;

  @JsonKey(
    readValue: _readAdvantages,
    fromJson: _stringListFromJson,
    defaultValue: <String>[],
  )
  final List<String> advantages;

  @JsonKey(readValue: _readRating, fromJson: _stringOrNull)
  final String? rating;

  @JsonKey(readValue: _readUsers, fromJson: _stringOrNull)
  final String? users;

  @JsonKey(readValue: _readChannel, fromJson: _stringOrNull)
  final String? channel;

  @JsonKey(readValue: _readDownloadUrl, fromJson: _stringOrNull)
  final String? downloadUrl;

  @JsonKey(readValue: _readLogo, fromJson: _stringOrNull)
  final String? logo;

  @JsonKey(readValue: _readDescription, fromJson: _stringOrNull)
  final String? description;

  @JsonKey(
    readValue: _readPlatforms,
    fromJson: _stringListFromJson,
    defaultValue: <String>[],
  )
  final List<String> platforms;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory TransferAppModel.fromJson(Map<String, dynamic> json) =>
      _$TransferAppModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransferAppModelToJson(this);
}

extension TransferAppModelX on TransferAppModel {
  TransferApp toEntity() => TransferApp(
    id: id,
    name: name,
    bank: bank,
    commission: commission,
    limit: limit,
    speed: speed,
    tags: List<String>.unmodifiable(tags),
    advantages: List<String>.unmodifiable(advantages),
    rating: rating,
    users: users,
    channel: channel,
    downloadUrl: downloadUrl,
    logo: logo,
    description: description,
    platforms: List<String>.unmodifiable(platforms),
    createdAt: createdAt,
  );
}

int _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

String _stringFromJson(Object? value) {
  if (value == null) return '';
  return value.toString();
}

String? _stringOrNull(Object? value) {
  if (value == null) return null;
  final stringValue = value.toString().trim();
  return stringValue.isEmpty ? null : stringValue;
}

List<String> _stringListFromJson(Object? value) {
  if (value is List) {
    return value
        .map((item) => item?.toString().trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (value is String && value.isNotEmpty) {
    return value
        .split(RegExp(r'[;,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

Object? _readName(Map<dynamic, dynamic> json, String key) =>
    json['app'] ?? json['app_name'] ?? json['name'];

Object? _readBank(Map<dynamic, dynamic> json, String key) =>
    json['bank'] ?? json['bank_name'] ?? json['provider'];

Object? _readCommission(Map<dynamic, dynamic> json, String key) {
  final direct = json['commission'];
  if (direct != null) return direct;

  final from = json['commission_from'];
  final to = json['commission_to'];
  if (from == null && to == null) return null;

  if (from != null && to != null) {
    if (from.toString() == to.toString()) {
      return from;
    }
    return '${from.toString()} - ${to.toString()}';
  }
  return from ?? to;
}

Object? _readLimit(Map<dynamic, dynamic> json, String key) {
  final direct = json['limit'] ?? json['limit_text'];
  if (direct != null) return direct;

  final min = json['amount_from'] ?? json['limit_from'];
  final max = json['amount_to'] ?? json['limit_to'];
  if (min == null && max == null) return null;
  if (min != null && max != null) {
    if (min.toString() == max.toString()) {
      return min;
    }
    return '${min.toString()} - ${max.toString()}';
  }
  return min ?? max;
}

Object? _readSpeed(Map<dynamic, dynamic> json, String key) =>
    json['speed'] ?? json['transfer_speed'] ?? json['delivery'];

Object? _readTags(Map<dynamic, dynamic> json, String key) {
  final tags = json['tags'];
  if (tags is List) return tags;

  final channels = json['channels'];
  if (channels is List) return channels;

  final opening = json['opening'];
  if (opening is String && opening.isNotEmpty) {
    return <String>[opening];
  }
  return null;
}

Object? _readAdvantages(Map<dynamic, dynamic> json, String key) =>
    json['advantages'] ?? json['features'];

Object? _readRating(Map<dynamic, dynamic> json, String key) =>
    json['rating'] ?? json['score'];

Object? _readUsers(Map<dynamic, dynamic> json, String key) =>
    json['users'] ?? json['downloads'] ?? json['audience'];

Object? _readChannel(Map<dynamic, dynamic> json, String key) =>
    json['channel'] ?? json['opening'];

Object? _readDownloadUrl(Map<dynamic, dynamic> json, String key) =>
    json['download_url'] ?? json['url'] ?? json['link'];

Object? _readPlatforms(Map<dynamic, dynamic> json, String key) =>
    json['platforms'] ?? json['os'];

Object? _readLogo(Map<dynamic, dynamic> json, String key) =>
    json['logo'] ?? json['logo_url'] ?? json['icon'];

Object? _readDescription(Map<dynamic, dynamic> json, String key) =>
    json['description'] ?? json['about'];
