import '../../domain/entities/avichipta_filter.dart';

class SearchRequestModel {
  const SearchRequestModel({
    this.fromCity,
    this.toCity,
    this.departureDate,
    this.returnDate,
    this.passengers = 1,
    this.maxPrice,
    this.airline,
    this.sortBy,
    this.sortDirection,
  });

  final String? fromCity;
  final String? toCity;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int passengers;
  final double? maxPrice;
  final String? airline;
  final String? sortBy;
  final String? sortDirection;

  factory SearchRequestModel.fromFilter(AvichiptaFilter filter) {
    return SearchRequestModel(
      fromCity: filter.fromCity,
      toCity: filter.toCity,
      departureDate: filter.departureDate,
      returnDate: filter.returnDate,
      passengers: filter.passengers,
      maxPrice: filter.maxPrice,
      airline: filter.airlines?.isNotEmpty == true ? filter.airlines!.first : null,
      sortBy: filter.sortBy,
      sortDirection: filter.sortDirection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fromCity != null) 'from_city': fromCity,
      if (toCity != null) 'to_city': toCity,
      if (departureDate != null) 'departure_date': departureDate!.toIso8601String(),
      if (returnDate != null) 'return_date': returnDate!.toIso8601String(),
      'passengers': passengers,
      if (maxPrice != null) 'max_price': maxPrice,
      if (airline != null) 'airline': airline,
      if (sortBy != null) 'sort_by': sortBy,
      if (sortDirection != null) 'sort_direction': sortDirection,
    };
  }
}

