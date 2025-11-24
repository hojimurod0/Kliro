import '../models/kasko_tariff_model.dart';

class KaskoLocalDataSource {
  const KaskoLocalDataSource();

  Future<List<KaskoTariffModel>> fetchTariffs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      KaskoTariffModel(
        id: '1',
        title: 'Standart A',
        duration: '12 oy',
        description: 'To\'liq zarar qoplash 80%',
        price: '550 000',
      ),
      KaskoTariffModel(
        id: '2',
        title: 'Standart B',
        duration: '12 oy',
        description: 'To\'liq zarar qoplash 90%',
        price: '750 000',
      ),
    ];
  }
}

