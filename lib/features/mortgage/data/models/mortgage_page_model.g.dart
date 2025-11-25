// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mortgage_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MortgagePageModel _$MortgagePageModelFromJson(Map<String, dynamic> json) =>
    MortgagePageModel(
      content: (json['content'] as List<dynamic>)
          .map((e) => MortgageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages:
          json['total_pages'] == null ? 0 : _intFromJson(json['total_pages']),
      totalElements: json['total_elements'] == null
          ? 0
          : _intFromJson(json['total_elements']),
      number: json['number'] == null ? 0 : _intFromJson(json['number']),
      size: json['size'] == null ? 10 : _intFromJson(json['size']),
      first: json['first'] == null ? true : _boolFromJson(json['first']),
      last: json['last'] == null ? false : _boolFromJson(json['last']),
      numberOfElements: json['number_of_elements'] == null
          ? 0
          : _intFromJson(json['number_of_elements']),
    );

Map<String, dynamic> _$MortgagePageModelToJson(MortgagePageModel instance) =>
    <String, dynamic>{
      'content': instance.content.map((e) => e.toJson()).toList(),
      'total_pages': instance.totalPages,
      'total_elements': instance.totalElements,
      'number': instance.number,
      'size': instance.size,
      'first': instance.first,
      'last': instance.last,
      'number_of_elements': instance.numberOfElements,
    };
