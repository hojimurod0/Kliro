class MortgageFilter {
  const MortgageFilter({
    this.bank,
    this.interestRateFrom,
    this.termMonthsFrom,
    this.maxSumFrom,
    this.downPaymentFrom,
    this.search,
    this.sort,
    this.direction,
  });

  final String? bank;
  final double? interestRateFrom;
  final int? termMonthsFrom;
  final double? maxSumFrom;
  final double? downPaymentFrom;
  final String? search;
  final String? sort;
  final String? direction;

  static const MortgageFilter empty = MortgageFilter();

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (bank != null && bank!.isNotEmpty) 'bank': bank,
      if (interestRateFrom != null) 'interest_rate_from': interestRateFrom,
      if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
      if (maxSumFrom != null) 'max_sum_from': maxSumFrom,
      if (downPaymentFrom != null) 'down_payment_from': downPaymentFrom,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      if (direction != null && direction!.isNotEmpty) 'direction': direction,
    };
  }

  MortgageFilter copyWith({
    String? bank,
    double? interestRateFrom,
    int? termMonthsFrom,
    double? maxSumFrom,
    double? downPaymentFrom,
    String? search,
    String? sort,
    String? direction,
    bool resetBank = false,
    bool resetSearch = false,
    bool resetSort = false,
    bool resetDirection = false,
  }) {
    return MortgageFilter(
      bank: resetBank ? null : (bank ?? this.bank),
      interestRateFrom: interestRateFrom ?? this.interestRateFrom,
      termMonthsFrom: termMonthsFrom ?? this.termMonthsFrom,
      maxSumFrom: maxSumFrom ?? this.maxSumFrom,
      downPaymentFrom: downPaymentFrom ?? this.downPaymentFrom,
      search: resetSearch ? null : (search ?? this.search),
      sort: resetSort ? null : (sort ?? this.sort),
      direction: resetDirection ? null : (direction ?? this.direction),
    );
  }

  bool get hasActiveFilters =>
      bank != null ||
      interestRateFrom != null ||
      termMonthsFrom != null ||
      maxSumFrom != null ||
      downPaymentFrom != null ||
      search != null ||
      sort != null ||
      direction != null;
}

