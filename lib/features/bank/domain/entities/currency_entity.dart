/// Domain entity for currency exchange rates.
/// This is a clean entity without any JSON serialization logic.
class CurrencyEntity {
  const CurrencyEntity({
    required this.id,
    required this.bankName,
    required this.currencyCode,
    required this.currencyName,
    required this.buyRate,
    required this.sellRate,
    this.location,
    this.rating,
    this.schedule,
    this.isOnline,
    this.lastUpdated,
  });

  final int id;
  final String bankName;
  final String currencyCode; // e.g., "USD", "EUR"
  final String currencyName; // e.g., "US Dollar", "Euro"
  final double buyRate; // Sotib olish kursi
  final double sellRate; // Sotish kursi
  final String? location; // Bank joylashuvi
  final double? rating; // Bank reytingi
  final String? schedule; // Ish vaqti
  final bool? isOnline; // Online xizmat mavjudligi
  final DateTime? lastUpdated; // So'ngi yangilanish vaqti
}

