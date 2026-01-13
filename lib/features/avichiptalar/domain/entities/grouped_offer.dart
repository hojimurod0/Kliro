import '../../data/models/offer_model.dart';
import 'package:equatable/equatable.dart';

/// Represents a grouped offer (outbound + optional inbound for round trips)
class GroupedOffer extends Equatable {
  final String id;
  final OfferModel outbound;
  final OfferModel? inbound;

  const GroupedOffer({
    required this.id,
    required this.outbound,
    this.inbound,
  });

  /// Create from legacy Map format
  factory GroupedOffer.fromMap(Map<String, dynamic> map) {
    return GroupedOffer(
      id: map['id'] as String? ?? '',
      outbound: map['outbound'] as OfferModel,
      inbound: map['inbound'] as OfferModel?,
    );
  }

  /// Convert to Map format (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'outbound': outbound,
      'inbound': inbound,
    };
  }

  /// Check if this is a round trip offer
  bool get isRoundTrip => inbound != null;

  @override
  List<Object?> get props => [id, outbound, inbound];
}
