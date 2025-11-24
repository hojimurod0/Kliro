import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/microcredit_entity.dart';

part 'microcredit_model.g.dart';

@JsonSerializable()
class MicrocreditModel {
  MicrocreditModel({
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

  @JsonKey(fromJson: _intFromJson)
  final int id;

  @JsonKey(name: 'bank_name', fromJson: _toString)
  final String bankName;

  @JsonKey(fromJson: _toString)
  final String description;

  @JsonKey(fromJson: _toString)
  final String rate;

  @JsonKey(fromJson: _toString)
  final String term;

  @JsonKey(fromJson: _toString)
  final String amount;

  @JsonKey(fromJson: _toString)
  final String channel;

  @JsonKey(fromJson: _toString)
  final String url;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory MicrocreditModel.fromJson(Map<String, dynamic> json) =>
      _$MicrocreditModelFromJson(json);

  Map<String, dynamic> toJson() => _$MicrocreditModelToJson(this);
}

extension MicrocreditModelX on MicrocreditModel {
  MicrocreditEntity toEntity() => MicrocreditEntity(
    id: id,
    bankName: bankName,
    description: description,
    rate: rate,
    term: term,
    amount: amount,
    channel: channel,
    url: url,
    createdAt: createdAt,
  );
}

String _toString(Object? value) => value?.toString() ?? '';

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
