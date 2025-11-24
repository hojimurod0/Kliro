import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class MicrocreditLocalDataSource {
  MicrocreditLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const String _cacheKey = 'microcredit_cache_v1';

  Future<void> cacheResponse(Map<String, dynamic> json) async {
    developer.log(
      'Caching microcredit response page=${json['number']} size=${json['number_of_elements']}',
      name: 'MicrocreditLocalDataSource',
    );
    await _prefs.setString(_cacheKey, jsonEncode(json));
  }

  Map<String, dynamic>? getLastCachedResponse() {
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) {
      developer.log(
        'No cached microcredit response found',
        name: 'MicrocreditLocalDataSource',
      );
      return null;
    }
    developer.log(
      'Loaded cached microcredit response',
      name: 'MicrocreditLocalDataSource',
    );
    return jsonDecode(cached) as Map<String, dynamic>;
  }
}
