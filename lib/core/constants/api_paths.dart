/// Пути API для Travel Insurance модуля
class ApiPaths {
  ApiPaths._();

  static const String travel = '/travel';

  /// POST /travel/purpose
  static const String purpose = '$travel/purpose';

  /// POST /travel/details
  static const String details = '$travel/details';

  /// POST /travel/calculate
  static const String calculate = '$travel/calculate';

  /// POST /travel/save
  static const String save = '$travel/save';

  /// POST /travel/check
  static const String check = '$travel/check';

  /// GET /travel/country
  static const String country = '$travel/country';

  /// GET /travel/purposes
  static const String purposes = '$travel/purposes';

  /// POST /travel/tarifs
  static const String tarifs = '$travel/tarifs';
}

