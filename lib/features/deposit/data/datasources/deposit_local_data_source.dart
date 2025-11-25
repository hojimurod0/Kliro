import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class DepositLocalDataSource {
  DepositLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const String _cacheKey = 'deposit_cache_v1';

  Future<void> cacheResponse(Map<String, dynamic> json) async {
    developer.log(
      'Caching deposit response page=${json['number']} size=${json['number_of_elements']}',
      name: 'DepositLocalDataSource',
    );
    await _prefs.setString(_cacheKey, jsonEncode(json));
  }

  Map<String, dynamic>? getLastCachedResponse() {
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) {
      developer.log(
        'No cached deposit response found',
        name: 'DepositLocalDataSource',
      );
      return null;
    }
    developer.log(
      'Loaded cached deposit response',
      name: 'DepositLocalDataSource',
    );
    return jsonDecode(cached) as Map<String, dynamic>;
  }
}
