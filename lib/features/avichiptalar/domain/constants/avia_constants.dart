/// Constants for Avia module
class AviaConstants {
  AviaConstants._(); // Private constructor to prevent instantiation

  // Commission and pricing
  static const double commissionRate = 1.1; // 10% commission
  static const String defaultCurrency = 'sum';

  // Cache settings
  static const int maxCacheSize = 50;
  static const Duration cacheTTL = Duration(hours: 1);

  // Prefetch settings
  static const int prefetchBatchSize = 3;
  static const int maxPrefetchOffers = 10;

  // ListView optimization
  static const double listViewCacheExtent = 500.0;
  static const int maxOffersForIsolate = 50;

  // Animation settings
  static const Duration baseAnimationDuration = Duration(milliseconds: 300);
  static const int animationDelayPerItem = 50;

  // Date validation
  static const int maxDaysInFuture = 365;
  static const int minPassengers = 1;
  static const int maxPassengers = 9;

  // Service class
  static const String defaultServiceClass = 'A';
}

