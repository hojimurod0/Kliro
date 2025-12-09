class CalcRequest {
  const CalcRequest({
    required this.persons,
    required this.startDate,
    required this.endDate,
    required this.provider,
  });

  final List<Map<String, dynamic>> persons;
  final String startDate;
  final String endDate;
  final String provider;

  Map<String, dynamic> toJson() => {
        'persons': persons,
        'start_date': startDate,
        'end_date': endDate,
        'provider': provider,
      };
}

