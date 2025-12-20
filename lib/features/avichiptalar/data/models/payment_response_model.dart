import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'booking_model.dart';

part 'payment_response_model.g.dart';

@JsonSerializable()
class PaymentResponseModel extends Equatable {
  final String? status;
  final String? transactionId;
  final String? message;
  final BookingModel? booking;

  const PaymentResponseModel({
    this.status,
    this.transactionId,
    this.message,
    this.booking,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseModelToJson(this);

  PaymentResponseModel copyWith({
    String? status,
    String? transactionId,
    String? message,
    BookingModel? booking,
  }) {
    return PaymentResponseModel(
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      message: message ?? this.message,
      booking: booking ?? this.booking,
    );
  }

  @override
  List<Object?> get props => [status, transactionId, message, booking];
}




