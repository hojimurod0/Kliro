import '../entities/insurance_service.dart';
import '../repositories/insurance_repository.dart';

class GetInsuranceServices {
  const GetInsuranceServices(this.repository);

  final InsuranceRepository repository;

  Future<List<InsuranceService>> call() => repository.getInsuranceServices();
}

