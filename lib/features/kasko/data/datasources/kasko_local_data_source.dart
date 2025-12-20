import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_page_model.dart';
import '../models/kasko_tariff_model.dart';
import '../models/rate_model.dart';

class KaskoLocalDataSource {
  KaskoLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const String _carsCacheKey = 'kasko_cars_cache_v1';
  static const String _ratesCacheKey = 'kasko_rates_cache_v1';

  // ============================================
  // CARS CACHE
  // ============================================
  Future<void> cacheCarsPage(CarPageModel carPage) async {
    try {
      developer.log(
        'Caching kasko cars page=${carPage.number} size=${carPage.numberOfElements}',
        name: 'KaskoLocalDataSource',
      );
      final json = carPage.toJson();
      await _prefs.setString(_carsCacheKey, jsonEncode(json));
    } catch (e) {
      developer.log(
        'Error caching cars: $e',
        name: 'KaskoLocalDataSource',
        error: e,
      );
    }
  }

  CarPageModel? getLastCachedCarsPage() {
    try {
      final cached = _prefs.getString(_carsCacheKey);
      if (cached == null) {
        developer.log(
          'No cached kasko cars found',
          name: 'KaskoLocalDataSource',
        );
        return null;
      }
      developer.log(
        'Loaded cached kasko cars',
        name: 'KaskoLocalDataSource',
      );
      final json = jsonDecode(cached) as Map<String, dynamic>;
      return CarPageModel.fromJson(json);
    } catch (e) {
      developer.log(
        'Error loading cached cars: $e',
        name: 'KaskoLocalDataSource',
        error: e,
      );
      return null;
    }
  }

  // ============================================
  // RATES CACHE
  // ============================================
  Future<void> cacheRates(List<RateModel> rates) async {
    try {
      developer.log(
        'Caching kasko rates count=${rates.length}',
        name: 'KaskoLocalDataSource',
      );
      final jsonList = rates.map((rate) => rate.toJson()).toList();
      await _prefs.setString(_ratesCacheKey, jsonEncode(jsonList));
    } catch (e) {
      developer.log(
        'Error caching rates: $e',
        name: 'KaskoLocalDataSource',
        error: e,
      );
    }
  }

  List<RateModel>? getLastCachedRates() {
    try {
      final cached = _prefs.getString(_ratesCacheKey);
      if (cached == null) {
        developer.log(
          'No cached kasko rates found',
          name: 'KaskoLocalDataSource',
        );
        return null;
      }
      developer.log(
        'Loaded cached kasko rates',
        name: 'KaskoLocalDataSource',
      );
      final jsonList = jsonDecode(cached) as List<dynamic>;
      return jsonList
          .map((json) => RateModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Error loading cached rates: $e',
        name: 'KaskoLocalDataSource',
        error: e,
      );
      return null;
    }
  }

  // ============================================
  // CLEAR CACHE
  // ============================================
  Future<void> clearCarsCache() async {
    await _prefs.remove(_carsCacheKey);
    developer.log('Cleared kasko cars cache', name: 'KaskoLocalDataSource');
  }

  Future<void> clearRatesCache() async {
    await _prefs.remove(_ratesCacheKey);
    developer.log('Cleared kasko rates cache', name: 'KaskoLocalDataSource');
  }

  Future<void> clearAllCache() async {
    await clearCarsCache();
    await clearRatesCache();
  }

  // ============================================
  // LEGACY: Tariffs (for backward compatibility)
  // ============================================
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
