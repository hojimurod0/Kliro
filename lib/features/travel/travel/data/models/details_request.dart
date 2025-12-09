class DetailsRequest {
  const DetailsRequest({
    required this.sessionId,
    required this.startDate,
    required this.endDate,
    required this.travelersBirthdates,
    required this.annualPolicy,
    required this.covidProtection,
  });

  final String sessionId;
  final String startDate; // DD-MM-YYYY
  final String endDate; // DD-MM-YYYY
  final List<String> travelersBirthdates; // DD-MM-YYYY
  final bool annualPolicy;
  final bool covidProtection;

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'start_date': startDate,
        'end_date': endDate,
        'travelers_birthdates': travelersBirthdates,
        'annual_policy': annualPolicy,
        'covid_protection': covidProtection,
      };
}

