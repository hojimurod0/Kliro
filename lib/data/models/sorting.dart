enum SortDirection { asc, desc }

class Sorting {
  const Sorting({
    required this.field,
    this.direction = SortDirection.asc,
  });

  final String field;
  final SortDirection direction;

  Map<String, dynamic> toQuery() => {
        'sort': field,
        'direction': direction.name,
      };
}

