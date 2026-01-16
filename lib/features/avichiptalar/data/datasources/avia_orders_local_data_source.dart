import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AviaOrderRef {
  final String bookingId;
  final int createdAtMs;

  const AviaOrderRef({
    required this.bookingId,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'created_at_ms': createdAtMs,
      };

  static AviaOrderRef? tryParse(dynamic raw) {
    try {
      if (raw is Map) {
        final m = Map<String, dynamic>.from(raw);
        final id = (m['booking_id'] ?? m['bookingId'])?.toString().trim();
        final created = m['created_at_ms'] ?? m['createdAtMs'];
        final createdAtMs = created is num
            ? created.toInt()
            : int.tryParse(created?.toString() ?? '');
        if (id != null && id.isNotEmpty && createdAtMs != null) {
          return AviaOrderRef(bookingId: id, createdAtMs: createdAtMs);
        }
      }
      if (raw is String) {
        final id = raw.trim();
        if (id.isNotEmpty) {
          return AviaOrderRef(
            bookingId: id,
            createdAtMs: DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
    } catch (_) {}
    return null;
  }
}

/// Local storage for Avia orders (booking ids) until backend provides list endpoint.
class AviaOrdersLocalDataSource {
  static const _key = 'avia_my_orders_v1';

  final SharedPreferences _prefs;

  AviaOrdersLocalDataSource(this._prefs);

  List<AviaOrderRef> getOrders() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = decoded
            .map(AviaOrderRef.tryParse)
            .whereType<AviaOrderRef>()
            .toList();
        // newest first
        items.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
        return items;
      }
    } catch (_) {}
    return [];
  }

  Future<void> addOrder(String bookingId) async {
    final id = bookingId.trim();
    if (id.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = getOrders();

    // de-dupe: keep the newest timestamp for the same id
    final filtered = existing.where((e) => e.bookingId != id).toList();
    filtered.insert(0, AviaOrderRef(bookingId: id, createdAtMs: now));

    await _prefs.setString(
      _key,
      jsonEncode(filtered.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeOrder(String bookingId) async {
    final id = bookingId.trim();
    if (id.isEmpty) return;
    final existing = getOrders();
    final filtered = existing.where((e) => e.bookingId != id).toList();
    await _prefs.setString(
      _key,
      jsonEncode(filtered.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}








