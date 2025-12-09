class PurposeResponse {
  const PurposeResponse({
    required this.sessionId,
    this.data,
  });

  final String sessionId;
  final Map<String, dynamic>? data;

  factory PurposeResponse.fromJson(Map<String, dynamic> json) {
    // Обработка разных форматов ответа
    String sessionId;
    Map<String, dynamic>? data;

    if (json.containsKey('session_id')) {
      sessionId = json['session_id'] as String;
      data = json;
    } else if (json.containsKey('result')) {
      final result = json['result'] as Map<String, dynamic>;
      sessionId = result['session_id'] as String;
      data = result;
    } else if (json.containsKey('data')) {
      final result = json['data'] as Map<String, dynamic>;
      sessionId = result['session_id'] as String;
      data = result;
    } else {
      throw Exception('Неверный формат ответа: отсутствует session_id');
    }

    return PurposeResponse(sessionId: sessionId, data: data);
  }
}

