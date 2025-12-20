import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fare_family_model.g.dart';

@JsonSerializable()
class FareFamilyModel extends Equatable {
  static String? _stringFromJson(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static String? _priceFromJson(dynamic v) {
    if (v == null) return null;
    if (v is num || v is String) return v.toString();
    if (v is Map<String, dynamic>) {
      return v['amount']?.toString() ?? v['value']?.toString() ?? v.toString();
    }
    return v.toString();
  }

  final String? id;
  final String? name;
  final String? description;
  @JsonKey(fromJson: _priceFromJson)
  final String? price;
  @JsonKey(fromJson: _stringFromJson)
  final String? currency;
  // Best-effort extra fields (API may differ)
  @JsonKey(name: 'hand_baggage')
  final Object? handBaggage;
  @JsonKey(name: 'hand_luggage')
  final Object? handLuggage;
  @JsonKey(name: 'carry_on')
  final Object? carryOn;
  final Object? baggage;
  @JsonKey(name: 'checked_baggage')
  final Object? checkedBaggage;
  final Object? exchange;
  final Object? change;
  final Object? refund;
  @JsonKey(name: 'return')
  final Object? returnPolicy;

  const FareFamilyModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.handBaggage,
    this.handLuggage,
    this.carryOn,
    this.baggage,
    this.checkedBaggage,
    this.exchange,
    this.change,
    this.refund,
    this.returnPolicy,
  });

  factory FareFamilyModel.fromJson(Map<String, dynamic> json) =>
      _$FareFamilyModelFromJson(json);

  Map<String, dynamic> toJson() => _$FareFamilyModelToJson(this);

  FareFamilyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    String? currency,
    Object? handBaggage,
    Object? handLuggage,
    Object? carryOn,
    Object? baggage,
    Object? checkedBaggage,
    Object? exchange,
    Object? change,
    Object? refund,
    Object? returnPolicy,
  }) {
    return FareFamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      handBaggage: handBaggage ?? this.handBaggage,
      handLuggage: handLuggage ?? this.handLuggage,
      carryOn: carryOn ?? this.carryOn,
      baggage: baggage ?? this.baggage,
      checkedBaggage: checkedBaggage ?? this.checkedBaggage,
      exchange: exchange ?? this.exchange,
      change: change ?? this.change,
      refund: refund ?? this.refund,
      returnPolicy: returnPolicy ?? this.returnPolicy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        currency,
        handBaggage,
        handLuggage,
        carryOn,
        baggage,
        checkedBaggage,
        exchange,
        change,
        refund,
        returnPolicy,
      ];
}

@JsonSerializable()
class FareFamilyResponseModel extends Equatable {
  final List<FareFamilyModel>? families;

  const FareFamilyResponseModel({
    this.families,
  });

  factory FareFamilyResponseModel.fromJson(Map<String, dynamic> json) {
    String? _extractText(Object? v) {
      if (v == null) return null;
      if (v is String) {
        final s = v.trim();
        return s.isEmpty ? null : s;
      }
      if (v is num) return v.toString();
      if (v is List) {
        for (final e in v) {
          final s = _extractText(e);
          if (s != null && s.toLowerCase() != 'null') return s;
        }
        return null;
      }
      if (v is Map) {
        // Prefer common locale keys first
        const localeKeys = ['en', 'ru', 'uz', 'uz_CYR', 'uz-CYR'];
        for (final k in localeKeys) {
          if (v.containsKey(k)) {
            final s = _extractText(v[k]);
            if (s != null && s.toLowerCase() != 'null') return s;
          }
        }
        // Then common nested keys
        const nestedKeys = ['title', 'name', 'value', 'text', 'label'];
        for (final k in nestedKeys) {
          if (v.containsKey(k)) {
            final s = _extractText(v[k]);
            if (s != null && s.toLowerCase() != 'null') return s;
          }
        }
        // Fallback: first string-like value
        for (final entry in v.entries) {
          final s = _extractText(entry.value);
          if (s != null && s.toLowerCase() != 'null') return s;
        }
        return null;
      }
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    String? pickText(List<Object?> values) {
      for (final v in values) {
        final s = _extractText(v);
        if (s != null && s.isNotEmpty && s.toLowerCase() != 'null') return s;
      }
      return null;
    }

    Map<String, dynamic>? asMap(Object? v) {
      // Accept both Map<String, dynamic> and Map<dynamic, dynamic> from Dio/JSON.
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    Map<String, dynamic> normalizeFamily(Map<String, dynamic> item) {
      // Some APIs return: { id, fare_family: { name, price, currency, ... }, ... }
      // Normalize to the flat keys expected by FareFamilyModel.
      final out = Map<String, dynamic>.from(item);

      final ff = asMap(out['fare_family']) ?? asMap(out['fareFamily']);
      final services = asMap(out['services']) ??
          asMap(out['service']) ??
          asMap(ff?['services']) ??
          asMap(ff?['service']);

      // id can be under different keys
      out['id'] ??= pickText([
        out['offer_id'],
        out['offerId'],
        out['fare_offer_id'],
        out['fareOfferId'],
        ff?['id'],
        ff?['offer_id'],
      ]);

      // name can be localized or use alternative keys
      // IMPORTANT: some APIs include `name: ""` (empty), so treat blank as missing.
      final existingName = _extractText(out['name']);
      if (existingName == null) {
        out['name'] = pickText([
        out['name_ru'],
        out['name_uz'],
        out['name_en'],
        out['title'],
        out['title_intl'],
        out['titleIntl'],
        out['name_intl'],
        out['nameIntl'],
        out['tariff_name'],
        out['tariffName'],
        out['tariff_title'],
        out['tariffTitle'],
        out['fare_name'],
        out['fareName'],
        out['fare_family_name'],
        out['fareFamilyName'],
        out['fare_family_title'],
        out['fareFamilyTitle'],
        out['family_name'],
        out['brand_name'],
        out['brandName'],
        out['brand'],
        out['tariff'],
        ff?['name'],
        ff?['name_ru'],
        ff?['name_uz'],
        ff?['name_en'],
        ff?['title'],
        ff?['title_intl'],
        ff?['titleIntl'],
        ff?['name_intl'],
        ff?['nameIntl'],
        ff?['tariff_name'],
        ff?['tariff_title'],
        ff?['tariffTitle'],
        ff?['fare_name'],
        ff?['fareName'],
        ff?['fare_family_name'],
        ff?['fare_family_title'],
        ff?['fareFamilyTitle'],
        ff?['family_name'],
        ff?['brand_name'],
        ff?['brand'],
        ff?['tariff'],
        ]) ?? out['name'];
      }

      final existingDesc = _extractText(out['description']);
      if (existingDesc == null) {
        out['description'] = pickText([
        out['description'],
        out['desc'],
        ff?['description'],
        ff?['desc'],
        ]) ?? out['description'];
      }

      // price/currency may be nested
      out['price'] ??= out['total_price'] ?? out['amount'] ?? ff?['price'];
      out['currency'] ??= pickText([
        out['currency'],
        ff?['currency'],
        asMap(out['price'])?['currency'],
        asMap(ff?['price'])?['currency'],
      ]);

      // Some APIs return fare family name under fare_family_type / fareFamilyType.
      // NOTE: we keep the existing "existingName" logic above; here we only add extra keys into that flow.
      final existingName2 = _extractText(out['name']);
      if (existingName2 == null) {
        out['name'] = pickText([
              out['fare_family_type'],
              out['fareFamilyType'],
              ff?['fare_family_type'],
              ff?['fareFamilyType'],
            ]) ??
            out['name'];
      }

      // Some APIs return full offer-like objects per tariff inside /fare-family:
      // { id, fare_family_type, price: {amount,currency}, directions:[{segments:[{handbags:{weight}, baggage:{weight}}]}] }
      Map<String, dynamic>? _bestBaggageFromDirections(
        Object? directionsValue,
        List<String> segmentKeys,
      ) {
        if (directionsValue is! List) return null;

        int? minWeight;
        int? minPiece;

        for (final d in directionsValue) {
          if (d is! Map) continue;
          final dm = Map<String, dynamic>.from(d);
          final segs = dm['segments'];
          if (segs is! List) continue;

          for (final s in segs) {
            if (s is! Map) continue;
            final sm = Map<String, dynamic>.from(s);

            Object? raw;
            for (final k in segmentKeys) {
              if (sm.containsKey(k)) {
                raw = sm[k];
                break;
              }
            }

            if (raw == null) continue;
            final rm = asMap(raw);
            if (rm == null) continue;

            final w = rm['weight'];
            final p = rm['piece'] ?? rm['pieces'];

            final weight =
                w is num ? w.toInt() : int.tryParse(w?.toString() ?? '');
            if (weight != null && weight > 0) {
              if (minWeight == null || weight < minWeight) minWeight = weight;
            }

            final piece =
                p is num ? p.toInt() : int.tryParse(p?.toString() ?? '');
            if (piece != null && piece > 0) {
              if (minPiece == null || piece < minPiece) minPiece = piece;
            }
          }
        }

        if (minWeight == null && minPiece == null) return null;
        final outMap = <String, dynamic>{};
        if (minPiece != null) outMap['piece'] = minPiece;
        if (minWeight != null) outMap['weight'] = minWeight;
        return outMap;
      }

      // Prefer segment-level baggage allowances if present.
      final directions =
          out['directions'] ?? ff?['directions'] ?? out['direction'] ?? ff?['direction'];
      final handFromSegs = _bestBaggageFromDirections(
        directions,
        const ['handbags', 'hand_baggage', 'handBaggage', 'hand_luggage', 'handLuggage', 'carry_on', 'carryOn', 'cabin_baggage', 'cabinBaggage'],
      );
      final bagFromSegs = _bestBaggageFromDirections(
        directions,
        const ['baggage', 'checked_baggage', 'checkedBaggage', 'baggage_allowance', 'baggageAllowance', 'luggage', 'luggage_allowance', 'luggageAllowance'],
      );

      bool _shouldOverrideWithMap(Object? current) {
        if (current == null) return true;
        // If API gives only a boolean like `baggage: true`, replace it with the detailed map we extracted.
        if (current is bool || current is num) return true;
        // If current is not a map, replace.
        return asMap(current) == null;
      }

      // Overwrite when we actually extracted something meaningful and existing value is non-informative.
      if (handFromSegs != null && _shouldOverrideWithMap(out['hand_baggage'])) {
        out['hand_baggage'] = handFromSegs;
      }
      if (bagFromSegs != null && _shouldOverrideWithMap(out['baggage'])) {
        // Put into both 'baggage' and 'checked_baggage' so downstream code can pick either.
        out['baggage'] = bagFromSegs;
      }
      if (bagFromSegs != null && _shouldOverrideWithMap(out['checked_baggage'])) {
        out['checked_baggage'] = bagFromSegs;
      }

      // If description is still missing, try to take it from segment comment/information_for_clients
      String? _firstSegmentText(Object? directionsValue, List<String> keys) {
        if (directionsValue is! List) return null;
        for (final d in directionsValue) {
          if (d is! Map) continue;
          final dm = Map<String, dynamic>.from(d);
          final segs = dm['segments'];
          if (segs is! List || segs.isEmpty) continue;
          final first = segs.first;
          if (first is! Map) continue;
          final sm = Map<String, dynamic>.from(first);
          for (final k in keys) {
            if (sm.containsKey(k)) {
              final s = _extractText(sm[k]);
              if (s != null) return s;
            }
          }
        }
        return null;
      }
      final descNow = _extractText(out['description']);
      if (descNow == null) {
        final segmentComment = _firstSegmentText(directions, const [
          'comment',
          'information_for_clients',
          'informationForClients',
        ]);
        out['description'] = pickText([
              out['comment'],
              out['information_for_clients'],
              out['informationForClients'],
              ff?['comment'],
              ff?['information_for_clients'],
              ff?['informationForClients'],
              segmentComment,
            ]) ??
            out['description'];
      }

      // baggage related keys can vary - try all possible locations
      // Hand baggage: try nested fare_family first, then top-level
      if (out['hand_baggage'] == null) {
        out['hand_baggage'] = ff?['hand_baggage'] ??
            ff?['handBaggage'] ??
            ff?['handbags'] ??
            ff?['hand_bags'] ??
            ff?['cabin_baggage'] ??
            ff?['cabinBaggage'] ??
            services?['hand_baggage'] ??
            services?['handBaggage'] ??
            services?['cabin_baggage'] ??
            services?['cabinBaggage'] ??
            services?['carry_on'] ??
            services?['carryOn'] ??
            out['handBaggage'] ??
            out['handbags'] ??
            out['hand_bags'] ??
            out['cabin_baggage'] ??
            out['cabinBaggage'];
      }
      // Hand luggage (alternative name)
      if (out['hand_luggage'] == null) {
        out['hand_luggage'] = ff?['hand_luggage'] ??
            ff?['handLuggage'] ??
            out['hand_luggage'] ??
            out['handLuggage'];
      }
      // Carry-on (alternative name)
      if (out['carry_on'] == null) {
        out['carry_on'] = ff?['carry_on'] ??
            ff?['carryOn'] ??
            out['carry_on'] ??
            out['carryOn'];
      }
      // Checked baggage: try nested fare_family first, then top-level
      if (out['baggage'] == null) {
        out['baggage'] = ff?['baggage'] ??
            ff?['checked_baggage'] ??
            ff?['checkedBaggage'] ??
            ff?['baggage_allowance'] ??
            ff?['baggageAllowance'] ??
            services?['baggage'] ??
            services?['checked_baggage'] ??
            services?['checkedBaggage'] ??
            services?['baggage_allowance'] ??
            services?['baggageAllowance'] ??
            services?['luggage'] ??
            services?['luggage_allowance'] ??
            services?['luggageAllowance'] ??
            out['checked_baggage'] ??
            out['checkedBaggage'] ??
            out['baggage_allowance'] ??
            out['baggageAllowance'];
      }
      // Checked baggage (explicit field)
      if (out['checked_baggage'] == null) {
        out['checked_baggage'] = ff?['checked_baggage'] ??
            ff?['checkedBaggage'] ??
            out['checked_baggage'] ??
            out['checkedBaggage'];
      }

      // rules text fields
      out['exchange'] ??= ff?['exchange'] ?? out['exchange'];
      out['change'] ??= ff?['change'] ?? out['change'];
      out['refund'] ??= ff?['refund'] ?? out['refund'];
      out['return'] ??= ff?['return'] ?? ff?['return_policy'] ?? out['return_policy'];

      return out;
    }

    List<dynamic>? extractFamiliesList(Map<String, dynamic> root) {
      dynamic raw = root['families'] ??
          root['fare_families'] ??
          root['fareFamilies'] ??
          root['tariffs'] ??
          root['tariflar'] ??
          root['data'] ??
          root['result'];

      for (var depth = 0; depth < 3; depth++) {
        if (raw is List) return raw;
        if (raw is Map) {
          final m = Map<String, dynamic>.from(raw);
          raw = m['families'] ??
              m['fare_families'] ??
              m['fareFamilies'] ??
              m['tariffs'] ??
              m['tariflar'] ??
              m['data'] ??
              m['result'];
          continue;
        }
        break;
      }
      return raw is List ? raw : null;
    }

    final list = extractFamiliesList(json);
    if (list != null) {
      return FareFamilyResponseModel(
        families: list
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .map(normalizeFamily)
            .map(FareFamilyModel.fromJson)
            .toList(),
      );
    }
    return FareFamilyResponseModel(families: const []);
  }

  Map<String, dynamic> toJson() => _$FareFamilyResponseModelToJson(this);

  FareFamilyResponseModel copyWith({
    List<FareFamilyModel>? families,
  }) {
    return FareFamilyResponseModel(
      families: families ?? this.families,
    );
  }

  @override
  List<Object?> get props => [families];
}




