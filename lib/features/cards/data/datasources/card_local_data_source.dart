import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class CardLocalDataSource {
  CardLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const String _cacheKey = 'card_offers_cache_v1';

  Future<void> cacheResponse(Map<String, dynamic> json) async {
    developer.log(
      'Caching card offers page=${json['number']} '
      'items=${json['number_of_elements']}',
      name: 'CardLocalDataSource',
    );
    await _prefs.setString(_cacheKey, jsonEncode(json));
  }

  Map<String, dynamic>? getLastCachedResponse() {
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) {
      developer.log('No cached card offers found', name: 'CardLocalDataSource');
      return null;
    }
    developer.log('Returning cached card offers', name: 'CardLocalDataSource');
    return jsonDecode(cached) as Map<String, dynamic>;
  }
}
