class CreateRequest {
  const CreateRequest({
    required this.sessionId,
    required this.provider,
    required this.summaAll,
    required this.programId,
    required this.sugurtalovchi,
    required this.travelers,
  });

  final String sessionId;
  final String provider;
  final int summaAll;
  final String programId;
  final Map<String, dynamic> sugurtalovchi;
  final List<Map<String, dynamic>> travelers;

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'provider': provider,
        'summa_all': summaAll,
        'program_id': programId,
        'sugurtalovchi': sugurtalovchi,
        'travelers': travelers,
      };
}

