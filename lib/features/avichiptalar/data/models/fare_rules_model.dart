import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fare_rules_model.g.dart';

@JsonSerializable()
class FareRulesModel extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final List<RuleItemModel>? rules;

  const FareRulesModel({
    this.id,
    this.title,
    this.description,
    this.rules,
  });

  factory FareRulesModel.fromJson(Map<String, dynamic> json) =>
      _$FareRulesModelFromJson(json);

  Map<String, dynamic> toJson() => _$FareRulesModelToJson(this);

  FareRulesModel copyWith({
    String? id,
    String? title,
    String? description,
    List<RuleItemModel>? rules,
  }) {
    return FareRulesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rules: rules ?? this.rules,
    );
  }

  @override
  List<Object?> get props => [id, title, description, rules];
}

@JsonSerializable()
class RuleItemModel extends Equatable {
  final String? type;
  final String? description;
  final bool? allowed;

  const RuleItemModel({
    this.type,
    this.description,
    this.allowed,
  });

  factory RuleItemModel.fromJson(Map<String, dynamic> json) =>
      _$RuleItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$RuleItemModelToJson(this);

  RuleItemModel copyWith({
    String? type,
    String? description,
    bool? allowed,
  }) {
    return RuleItemModel(
      type: type ?? this.type,
      description: description ?? this.description,
      allowed: allowed ?? this.allowed,
    );
  }

  @override
  List<Object?> get props => [type, description, allowed];
}




