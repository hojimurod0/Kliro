import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/hotel_booking.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class HotelBookingModel extends HotelBooking {
  const HotelBookingModel({
    required super.bookingId,
    required super.status,
    super.confirmationNumber,
    super.hotelConfirmationNumber,
    super.voucherUrl,
    super.checkInInstructions,
    super.paymentDeadline,
    super.totalAmount,
    super.currency,
    super.paymentStatus,
    super.cancellationPolicy,
    super.hotelInfo,
    super.roomInfo,
    super.guestInfo,
    super.dates,
  });

  factory HotelBookingModel.fromJson(Map<String, dynamic> json) =>
      _$HotelBookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelBookingModelToJson(this);
}

@JsonSerializable()
class CreateBookingRequestModel {
  const CreateBookingRequestModel({
    required this.quoteId,
    required this.externalId,
    required this.bookingRooms,
    this.comment,
    this.deltaPrice,
  });

  final String quoteId;
  final String externalId;
  final List<BookingRoomModel> bookingRooms;
  final String? comment;
  final DeltaPriceModel? deltaPrice;

  factory CreateBookingRequestModel.fromEntity(
      CreateHotelBookingRequest request) {
    return CreateBookingRequestModel(
      quoteId: request.quoteId,
      externalId: request.externalId,
      bookingRooms: request.bookingRooms
          .map((room) => BookingRoomModel.fromEntity(room))
          .toList(),
      comment: request.comment,
      deltaPrice: request.deltaPrice != null
          ? DeltaPriceModel.fromEntity(request.deltaPrice!)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$CreateBookingRequestModelToJson(this);
}

@JsonSerializable()
class BookingRoomModel {
  const BookingRoomModel({
    required this.optionRefId,
    required this.guests,
    required this.price,
  });

  final String optionRefId;
  final List<BookingGuestModel> guests;
  final double price;

  factory BookingRoomModel.fromJson(Map<String, dynamic> json) =>
      _$BookingRoomModelFromJson(json);

  factory BookingRoomModel.fromEntity(BookingRoom room) {
    return BookingRoomModel(
      optionRefId: room.optionRefId,
      guests: room.guests
          .map((guest) => BookingGuestModel.fromEntity(guest))
          .toList(),
      price: room.price,
    );
  }

  Map<String, dynamic> toJson() => _$BookingRoomModelToJson(this);
}

@JsonSerializable()
class BookingGuestModel {
  const BookingGuestModel({
    required this.personTitle,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    this.age,
  });

  final String personTitle;
  final String firstName;
  final String lastName;
  final String nationality;
  final int? age;

  factory BookingGuestModel.fromJson(Map<String, dynamic> json) =>
      _$BookingGuestModelFromJson(json);

  factory BookingGuestModel.fromEntity(BookingGuest guest) {
    return BookingGuestModel(
      personTitle: guest.personTitle,
      firstName: guest.firstName,
      lastName: guest.lastName,
      nationality: guest.nationality,
      age: guest.age,
    );
  }

  Map<String, dynamic> toJson() => _$BookingGuestModelToJson(this);
}

@JsonSerializable()
class DeltaPriceModel {
  const DeltaPriceModel({
    this.amount,
    this.percent,
    this.matches = 'ALL',
  });

  final double? amount;
  final double? percent;
  final String matches;

  factory DeltaPriceModel.fromJson(Map<String, dynamic> json) =>
      _$DeltaPriceModelFromJson(json);

  factory DeltaPriceModel.fromEntity(DeltaPrice deltaPrice) {
    return DeltaPriceModel(
      amount: deltaPrice.amount,
      percent: deltaPrice.percent,
      matches: deltaPrice.matches,
    );
  }

  Map<String, dynamic> toJson() => _$DeltaPriceModelToJson(this);
}
