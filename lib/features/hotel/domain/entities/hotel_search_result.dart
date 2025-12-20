import 'package:equatable/equatable.dart';
import 'hotel.dart';

class HotelSearchResult extends Equatable {
  const HotelSearchResult({
    required this.hotels,
    this.total = 0,
    this.page = 1,
    this.pageSize = 10,
  });

  final List<Hotel> hotels;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => (page * pageSize) < total;

  HotelSearchResult copyWith({
    List<Hotel>? hotels,
    int? total,
    int? page,
    int? pageSize,
  }) {
    return HotelSearchResult(
      hotels: hotels ?? this.hotels,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [hotels, total, page, pageSize];
}

