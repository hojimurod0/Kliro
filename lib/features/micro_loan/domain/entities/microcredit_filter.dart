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

