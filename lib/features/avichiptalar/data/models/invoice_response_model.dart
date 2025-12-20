import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';

class InvoiceResponseModel extends Equatable {
  final String uuid;
  final String checkoutUrl;

  const InvoiceResponseModel({
    required this.uuid,
    required this.checkoutUrl,
  });

  factory InvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    // API returns { "data": { "uuid": "...", "checkout_url": "..." } }
    // Or sometimes just { "uuid": "...", "checkout_url": "..." } if data is unwrapped
    
    // Check if json has 'data' key
    final data = json.containsKey('data') ? json['data'] : json;
    
    return InvoiceResponseModel(
      uuid: data['uuid'] ?? '',
      checkoutUrl: data['checkout_url'] ?? '',
    );
  }

  Invoice toEntity() {
    return Invoice(
      uuid: uuid,
      checkoutUrl: checkoutUrl,
    );
  }

  @override
  List<Object?> get props => [uuid, checkoutUrl];
}
