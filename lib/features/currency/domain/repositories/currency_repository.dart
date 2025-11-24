import '../entities/currency_rate.dart';

abstract class CurrencyRepository {
  List<CurrencyRate> getRates();
}
