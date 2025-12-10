class CalcRequest {
  const CalcRequest({
    required this.sessionId,
    this.accident = false,
    this.luggage = false,
    this.cancelTravel = false,
    this.personRespon = false,
    this.delayTravel = false,
    this.programId,
  });

  final String sessionId;
  final bool accident;
  final bool luggage;
  final bool cancelTravel;
  final bool personRespon;
  final bool delayTravel;
  final String? programId;

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'accident': accident,
        'luggage': luggage,
        'cancel_travel': cancelTravel,
        'person_respon': personRespon,
        'delay_travel': delayTravel,
      };
}

