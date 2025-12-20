import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'balance_response_model.g.dart';

@JsonSerializable()
class BalanceResponseModel extends Equatable {
  final double? balance;
  final String? currency;

  const BalanceResponseModel({this.balance, this.currency});

  factory BalanceResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceResponseModelToJson(this);

  BalanceResponseModel copyWith({double? balance, String? currency}) {
    return BalanceResponseModel(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [balance, currency];
}
