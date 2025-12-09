class TarifResponse {
  const TarifResponse({
    this.tarifs,
    this.data,
  });

  final List<Map<String, dynamic>>? tarifs;
  final Map<String, dynamic>? data;

  factory TarifResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> resultData = json;

    if (json.containsKey('result')) {
      resultData = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data')) {
      resultData = json['data'] as Map<String, dynamic>;
    }

    return TarifResponse(
      tarifs: resultData['tarifs'] as List<Map<String, dynamic>>?,
      data: resultData,
    );
  }
}

