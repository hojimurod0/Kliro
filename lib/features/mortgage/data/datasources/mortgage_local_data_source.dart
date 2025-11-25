import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class MortgageLocalDataSource {
  MortgageLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const String _cacheKey = 'mortgage_cache_v1';

  Future<void> cacheResponse(Map<String, dynamic> json) async {
    developer.log(
      'Caching mortgage response page=${json['number']} size=${json['number_of_elements']}',
      name: 'MortgageLocalDataSource',
    );
    await _prefs.setString(_cacheKey, jsonEncode(json));
  }

  Map<String, dynamic>? getLastCachedResponse() {
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) {
      developer.log(
        'No cached mortgage response found',
        name: 'MortgageLocalDataSource',
      );
      return null;
    }
    developer.log(
      'Loaded cached mortgage response',
      name: 'MortgageLocalDataSource',
    );
    return jsonDecode(cached) as Map<String, dynamic>;
  }
}
