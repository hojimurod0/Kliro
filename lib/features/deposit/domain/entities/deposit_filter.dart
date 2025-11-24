class DepositFilter {
  const DepositFilter({
    this.bank,
    this.rateFrom,
    this.termMonthsFrom,
    this.amountFrom,
    this.search,
    this.sort,
    this.direction,
  });

  final String? bank;
  final double? rateFrom;
  final int? termMonthsFrom;
  final double? amountFrom;
  final String? search;
  final String? sort;
  final String? direction;

  static const DepositFilter empty = DepositFilter();

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (bank != null && bank!.isNotEmpty) 'bank': bank,
      if (rateFrom != null) 'rate_from': rateFrom,
      if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
      if (amountFrom != null) 'amount_from': amountFrom,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      if (direction != null && direction!.isNotEmpty) 'direction': direction,
    };
  }

  DepositFilter copyWith({
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? search,
    String? sort,
    String? direction,
    bool resetBank = false,
    bool resetSearch = false,
    bool resetSort = false,
    bool resetDirection = false,
  }) {
    return DepositFilter(
      bank: resetBank ? null : (bank ?? this.bank),
      rateFrom: rateFrom ?? this.rateFrom,
      termMonthsFrom: termMonthsFrom ?? this.termMonthsFrom,
      amountFrom: amountFrom ?? this.amountFrom,
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
      search != null ||
      sort != null ||
      direction != null;
}

