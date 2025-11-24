import 'package:equatable/equatable.dart';

class GoogleAuthRedirect extends Equatable {
  const GoogleAuthRedirect({
    required this.url,
    this.sessionId,
  });

  final String url;
  final String? sessionId;

  @override
  List<Object?> get props => [url, sessionId];
}

