class SearchResultItem {
  const SearchResultItem({
    required this.category,
    required this.name,
    this.bank,
    this.meta,
  });

  final String category;
  final String name;
  final String? bank;
  final Map<String, dynamic>? meta;

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      SearchResultItem(
        category: json['category'] as String? ?? '',
        name: json['name'] as String? ?? '',
        bank: json['bank'] as String?,
        meta: json['meta'] is Map<String, dynamic>
            ? json['meta'] as Map<String, dynamic>
            : null,
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'name': name,
        'bank': bank,
        'meta': meta,
      };
}

