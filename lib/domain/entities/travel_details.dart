import 'package:equatable/equatable.dart';

/// Сущность деталей путешествия
class TravelDetails extends Equatable {
  final String sessionId;
  final String startDate;
  final String endDate;
  final List<String> travelersBirthdates;
  final bool annualPolicy;
  final bool covidProtection;

  const TravelDetails({
    required this.sessionId,
    required this.startDate,
    required this.endDate,
    required this.travelersBirthdates,
    required this.annualPolicy,
    required this.covidProtection,
  });

  @override
  List<Object?> get props => [
        sessionId,
        startDate,
        endDate,
        travelersBirthdates,
        annualPolicy,
        covidProtection,
      ];
}

