import 'package:equatable/equatable.dart';

class CardFilter extends Equatable {
  const CardFilter({
    this.search,
    this.bank,
    this.cardNetwork,
    this.cardCategory,
    this.cardType,
    this.opening,
    this.sort,
    this.direction,
  });

  static const CardFilter empty = CardFilter();

  final String? search;
  final String? bank;
  final String? cardNetwork;
  final String? cardCategory;
  final String? cardType;
  final String? opening;
  final String? sort;
  final String? direction;

  CardFilter copyWith({
    String? search,
    String? bank,
    String? cardNetwork,
    String? cardCategory,
    String? cardType,
    String? opening,
    String? sort,
    String? direction,
    bool resetSearch = false,
    bool resetBank = false,
    bool resetCardNetwork = false,
    bool resetCardCategory = false,
    bool resetCardType = false,
    bool resetOpening = false,
    bool resetSort = false,
    bool resetDirection = false,
  }) {
    return CardFilter(
      search: resetSearch ? null : (search ?? this.search),
      bank: resetBank ? null : (bank ?? this.bank),
      cardNetwork: resetCardNetwork ? null : (cardNetwork ?? this.cardNetwork),
      cardCategory: resetCardCategory
          ? null
          : (cardCategory ?? this.cardCategory),
      cardType: resetCardType ? null : (cardType ?? this.cardType),
      opening: resetOpening ? null : (opening ?? this.opening),
      sort: resetSort ? null : (sort ?? this.sort),
      direction: resetDirection ? null : (direction ?? this.direction),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{};
    if ((search ?? '').isNotEmpty) map['search'] = search?.trim();
    if ((bank ?? '').isNotEmpty) map['bank'] = bank?.trim();
    if ((cardNetwork ?? '').isNotEmpty) {
      map['card_network'] = cardNetwork?.trim();
    }
    if ((cardCategory ?? '').isNotEmpty) {
      map['card_category'] = cardCategory?.trim();
    }
    if ((cardType ?? '').isNotEmpty) {
      map['card_type'] = cardType?.trim();
    }
    if ((opening ?? '').isNotEmpty) map['opening'] = opening?.trim();
    if ((sort ?? '').isNotEmpty) map['sort'] = sort?.trim();
    if ((direction ?? '').isNotEmpty) map['direction'] = direction?.trim();
    return map;
  }

  bool get hasActiveFilters =>
      (bank ?? '').isNotEmpty ||
      (cardNetwork ?? '').isNotEmpty ||
      (cardCategory ?? '').isNotEmpty ||
      (cardType ?? '').isNotEmpty ||
      (opening ?? '').isNotEmpty ||
      (sort ?? '').isNotEmpty ||
      (direction ?? '').isNotEmpty;

  @override
  List<Object?> get props => [
    search,
    bank,
    cardNetwork,
    cardCategory,
    cardType,
    opening,
    sort,
    direction,
  ];
}
