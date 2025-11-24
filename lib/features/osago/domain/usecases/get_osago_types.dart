import '../entities/osago_type.dart';
import '../repositories/osago_repository.dart';

class GetOsagoTypes {
  const GetOsagoTypes(this.repository);

  final OsagoRepository repository;

  Future<List<OsagoType>> call() => repository.getTypes();
}

