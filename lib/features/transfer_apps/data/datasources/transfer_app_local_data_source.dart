import '../models/transfer_app_model.dart';

class TransferAppLocalDataSource {
  const TransferAppLocalDataSource();

  List<TransferAppModel> fetchTransferApps() {
    return [
      TransferAppModel(
        name: 'Click',
        bank: 'Asaka Bank',
        rating: '4.8',
        users: '5M+',
        commission: '0.5%',
        limit: "100 mln so'm",
        tags: ['P2P', 'Karta', 'Hisob'],
        speed: 'Tezkor',
        advantages: const [
          'Past komissiya',
          'Tezkor o\'tkazma',
          '24/7 xizmat',
        ],
      ),
      TransferAppModel(
        name: 'Payme',
        bank: 'TBC Bank',
        rating: '4.9',
        users: '7M+',
        commission: '1.0%',
        limit: "50 mln so'm",
        tags: ['P2P', 'QR', 'Humo'],
        speed: 'Tezkor',
        advantages: const [
          'QR kod orqali',
          'Humo kartalar',
          'Cashback',
        ],
      ),
      TransferAppModel(
        name: 'Apelsin',
        bank: 'Kapital Bank',
        rating: '4.7',
        users: '3M+',
        commission: '0.3%',
        limit: "150 mln so'm",
        tags: ['Visa', 'Master', 'P2P'],
        speed: 'Tezkor',
        advantages: const [
          'Eng past komissiya',
          'Visa va Mastercard',
          'Yuqori limit',
        ],
      ),
    ];
  }
}

