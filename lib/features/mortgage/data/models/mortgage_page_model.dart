import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/mortgage_page.dart';
import 'mortgage_model.dart';

part 'mortgage_page_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MortgagePageModel {
  MortgagePageModel({
    required this.content,
    this.totalPages = 0,
    this.totalElements = 0,
    this.number = 0,
    this.size = 10,
    this.first = true,
    this.last = false,
    this.numberOfElements = 0,
  });

  final List<MortgageModel> content;

  @JsonKey(name: 'total_pages', fromJson: _intFromJson)
  final int totalPages;

  @JsonKey(name: 'total_elements', fromJson: _intFromJson)
  final int totalElements;

  @JsonKey(fromJson: _intFromJson)
  final int number;
  
  @JsonKey(fromJson: _intFromJson)
  final int size;
  
  @JsonKey(fromJson: _boolFromJson)
  final bool first;
  
  @JsonKey(fromJson: _boolFromJson)
  final bool last;

  @JsonKey(name: 'number_of_elements', fromJson: _intFromJson)
  final int numberOfElements;

  factory MortgagePageModel.fromJson(Map<String, dynamic> json) =>
      _$MortgagePageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MortgagePageModelToJson(this);
}

extension MortgagePageModelX on MortgagePageModel {
  MortgagePage toEntity() => MortgagePage(
        items: content.map((item) => item.toEntity()).toList(),
        totalPages: totalPages,
        totalElements: totalElements,
        pageNumber: number,
        pageSize: size,
        isFirst: first,
        isLast: last,
        numberOfElements: numberOfElements,
      );
}

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

bool _boolFromJson(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  return false;
}

