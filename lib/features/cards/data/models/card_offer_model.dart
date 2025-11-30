import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/card_offer.dart';

part 'card_offer_model.g.dart';

@JsonSerializable()
class CardOfferModel {
  CardOfferModel({
    required this.id,
    required this.bankName,
    required this.cardName,
    this.cardNetwork,
    this.cardCategory,
    this.cardType,
    this.currency,
    this.cashback,
    this.serviceFee,
    this.limitAmount,
    this.delivery,
    this.opening,
    this.description,
    this.gracePeriod,
    this.minIncome,
    this.processingTime,
    this.rating,
    this.url,
    this.advantages,
    this.features,
    this.createdAt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int id;

  @JsonKey(name: 'bank_name', fromJson: _toString)
  final String bankName;

  @JsonKey(name: 'card_name', fromJson: _toString)
  final String cardName;

  @JsonKey(name: 'card_network', fromJson: _toStringOrNull)
  final String? cardNetwork;

  @JsonKey(name: 'card_category', fromJson: _toStringOrNull)
  final String? cardCategory;

  @JsonKey(name: 'card_type', fromJson: _toStringOrNull)
  final String? cardType;

  @JsonKey(fromJson: _toStringOrNull)
  final String? currency;

  @JsonKey(fromJson: _toStringOrNull)
  final String? cashback;

  @JsonKey(name: 'service_fee', fromJson: _toStringOrNull)
  final String? serviceFee;

  @JsonKey(name: 'limit_amount', fromJson: _toStringOrNull)
  final String? limitAmount;

  @JsonKey(fromJson: _toStringOrNull)
  final String? delivery;

  @JsonKey(fromJson: _toStringOrNull)
  final String? opening;

  @JsonKey(fromJson: _toStringOrNull)
  final String? description;

  @JsonKey(name: 'grace_period', fromJson: _toStringOrNull)
  final String? gracePeriod;

  @JsonKey(name: 'min_income', fromJson: _toStringOrNull)
  final String? minIncome;

  @JsonKey(name: 'processing_time', fromJson: _toStringOrNull)
  final String? processingTime;

  @JsonKey(fromJson: _doubleFromJsonOrNull)
  final double? rating;

  @JsonKey(fromJson: _toStringOrNull)
  final String? url;

  @JsonKey(fromJson: _stringListFromJson)
  final List<String>? advantages;

  @JsonKey(fromJson: _stringListFromJson)
  final List<String>? features;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory CardOfferModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeCardJson(json);
    return _$CardOfferModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$CardOfferModelToJson(this);
}

extension CardOfferModelX on CardOfferModel {
  CardOffer toEntity() => CardOffer(
    id: id,
    bankName: bankName,
    cardName: cardName,
    cardNetwork: cardNetwork,
    cardCategory: cardCategory,
    cardType: cardType,
    currency: currency,
    cashback: cashback,
    serviceFee: serviceFee,
    limitAmount: limitAmount,
    delivery: delivery,
    opening: opening,
    description: description,
    gracePeriod: gracePeriod,
    minIncome: minIncome,
    processingTime: processingTime,
    rating: rating,
    url: url,
    advantages: advantages,
    features: features,
    createdAt: createdAt,
    isPrimaryCard: (url ?? '').isNotEmpty,
  );
}

Map<String, dynamic> _normalizeCardJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);

  void ensureKey(String target, List<String> fallbacks) {
    final current = normalized[target];
    if (current == null ||
        (current is String && current.trim().isEmpty) ||
        (current is num && current == 0)) {
      for (final key in fallbacks) {
        final candidate = json[key];
        if (candidate == null) continue;
        normalized[target] = candidate;
        break;
      }
    }
  }

  ensureKey('bank_name', const ['bankName', 'bank']);
  ensureKey('card_name', const ['cardName', 'name', 'title', 'description']);
  ensureKey('card_network', const ['cardNetwork', 'network', 'card_tag']);
  ensureKey('card_category', const ['category', 'cardCategory', 'type_tag']);
  ensureKey('card_type', const ['cardType', 'type', 'card_category']);
  ensureKey('currency', const ['currency_code', 'valyuta', 'currencyCode']);
  ensureKey('cashback', const ['cashback_percent', 'cashbackPercent']);
  ensureKey('service_fee', const ['annual_fee', 'yearly_fee', 'serviceFee']);
  ensureKey('limit_amount', const ['limit', 'max_limit', 'limitAmount']);
  ensureKey('delivery', const ['opening', 'delivery_type']);
  ensureKey('grace_period', const ['grace', 'gracePeriod']);
  ensureKey('processing_time', const ['processingTime', 'issuance_time']);
  ensureKey('min_income', const ['income', 'income_requirement']);
  ensureKey('advantages', const ['benefits', 'features']);

  normalized['id'] = normalized['id'] ?? normalized['card_id'] ?? 0;

  return normalized;
}

String _toString(Object? value) => value?.toString() ?? '';

String? _toStringOrNull(Object? value) {
  if (value == null) return null;
  final str = value.toString();
  if (str.trim().isEmpty) return null;
  return str;
}

double? _doubleFromJsonOrNull(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _intFromJson(Object? value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<String>? _stringListFromJson(Object? value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  if (value is String && value.contains(',')) {
    return value.split(',').map((e) => e.trim()).toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return null;
}
