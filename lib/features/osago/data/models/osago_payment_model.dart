import '../../domain/entities/osago_payment.dart';

class OsagoPaymentModel extends OsagoPayment {
  const OsagoPaymentModel({
    required super.orderId,
    required super.amount,
    required super.paymentType,
    super.paymentId,
    super.status,
  });

  factory OsagoPaymentModel.fromJson(Map<String, dynamic> json) {
    return OsagoPaymentModel(
      orderId: json['orderId'] as String,
      amount: json['amount'] as String,
      paymentType: json['paymentType'] as String,
      paymentId: json['paymentId'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'paymentType': paymentType,
      if (paymentId != null) 'paymentId': paymentId,
      if (status != null) 'status': status,
    };
  }
}

