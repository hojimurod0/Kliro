import 'package:equatable/equatable.dart';

class InvoiceRequestModel extends Equatable {
  final num amount;
  final String invoiceId;
  final String lang;
  final String returnUrl;
  final String callbackUrl;

  const InvoiceRequestModel({
    required this.amount,
    required this.invoiceId,
    required this.lang,
    required this.returnUrl,
    required this.callbackUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'invoice_id': invoiceId,
      'lang': lang,
      'return_url': returnUrl,
      'callback_url': callbackUrl,
    };
  }

  @override
  List<Object?> get props => [amount, invoiceId, lang, returnUrl, callbackUrl];
}
