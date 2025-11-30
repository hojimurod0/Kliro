class AutoCreditFilter {
  const AutoCreditFilter({
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

  static const AutoCreditFilter empty = AutoCreditFilter();

  Map<String, dynamic> toQueryParameters() {
    return {
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

  AutoCreditFilter copyWith({
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
    bool resetRate = false,
    bool resetTerm = false,
    bool resetAmount = false,
    bool resetSort = false,
    bool resetDirection = false,
  }) {
    return AutoCreditFilter(
      bank: resetBank ? null : (bank ?? this.bank),
      rateFrom: resetRate ? null : (rateFrom ?? this.rateFrom),
      termMonthsFrom: resetTerm ? null : (termMonthsFrom ?? this.termMonthsFrom),
      amountFrom: resetAmount ? null : (amountFrom ?? this.amountFrom),
      opening: resetOpening ? null : (opening ?? this.opening),
      search: resetSearch ? null : (search ?? this.search),
      sort: resetSort ? null : (sort ?? this.sort),
      direction: resetDirection ? null : (direction ?? this.direction),
    );
  }

  bool get hasActiveFilters =>
      rateFrom != null ||
      termMonthsFrom != null ||
      amountFrom != null ||
      (opening != null && opening!.isNotEmpty) ||
      (search != null && search!.isNotEmpty) ||
      (sort != null && sort!.isNotEmpty) ||
      (direction != null && direction!.isNotEmpty);
}


