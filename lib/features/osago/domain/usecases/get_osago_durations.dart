import '../entities/osago_duration.dart';
import '../repositories/osago_repository.dart';

class GetOsagoDurations {
  const GetOsagoDurations(this.repository);

  final OsagoRepository repository;

  Future<List<OsagoDuration>> call() => repository.getDurations();
}

