import 'package:equatable/equatable.dart';

import '../../../domain/entities/travel_insurance.dart';
import '../../../domain/entities/travel_person.dart';

abstract class TravelEvent extends Equatable {
  const TravelEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonsData extends TravelEvent {
  const LoadPersonsData({
    required this.persons,
    this.insurance,
  });

  final List<TravelPerson> persons;
  final TravelInsurance? insurance;

  @override
  List<Object?> get props => [persons, insurance];
}

class LoadInsuranceData extends TravelEvent {
  const LoadInsuranceData(this.insurance);

  final TravelInsurance insurance;

  @override
  List<Object?> get props => [insurance];
}

class CalcRequested extends TravelEvent {
  const CalcRequested();
}

class CreatePolicyRequested extends TravelEvent {
  const CreatePolicyRequested();
}

class PaymentSelected extends TravelEvent {
  const PaymentSelected(this.method);

  final String method;

  @override
  List<Object?> get props => [method];
}

class CheckPolicyRequested extends TravelEvent {
  const CheckPolicyRequested();
}

class PurposeSubmitted extends TravelEvent {
  const PurposeSubmitted({
    required this.purposeId,
    required this.destinations,
  });

  final int purposeId;
  final List<String> destinations;

  @override
  List<Object?> get props => [purposeId, destinations];
}

class DetailsSubmitted extends TravelEvent {
  const DetailsSubmitted({
    required this.sessionId,
    required this.startDate,
    required this.endDate,
    required this.travelersBirthdates,
    required this.annualPolicy,
    required this.covidProtection,
  });

  final String sessionId;
  final String startDate;
  final String endDate;
  final List<String> travelersBirthdates;
  final bool annualPolicy;
  final bool covidProtection;

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

class LoadCountries extends TravelEvent {
  const LoadCountries();
}

class LoadTarifs extends TravelEvent {
  const LoadTarifs(this.countryCode);

  final String countryCode;

  @override
  List<Object?> get props => [countryCode];
}

class LoadPurposes extends TravelEvent {
  const LoadPurposes();
}

