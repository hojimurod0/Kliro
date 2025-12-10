import 'package:equatable/equatable.dart';
import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/region_entity.dart';

abstract class AccidentEvent extends Equatable {
  const AccidentEvent();

  @override
  List<Object?> get props => [];
}

// Tariffs events
class FetchTariffs extends AccidentEvent {
  final bool forceRefresh;

  const FetchTariffs({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SelectTariff extends AccidentEvent {
  final TariffEntity tariff;

  const SelectTariff(this.tariff);

  @override
  List<Object?> get props => [tariff];
}

// Regions events
class FetchRegions extends AccidentEvent {
  final bool forceRefresh;

  const FetchRegions({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SelectRegion extends AccidentEvent {
  final RegionEntity region;

  const SelectRegion(this.region);

  @override
  List<Object?> get props => [region];
}

// Create Insurance event
class CreateInsurance extends AccidentEvent {
  final String startDate;
  final int tariffId;
  final String pinfl;
  final String passSery;
  final String passNum;
  final String dateBirth;
  final String lastName;
  final String firstName;
  final String? patronymName;
  final int region;
  final String phone;
  final String address;

  const CreateInsurance({
    required this.startDate,
    required this.tariffId,
    required this.pinfl,
    required this.passSery,
    required this.passNum,
    required this.dateBirth,
    required this.lastName,
    required this.firstName,
    this.patronymName,
    required this.region,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [
    startDate,
    tariffId,
    pinfl,
    passSery,
    passNum,
    dateBirth,
    lastName,
    firstName,
    patronymName,
    region,
    phone,
    address,
  ];
}

// Check Payment event
class CheckPayment extends AccidentEvent {
  final int anketaId;
  final String lan;

  const CheckPayment({required this.anketaId, required this.lan});

  @override
  List<Object?> get props => [anketaId, lan];
}
