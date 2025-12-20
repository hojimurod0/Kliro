import 'package:equatable/equatable.dart';

import 'avichipta.dart';

class AvichiptaSearchResult extends Equatable {
  const AvichiptaSearchResult({
    required this.flights,
    this.totalCount,
    this.minPrice,
    this.maxPrice,
  });

  final List<Avichipta> flights;
  final int? totalCount;
  final double? minPrice;
  final double? maxPrice;

  @override
  List<Object?> get props => [flights, totalCount, minPrice, maxPrice];
}

