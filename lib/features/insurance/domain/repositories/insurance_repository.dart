import '../entities/insurance_service.dart';

abstract class InsuranceRepository {
  Future<List<InsuranceService>> getInsuranceServices();
}

