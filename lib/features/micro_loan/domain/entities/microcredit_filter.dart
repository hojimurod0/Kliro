class MicrocreditFilter {
  const MicrocreditFilter({
    this.bank,
    this.rateFrom,
    this.termMonthsFrom,
    this.amountFrom,
    this.opening,
    this.search,
    this.sort,
    this.direction,
  });

  final String? bank;
  final double? rateFrom;
  final int? termMonthsFrom;
  final double? amountFrom;
  final String? opening;
  final String? search;
  final String? sort;
  final String? direction;

  static const MicrocreditFilter empty = MicrocreditFilter();

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (bank != null && bank!.isNotEmpty) 'bank': bank,
      if (rateFrom != null) 'rate_from': rateFrom,
      if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
      if (amountFrom != null) 'amount_from': amountFrom,
      if (opening != null && opening!.isNotEmpty) 'opening': opening,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      if (direction != null && direction!.isNotEmpty) 'direction': direction,
    };
  }

  MicrocreditFilter copyWith({
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
    String? sort,
    String? direction,
    bool resetBank = false,
    bool resetOpening = false,
    bool resetSearch = false,
    bool resetSort = false,
    bool resetDirection = false,
  }) {
    return MicrocreditFilter(
      bank: resetBank ? null : (bank ?? this.bank),
      rateFrom: rateFrom ?? this.rateFrom,
      termMonthsFrom: termMonthsFrom ?? this.termMonthsFrom,
      amountFrom: amountFrom ?? this.amountFrom,
      opening: resetOpening ? null : (opening ?? this.opening),
      search: resetSearch ? null : (search ?? this.search),
      sort: resetSort ? null : (sort ?? this.sort),
      direction: resetDirection ? null : (direction ?? this.direction),
    );
  }

  bool get hasActiveFilters =>
      bank != null ||
      rateFrom != null ||
      termMonthsFrom != null ||
      amountFrom != null ||
      opening != null ||
      search != null ||
      sort != null ||
      direction != null;
}

Map<String, dynamic> microcreditFilterToMap(MicrocreditFilter filter) {
  return <String, dynamic>{
    'bank': filter.bank,
    'rateFrom': filter.rateFrom,
    'termMonthsFrom': filter.termMonthsFrom,
    'amountFrom': filter.amountFrom,
    'opening': filter.opening,
    'search': filter.search,
    'sort': filter.sort,
    'direction': filter.direction,
  };
}

MicrocreditFilter microcreditFilterFromMap(Map<String, dynamic> map) {
  double? _toDouble(dynamic value) =>
      value == null ? null : (value as num).toDouble();
  int? _toInt(dynamic value) => value == null ? null : (value as num).toInt();

  return MicrocreditFilter(
    bank: map['bank'] as String?,
    rateFrom: _toDouble(map['rateFrom']),
    termMonthsFrom: _toInt(map['termMonthsFrom']),
    amountFrom: _toDouble(map['amountFrom']),
    opening: map['opening'] as String?,
    search: map['search'] as String?,
    sort: map['sort'] as String?,
    direction: map['direction'] as String?,
  );
}

