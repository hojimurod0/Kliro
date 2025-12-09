import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'session_model.g.dart';

/// Модель сессии
@JsonSerializable()
class SessionModel extends Equatable {
  final String sessionId;
  final Map<String, dynamic>? data;

  const SessionModel({
    required this.sessionId,
    this.data,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  @override
  List<Object?> get props => [sessionId, data];
}

