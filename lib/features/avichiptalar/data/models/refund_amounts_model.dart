import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refund_amounts_model.g.dart';

@JsonSerializable()
class RefundAmountsModel extends Equatable {
  @JsonKey(name: 'refund_amount')
  final String? refundAmount;
  @JsonKey(name: 'penalty_amount')
  final String? penaltyAmount;
  final String? currency;
  @JsonKey(name: 'total_refund')
  final String? totalRefund;

  const RefundAmountsModel({
    this.refundAmount,
    this.penaltyAmount,
    this.currency,
    this.totalRefund,
  });

  factory RefundAmountsModel.fromJson(Map<String, dynamic> json) =>
      _$RefundAmountsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RefundAmountsModelToJson(this);

  RefundAmountsModel copyWith({
    String? refundAmount,
    String? penaltyAmount,
    String? currency,
    String? totalRefund,
  }) {
    return RefundAmountsModel(
      refundAmount: refundAmount ?? this.refundAmount,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      currency: currency ?? this.currency,
      totalRefund: totalRefund ?? this.totalRefund,
    );
  }

  @override
  List<Object?> get props =>
      [refundAmount, penaltyAmount, currency, totalRefund];
}




