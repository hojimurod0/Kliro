import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'booking_model.dart';

part 'cancel_response_model.g.dart';

@JsonSerializable()
class CancelResponseModel extends Equatable {
  final String? status;
  final String? message;
  final BookingModel? booking;

  const CancelResponseModel({
    this.status,
    this.message,
    this.booking,
  });

  factory CancelResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CancelResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CancelResponseModelToJson(this);

  CancelResponseModel copyWith({
    String? status,
    String? message,
    BookingModel? booking,
  }) {
    return CancelResponseModel(
      status: status ?? this.status,
      message: message ?? this.message,
      booking: booking ?? this.booking,
    );
  }

  @override
  List<Object?> get props => [status, message, booking];
}




