import 'package:equatable/equatable.dart';

import '../../../domain/entities/travel_calc_result.dart';
import '../../../domain/entities/travel_check_result.dart';
import '../../../domain/entities/travel_create_result.dart';
import '../../../domain/entities/travel_insurance.dart';
import '../../../domain/entities/travel_person.dart';

abstract class TravelState extends Equatable {
  const TravelState({
    this.persons = const <TravelPerson>[],
    this.insurance,
    this.calcResponse,
    this.createResponse,
    this.checkResponse,
    this.paymentMethod,
    this.errorMessage,
    this.sessionId,
  });

  final List<TravelPerson> persons;
  final TravelInsurance? insurance;
  final TravelCalcResult? calcResponse;
  final TravelCreateResult? createResponse;
  final TravelCheckResult? checkResponse;
  final String? paymentMethod;
  final String? errorMessage;
  final String? sessionId;

  @override
  List<Object?> get props => [
        persons,
        insurance,
        calcResponse,
        createResponse,
        checkResponse,
        paymentMethod,
        errorMessage,
        sessionId,
      ];
}

class TravelInitial extends TravelState {
  const TravelInitial();
}

class TravelLoading extends TravelState {
  const TravelLoading({
    super.persons,
    super.insurance,
    super.calcResponse,
    super.createResponse,
    super.checkResponse,
    super.paymentMethod,
    super.sessionId,
  });
}

class TravelPersonsFilled extends TravelState {
  const TravelPersonsFilled({
    required super.persons,
    super.insurance,
    super.sessionId,
  });
}

class TravelInsuranceFilled extends TravelState {
  const TravelInsuranceFilled({
    required super.persons,
    required super.insurance,
    super.sessionId,
  });
}

class TravelCalcSuccess extends TravelState {
  const TravelCalcSuccess({
    required super.persons,
    required super.insurance,
    required super.calcResponse,
    super.paymentMethod,
    super.sessionId,
  });
}

class TravelCreateSuccess extends TravelState {
  const TravelCreateSuccess({
    required super.persons,
    required super.insurance,
    required super.calcResponse,
    required super.createResponse,
    super.paymentMethod,
    super.sessionId,
  });
}

class TravelCheckSuccess extends TravelState {
  const TravelCheckSuccess({
    required super.persons,
    required super.insurance,
    required super.calcResponse,
    required super.createResponse,
    required super.checkResponse,
    super.paymentMethod,
    super.sessionId,
  });
}

class TravelFailure extends TravelState {
  const TravelFailure({
    required String message,
    super.persons,
    super.insurance,
    super.calcResponse,
    super.createResponse,
    super.checkResponse,
    super.paymentMethod,
    super.sessionId,
  }) : super(errorMessage: message);
}

class PurposeCreated extends TravelState {
  const PurposeCreated({
    required String sessionId,
    super.persons,
    super.insurance,
  }) : super(sessionId: sessionId);
}

class DetailsSaved extends TravelState {
  const DetailsSaved({
    super.persons,
    super.insurance,
    super.sessionId,
  });
}

class CountriesLoaded extends TravelState {
  const CountriesLoaded({
    required this.countries,
    super.persons,
    super.insurance,
    super.sessionId,
  });

  final List<dynamic> countries;

  @override
  List<Object?> get props => [countries, ...super.props];
}

class TarifsLoaded extends TravelState {
  const TarifsLoaded({
    required this.tarifs,
    super.persons,
    super.insurance,
    super.sessionId,
  });

  final Map<String, dynamic> tarifs;

  @override
  List<Object?> get props => [
        tarifs,
        ...super.props,
      ];
}

class PurposesLoaded extends TravelState {
  const PurposesLoaded({
    required this.purposes,
    super.persons,
    super.insurance,
    super.sessionId,
  });

  final List<dynamic> purposes;

  @override
  List<Object?> get props => [purposes, ...super.props];
}

