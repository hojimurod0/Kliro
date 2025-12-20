import '../entities/avichipta.dart';
import '../repositories/avichiptalar_repository.dart';

class GetFlightDetails {
  GetFlightDetails(this._repository);

  final AvichiptalarRepository _repository;

  Future<Avichipta> call({required String flightId}) {
    return _repository.getFlightDetails(flightId: flightId);
  }
}

