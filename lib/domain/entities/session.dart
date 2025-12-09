import 'package:equatable/equatable.dart';

/// Сущность сессии
class Session extends Equatable {
  final String sessionId;
  final Map<String, dynamic>? data;

  const Session({
    required this.sessionId,
    this.data,
  });

  @override
  List<Object?> get props => [sessionId, data];
}

