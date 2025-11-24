import '../entities/osago_company.dart';
import '../repositories/osago_repository.dart';

class GetOsagoCompanies {
  const GetOsagoCompanies(this.repository);

  final OsagoRepository repository;

  Future<List<OsagoCompany>> call() => repository.getCompanies();
}

