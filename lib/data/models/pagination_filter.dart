class PaginationFilter {
  const PaginationFilter({
    this.page,
    this.size,
  });

  final int? page;
  final int? size;

  Map<String, dynamic> toQuery() => {
        if (page != null) 'page': page,
        if (size != null) 'size': size,
      };
}

