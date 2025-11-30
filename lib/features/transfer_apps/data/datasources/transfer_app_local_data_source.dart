import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transfer_app_model.dart';

class TransferAppLocalDataSource {
  TransferAppLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _cacheKey = 'transfer_apps_cache_v1';

  Future<void> cacheResponse(List<Map<String, dynamic>> payload) async {
    developer.log(
      'Caching ${payload.length} transfer apps',
      name: 'TransferAppLocalDataSource',
    );
    await _prefs.setString(_cacheKey, jsonEncode(payload));
  }

  List<TransferAppModel>? getLastCachedApps() {
    final cached = _prefs.getString(_cacheKey);
    if (cached == null) {
      developer.log(
        'No cached transfer apps found',
        name: 'TransferAppLocalDataSource',
      );
      return null;
    }

    try {
      final decoded = jsonDecode(cached) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TransferAppModel.fromJson)
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to decode cached transfer apps',
        name: 'TransferAppLocalDataSource',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}

