class PaginationFilter {
  const PaginationFilter({
    required this.page,
    required this.size,
  });

  final int page;
  final int size;

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'size': size,
    };
  }
}

