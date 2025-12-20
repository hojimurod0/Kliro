import 'package:equatable/equatable.dart';

import 'car_entity.dart';

class CarPage extends Equatable {
  const CarPage({
    required this.items,
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.numberOfElements,
  });

  final List<CarEntity> items;
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final int numberOfElements;

  @override
  List<Object?> get props => [
        items,
        totalPages,
        totalElements,
        pageNumber,
        pageSize,
        isFirst,
        isLast,
        numberOfElements,
      ];
}

