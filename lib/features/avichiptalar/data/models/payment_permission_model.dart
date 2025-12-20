import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_permission_model.g.dart';

@JsonSerializable()
class PaymentPermissionModel extends Equatable {
  final bool? allowed;
  final String? reason;
  @JsonKey(name: 'can_pay')
  final bool? canPay;
  @JsonKey(name: 'payment_allowed')
  final bool? paymentAllowed;

  const PaymentPermissionModel({
    this.allowed,
    this.reason,
    this.canPay,
    this.paymentAllowed,
  });

  factory PaymentPermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPermissionModelToJson(this);

  PaymentPermissionModel copyWith({
    bool? allowed,
    String? reason,
    bool? canPay,
    bool? paymentAllowed,
  }) {
    return PaymentPermissionModel(
      allowed: allowed ?? this.allowed,
      reason: reason ?? this.reason,
      canPay: canPay ?? this.canPay,
      paymentAllowed: paymentAllowed ?? this.paymentAllowed,
    );
  }

  @override
  List<Object?> get props => [allowed, reason, canPay, paymentAllowed];
}




