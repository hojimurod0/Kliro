import '../models/mortgage_offer_model.dart';

class MortgageLocalDataSource {
  const MortgageLocalDataSource();

  Future<List<MortgageOfferModel>> fetchMortgageOffers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      MortgageOfferModel(
        bankName: "Ipak Yuli Bank",
        rating: 4.7,
        interestRate: "14%",
        term: "20 yil",
        maxSum: "2 mlrd so'm",
        downPayment: "20% dan",
        advantages: const [
          "Tez yetkazib berish",
          "Yuqori sifat",
        ],
      ),
      MortgageOfferModel(
        bankName: "Ipak Yuli Bank",
        rating: 4.7,
        interestRate: "14%",
        term: "20 yil",
        maxSum: "2 mlrd so'm",
        downPayment: "20% dan",
        advantages: const [
          "Tez yetkazib berish",
          "Yuqori sifat",
        ],
      ),
      MortgageOfferModel(
        bankName: "Ipak Yuli Bank",
        rating: 4.7,
        interestRate: "14%",
        term: "20 yil",
        maxSum: "2 mlrd so'm",
        downPayment: "20% dan",
        advantages: const [
          "Tez yetkazib berish",
          "Yuqori sifat",
        ],
      ),
    ];
  }
}

