import 'package:equatable/equatable.dart';

class PaymentPermissionModel extends Equatable {
  final bool? paymentAllowed;

  const PaymentPermissionModel({
    this.paymentAllowed,
  });

  factory PaymentPermissionModel.fromJson(Map<String, dynamic> json) {
    return PaymentPermissionModel(
      paymentAllowed: json['payment_allowed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'payment_allowed': paymentAllowed,
      };

  PaymentPermissionModel copyWith({
    bool? paymentAllowed,
  }) {
    return PaymentPermissionModel(
      paymentAllowed: paymentAllowed ?? this.paymentAllowed,
    );
  }

  @override
  List<Object?> get props => [paymentAllowed];
}




