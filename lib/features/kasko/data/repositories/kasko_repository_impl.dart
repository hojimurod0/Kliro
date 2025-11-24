import '../../domain/entities/kasko_tariff.dart';
import '../../domain/repositories/kasko_repository.dart';
import '../datasources/kasko_local_data_source.dart';
import '../models/kasko_tariff_model.dart';

class KaskoRepositoryImpl implements KaskoRepository {
  final KaskoLocalDataSource localDataSource;

  const KaskoRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<KaskoTariff>> getTariffs() async {
    final models = await localDataSource.fetchTariffs();
    return models;
  }
}

