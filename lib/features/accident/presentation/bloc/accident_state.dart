import 'package:equatable/equatable.dart';
import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/entities/create_insurance_entity.dart';
import '../../domain/entities/check_payment_entity.dart';

abstract class AccidentState extends Equatable {
  const AccidentState();

  @override
  List<Object?> get props => [];
}

class AccidentInitial extends AccidentState {
  const AccidentInitial();
}

// Tariffs states
class AccidentTariffsLoading extends AccidentState {
  const AccidentTariffsLoading();
}

class AccidentTariffsLoaded extends AccidentState {
  final List<TariffEntity> tariffs;
  final TariffEntity? selectedTariff;

  const AccidentTariffsLoaded(this.tariffs, {this.selectedTariff});

  @override
  List<Object?> get props => [tariffs, selectedTariff];
}

// Regions states
class AccidentRegionsLoading extends AccidentState {
  const AccidentRegionsLoading();
}

class AccidentRegionsLoaded extends AccidentState {
  final List<RegionEntity> regions;
  final RegionEntity? selectedRegion;

  const AccidentRegionsLoaded(this.regions, {this.selectedRegion});

  @override
  List<Object?> get props => [regions, selectedRegion];
}

// Create Insurance states
class AccidentCreatingInsurance extends AccidentState {
  const AccidentCreatingInsurance();
}

class AccidentInsuranceCreated extends AccidentState {
  final CreateInsuranceEntity insurance;

  const AccidentInsuranceCreated(this.insurance);

  @override
  List<Object?> get props => [insurance];
}

// Check Payment states
class AccidentCheckingPayment extends AccidentState {
  const AccidentCheckingPayment();
}

class AccidentPaymentChecked extends AccidentState {
  final CheckPaymentEntity paymentStatus;

  const AccidentPaymentChecked(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

// Error state
class AccidentError extends AccidentState {
  final String message;

  const AccidentError(this.message);

  @override
  List<Object?> get props => [message];
}
