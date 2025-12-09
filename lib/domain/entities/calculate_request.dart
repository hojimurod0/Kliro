import 'package:equatable/equatable.dart';

/// Сущность запроса расчета
class CalculateRequest extends Equatable {
  final String sessionId;
  final bool accident;
  final bool luggage;
  final bool cancelTravel;
  final bool personRespon;
  final bool delayTravel;

  const CalculateRequest({
    required this.sessionId,
    required this.accident,
    required this.luggage,
    required this.cancelTravel,
    required this.personRespon,
    required this.delayTravel,
  });

  @override
  List<Object?> get props => [
        sessionId,
        accident,
        luggage,
        cancelTravel,
        personRespon,
        delayTravel,
      ];
}

