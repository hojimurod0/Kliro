class CreateRequest {
  const CreateRequest({
    required this.sessionId,
    required this.provider,
    required this.persons,
    required this.startDate,
    required this.endDate,
    required this.phoneNumber,
    this.email,
  });

  final String sessionId;
  final String provider;
  final List<Map<String, dynamic>> persons;
  final String startDate;
  final String endDate;
  final String phoneNumber;
  final String? email;

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'provider': provider,
        'persons': persons,
        'start_date': startDate,
        'end_date': endDate,
        'phone_number': phoneNumber,
        if (email != null) 'email': email,
      };
}

