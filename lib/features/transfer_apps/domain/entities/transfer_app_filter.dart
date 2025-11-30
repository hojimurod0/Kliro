class TransferAppFilter {
  const TransferAppFilter({
    this.search,
    this.app,
    this.commissionFrom,
    this.commissionTo,
    this.sort,
    this.direction,
    this.speed,
    this.transferMethod,
    this.page = 0,
    this.size = 20,
  });

  final String? search;
  final String? app;
  final double? commissionFrom;
  final double? commissionTo;
  final String? sort;
  final String? direction;
  final String? speed;
  final String? transferMethod;
  final int page;
  final int size;

  static const TransferAppFilter empty = TransferAppFilter();

  Map<String, dynamic> toQueryParameters() => <String, dynamic>{
        'page': page,
        'size': size,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (app != null && app!.isNotEmpty) 'app': app,
        if (commissionFrom != null) 'commission_from': commissionFrom,
        if (commissionTo != null) 'commission_to': commissionTo,
      };

  TransferAppFilter copyWith({
    String? search,
    String? app,
    double? commissionFrom,
    double? commissionTo,
    String? sort,
    String? direction,
    String? speed,
    String? transferMethod,
    int? page,
    int? size,
    bool resetSearch = false,
    bool resetApp = false,
    bool resetCommission = false,
    bool resetCommissionTo = false,
    bool resetSort = false,
    bool resetDirection = false,
    bool resetSpeed = false,
    bool resetTransferMethod = false,
  }) {
    return TransferAppFilter(
      search: resetSearch ? null : (search ?? this.search),
      app: resetApp ? null : (app ?? this.app),
      commissionFrom:
          resetCommission ? null : (commissionFrom ?? this.commissionFrom),
      commissionTo:
          resetCommissionTo ? null : (commissionTo ?? this.commissionTo),
      sort: resetSort ? null : (sort ?? this.sort),
      direction: resetDirection ? null : (direction ?? this.direction),
      speed: resetSpeed ? null : (speed ?? this.speed),
      transferMethod: resetTransferMethod
          ? null
          : (transferMethod ?? this.transferMethod),
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  bool get hasActiveFilters =>
      (search != null && search!.isNotEmpty) ||
      (app != null && app!.isNotEmpty) ||
      commissionFrom != null ||
      commissionTo != null ||
      sort != null ||
      direction != null ||
      (speed != null && speed!.isNotEmpty) ||
      (transferMethod != null && transferMethod!.isNotEmpty);
}


