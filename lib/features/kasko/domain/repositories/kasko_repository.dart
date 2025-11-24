import '../entities/kasko_tariff.dart';

abstract class KaskoRepository {
  Future<List<KaskoTariff>> getTariffs();
}

