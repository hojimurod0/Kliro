import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/search_offers_request_model.dart';

/// Utility class for flight-related helper functions
class FlightUtils {
  // Price parsing cache
  static final Map<String, double?> _priceCache = {};
  static const int _maxCacheSize = 100;

  static double? parsePriceValue(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // Check cache first
    if (_priceCache.containsKey(raw)) {
      return _priceCache[raw];
    }

    // Parse price
    final s0 = raw.trim();
    if (s0.isEmpty) return null;
    var s =
        s0.replaceAll('\u00A0', '').replaceAll(' ', '').replaceAll(',', '.');
    s = s.replaceAll(RegExp(r'[^0-9.]'), '');
    if (s.isEmpty) return null;
    final parts = s.split('.');
    if (parts.length > 2) {
      final dec = parts.removeLast();
      final intPart = parts.join();
      s = dec.isEmpty ? intPart : '$intPart.$dec';
    }

    final result = double.tryParse(s);

    // Cache result (with size limit)
    if (_priceCache.length >= _maxCacheSize) {
      _priceCache.clear(); // Simple eviction strategy
    }
    _priceCache[raw] = result;

    return result;
  }

  /// Clear price cache (useful for testing or memory management)
  static void clearPriceCache() {
    _priceCache.clear();
  }

  static String formatPriceHuman(String raw) {
    final v = parsePriceValue(raw);
    if (v == null) return raw;

    final intPart = v.floor();
    final frac = v - intPart;

    String groupInt(int n) {
      final s = n.toString();
      final rev = s.split('').reversed.toList();
      final buf = StringBuffer();
      for (var i = 0; i < rev.length; i++) {
        if (i > 0 && i % 3 == 0) buf.write(' ');
        buf.write(rev[i]);
      }
      return buf.toString().split('').reversed.join();
    }

    final intStr = groupInt(intPart);
    if (frac.abs() < 1e-9) return intStr;

    // Show up to 1 decimal (common for API like "16982131.1")
    final fixed = v.toStringAsFixed(1);
    final fixedParts = fixed.split('.');
    if (fixedParts.length != 2) return intStr;
    final dec = fixedParts[1].replaceFirst(RegExp(r'0+$'), '');
    if (dec.isEmpty) return intStr;
    return '$intStr,$dec';
  }

  static String apiOfferIdForApi(String? id) {
    final s = (id ?? '').trim();
    final m = RegExp(r'-(\d+)$').firstMatch(s);
    if (m == null) return s;
    final suffix = m.group(1);
    if ((suffix == '0' || suffix == '1') && s.length > 25) {
      return s.substring(0, m.start);
    }
    return s;
  }

  static List<Map<String, dynamic>> groupOffers(
    List<OfferModel> offers,
    bool isRoundTrip,
    SearchOffersRequestModel? searchRequest,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
          'groupOffers: Boshlanmoqda, ${offers.length} ta offer, isRoundTrip=$isRoundTrip');
    }

    if (!isRoundTrip || searchRequest == null) {
      // Single direction - simple map
      if (kDebugMode) {
        AppLogger.debug(
            'groupOffers: Bir yo\'nalish, ${offers.length} ta offer qaytaryapmiz');
      }
      return offers
          .map((offer) => {'id': offer.id, 'outbound': offer, 'inbound': null})
          .toList();
    }

    final directions = searchRequest.directions;
    if (directions.length < 2) {
      if (kDebugMode) {
        AppLogger.debug(
            'groupOffers: 2 dan kam yo\'nalish, ${offers.length} ta offer qaytaryapmiz');
      }
      return offers
          .map((offer) => {'id': offer.id, 'outbound': offer, 'inbound': null})
          .toList();
    }

    final outboundDirection = directions[0];
    final inboundDirection = directions[1];

    if (kDebugMode) {
      AppLogger.debug(
          'groupOffers: Round trip - outbound: ${outboundDirection.departureAirport}->${outboundDirection.arrivalAirport}');
      AppLogger.debug(
          'groupOffers: Round trip - inbound: ${inboundDirection.departureAirport}->${inboundDirection.arrivalAirport}');
    }

    final grouped = <Map<String, dynamic>>[];
    final usedIndices = <int>{};
    int skippedEmptySegments = 0;
    int skippedNoMatch = 0;

    for (var i = 0; i < offers.length; i++) {
      if (usedIndices.contains(i)) continue;

      final outboundOffer = offers[i];
      final outboundSegments = outboundOffer.segments ?? [];

      if (outboundSegments.isEmpty) {
        skippedEmptySegments++;
        AppLogger.debug(
            'groupOffers: Offer $i bo\'sh segments, o\'tkazib yuborilmoqda');
        continue;
      }

      final firstDeparture = outboundSegments.first.departureAirport;
      final lastArrival = outboundSegments.last.arrivalAirport;

      final matchesOutbound =
          firstDeparture == outboundDirection.departureAirport &&
              lastArrival == outboundDirection.arrivalAirport;

      if (!matchesOutbound) {
        skippedNoMatch++;
        if (kDebugMode) {
          AppLogger.debug(
              'groupOffers: Offer $i outbound ga mos kelmaydi: $firstDeparture->$lastArrival (kutilgan: ${outboundDirection.departureAirport}->${outboundDirection.arrivalAirport})');
        }
        grouped.add({
          'id': outboundOffer.id,
          'outbound': outboundOffer,
          'inbound': null,
        });
        usedIndices.add(i);
        continue;
      }

      OfferModel? inboundOffer;
      int? inboundIndex;

      for (var j = i + 1; j < offers.length; j++) {
        if (usedIndices.contains(j)) continue;

        final candidateOffer = offers[j];
        final candidateSegments = candidateOffer.segments ?? [];

        if (candidateSegments.isEmpty) continue;

        final candidateDeparture = candidateSegments.first.departureAirport;
        final candidateArrival = candidateSegments.last.arrivalAirport;

        final matchesInbound =
            candidateDeparture == inboundDirection.departureAirport &&
                candidateArrival == inboundDirection.arrivalAirport;

        if (matchesInbound) {
          inboundOffer = candidateOffer;
          inboundIndex = j;
          break;
        }
      }

      grouped.add({
        'id': '${outboundOffer.id}_${inboundOffer?.id ?? 'single'}',
        'outbound': outboundOffer,
        'inbound': inboundOffer,
      });

      usedIndices.add(i);
      if (inboundIndex != null) {
        usedIndices.add(inboundIndex);
      }
    }

    for (var i = 0; i < offers.length; i++) {
      if (!usedIndices.contains(i)) {
        grouped.add({
          'id': offers[i].id,
          'outbound': offers[i],
          'inbound': null,
        });
      }
    }

    AppLogger.debug(
        'groupOffers: Yakuniy natija - ${grouped.length} ta guruhlangan offer');
    AppLogger.debug(
        'groupOffers: Bo\'sh segments bilan o\'tkazib yuborilgan: $skippedEmptySegments');
    AppLogger.debug('groupOffers: Mos kelmagan: $skippedNoMatch');

    return grouped;
  }
}
