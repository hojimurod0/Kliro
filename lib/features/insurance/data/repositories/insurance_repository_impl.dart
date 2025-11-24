import '../../domain/entities/insurance_service.dart';
import '../../domain/repositories/insurance_repository.dart';
import '../datasources/insurance_local_data_source.dart';

class InsuranceRepositoryImpl implements InsuranceRepository {
  InsuranceRepositoryImpl({required InsuranceLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final InsuranceLocalDataSource _localDataSource;

  @override
  Future<List<InsuranceService>> getInsuranceServices() async {
    return await _localDataSource.fetchInsuranceServices();
  }
}

