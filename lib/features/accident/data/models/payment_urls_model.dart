import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment_urls_model.g.dart';

@JsonSerializable()
class PaymentUrlsModel extends Equatable {
  final String click;
  final String payme;

  const PaymentUrlsModel({
    required this.click,
    required this.payme,
  });

  factory PaymentUrlsModel.fromJson(Map<String, dynamic> json) {
    // Null safety: click va payme ni tekshirish
    final clickValue = json['click'];
    if (clickValue == null) {
      throw FormatException('click is null in PaymentUrlsModel');
    }
    
    final paymeValue = json['payme'];
    if (paymeValue == null) {
      throw FormatException('payme is null in PaymentUrlsModel');
    }
    
    return _$PaymentUrlsModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PaymentUrlsModelToJson(this);

  @override
  List<Object?> get props => [click, payme];
}

