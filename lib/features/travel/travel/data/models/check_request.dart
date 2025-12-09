class CheckRequest {
  const CheckRequest({required this.sessionId});

  final String sessionId;

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
      };
}

