class MortgageFilter {
  const MortgageFilter({
    this.bank,
    this.interestRateFrom,
    this.interestRateTo,
    this.termMonthsFrom,
    this.termMonthsTo,
    this.maxSumFrom,
    this.maxSumTo,
    this.downPaymentFrom,
    this.search,
    this.sort,
    this.direction,
    this.opening,
    this.propertyType,
  });

  final String? bank;
  final double? interestRateFrom;
  final double? interestRateTo;
  final int? termMonthsFrom;
  final int? termMonthsTo;
  final double? maxSumFrom;
  final double? maxSumTo;
  final double? downPaymentFrom;
  final String? search;
  final String? sort;
  final String? direction;
  final String? opening;
  final String? propertyType;

  static const MortgageFilter empty = MortgageFilter();

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (bank != null && bank!.isNotEmpty) 'bank': bank,
      if (interestRateFrom != null) 'interest_rate_from': interestRateFrom,
      if (interestRateTo != null) 'interest_rate_to': interestRateTo,
      if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
      if (termMonthsTo != null) 'term_months_to': termMonthsTo,
      if (maxSumFrom != null) 'max_sum_from': maxSumFrom,
      if (maxSumTo != null) 'max_sum_to': maxSumTo,
      if (downPaymentFrom != null) 'down_payment_from': downPaymentFrom,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (sort != null && sort!.isNotEmpty) 'sort': sort,
      if (direction != null && direction!.isNotEmpty) 'direction': direction,
      if (opening != null && opening!.isNotEmpty) 'opening': opening,
      if (propertyType != null && propertyType!.isNotEmpty)
        'property_type': propertyType,
    };
  }

  MortgageFilter copyWith({
    String? bank,
    double? interestRateFrom,
    double? interestRateTo,
    int? termMonthsFrom,
    int? termMonthsTo,
    double? maxSumFrom,
    double? maxSumTo,
    double? downPaymentFrom,
    String? search,
    String? sort,
    String? direction,
    String? opening,
    String? propertyType,
    bool resetBank = false,
    bool resetSearch = false,
    bool resetSort = false,
    bool resetDirection = false,
    bool resetInterestRate = false,
    bool resetInterestRateTo = false,
    bool resetTerm = false,
    bool resetTermTo = false,
    bool resetMaxSum = false,
    bool resetMaxSumTo = false,
    bool resetDownPayment = false,
    bool resetOpening = false,
    bool resetPropertyType = false,
  }) {
    return MortgageFilter(
      bank: resetBank ? null : (bank ?? this.bank),
      interestRateFrom:
          resetInterestRate ? null : (interestRateFrom ?? this.interestRateFrom),
      interestRateTo:
          resetInterestRateTo ? null : (interestRateTo ?? this.interestRateTo),
      termMonthsFrom: resetTerm ? null : (termMonthsFrom ?? this.termMonthsFrom),
      termMonthsTo: resetTermTo ? null : (termMonthsTo ?? this.termMonthsTo),
      maxSumFrom: resetMaxSum ? null : (maxSumFrom ?? this.maxSumFrom),
      maxSumTo: resetMaxSumTo ? null : (maxSumTo ?? this.maxSumTo),
      downPaymentFrom:
          resetDownPayment ? null : (downPaymentFrom ?? this.downPaymentFrom),
      search: resetSearch ? null : (search ?? this.search),
      sort: resetSort ? null : (sort ?? this.sort),
      direction: resetDirection ? null : (direction ?? this.direction),
      opening: resetOpening ? null : (opening ?? this.opening),
      propertyType:
          resetPropertyType ? null : (propertyType ?? this.propertyType),
    );
  }

  bool get hasActiveFilters =>
      bank != null ||
      interestRateFrom != null ||
      interestRateTo != null ||
      termMonthsFrom != null ||
      termMonthsTo != null ||
      maxSumFrom != null ||
      maxSumTo != null ||
      downPaymentFrom != null ||
      opening != null ||
      propertyType != null ||
      search != null ||
      sort != null ||
      direction != null;
}

Map<String, dynamic> mortgageFilterToMap(MortgageFilter filter) {
  return <String, dynamic>{
    'bank': filter.bank,
    'interestRateFrom': filter.interestRateFrom,
    'interestRateTo': filter.interestRateTo,
    'termMonthsFrom': filter.termMonthsFrom,
    'termMonthsTo': filter.termMonthsTo,
    'maxSumFrom': filter.maxSumFrom,
    'maxSumTo': filter.maxSumTo,
    'downPaymentFrom': filter.downPaymentFrom,
    'search': filter.search,
    'sort': filter.sort,
    'direction': filter.direction,
    'opening': filter.opening,
    'propertyType': filter.propertyType,
  };
}

MortgageFilter mortgageFilterFromMap(Map<String, dynamic> map) {
  double? _toDouble(dynamic value) =>
      value == null ? null : (value as num).toDouble();
  int? _toInt(dynamic value) => value == null ? null : (value as num).toInt();

  return MortgageFilter(
    bank: map['bank'] as String?,
    interestRateFrom: _toDouble(map['interestRateFrom']),
    interestRateTo: _toDouble(map['interestRateTo']),
    termMonthsFrom: _toInt(map['termMonthsFrom']),
    termMonthsTo: _toInt(map['termMonthsTo']),
    maxSumFrom: _toDouble(map['maxSumFrom']),
    maxSumTo: _toDouble(map['maxSumTo']),
    downPaymentFrom: _toDouble(map['downPaymentFrom']),
    search: map['search'] as String?,
    sort: map['sort'] as String?,
    direction: map['direction'] as String?,
    opening: map['opening'] as String?,
    propertyType: map['propertyType'] as String?,
  );
}

