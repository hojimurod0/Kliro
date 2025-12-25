import '../../domain/entities/hotel_booking.dart';

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

  factory HotelBookingModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return HotelBookingModel(
      bookingId: data['booking_id'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      confirmationNumber: data['confirmation_number'] as String?,
      hotelConfirmationNumber: data['hotel_confirmation_number'] as String?,
      voucherUrl: data['voucher_url'] as String?,
      checkInInstructions: data['check_in_instructions'] as String?,
      paymentDeadline: data['payment_deadline'] != null
          ? DateTime.parse(data['payment_deadline'] as String)
          : null,
      totalAmount: (data['total_amount'] as num?)?.toDouble(),
      currency: data['currency'] as String?,
      paymentStatus: data['payment_status'] as String?,
      cancellationPolicy: data['cancellation_policy'] as Map<String, dynamic>?,
      hotelInfo: data['hotel_info'] as Map<String, dynamic>?,
      roomInfo: data['room_info'] as Map<String, dynamic>?,
      guestInfo: data['guest_info'] as Map<String, dynamic>?,
      dates: data['dates'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'status': status,
      if (confirmationNumber != null) 'confirmation_number': confirmationNumber,
      if (hotelConfirmationNumber != null) 'hotel_confirmation_number': hotelConfirmationNumber,
      if (voucherUrl != null) 'voucher_url': voucherUrl,
      if (checkInInstructions != null) 'check_in_instructions': checkInInstructions,
      if (paymentDeadline != null) 'payment_deadline': paymentDeadline!.toIso8601String(),
      if (totalAmount != null) 'total_amount': totalAmount,
      if (currency != null) 'currency': currency,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (cancellationPolicy != null) 'cancellation_policy': cancellationPolicy,
      if (hotelInfo != null) 'hotel_info': hotelInfo,
      if (roomInfo != null) 'room_info': roomInfo,
      if (guestInfo != null) 'guest_info': guestInfo,
      if (dates != null) 'dates': dates,
    };
  }
}

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

  factory CreateBookingRequestModel.fromEntity(CreateHotelBookingRequest request) {
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

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'quote_id': quoteId,
        'external_id': externalId,
        'booking_rooms': bookingRooms.map((room) => room.toJson()).toList(),
        if (comment != null) 'comment': comment,
        if (deltaPrice != null) 'deltaPrice': deltaPrice!.toJson(),
      },
    };
  }
}

class BookingRoomModel {
  const BookingRoomModel({
    required this.optionRefId,
    required this.guests,
    required this.price,
  });

  final String optionRefId;
  final List<BookingGuestModel> guests;
  final double price;

  factory BookingRoomModel.fromEntity(BookingRoom room) {
    return BookingRoomModel(
      optionRefId: room.optionRefId,
      guests: room.guests
          .map((guest) => BookingGuestModel.fromEntity(guest))
          .toList(),
      price: room.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_ref_id': optionRefId,
      'guests': guests.map((guest) => guest.toJson()).toList(),
      'price': price,
    };
  }
}

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

  factory BookingGuestModel.fromEntity(BookingGuest guest) {
    return BookingGuestModel(
      personTitle: guest.personTitle,
      firstName: guest.firstName,
      lastName: guest.lastName,
      nationality: guest.nationality,
      age: guest.age,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person_title': personTitle,
      'first_name': firstName,
      'last_name': lastName,
      'nationality': nationality,
      if (age != null) 'age': age,
    };
  }
}

class DeltaPriceModel {
  const DeltaPriceModel({
    this.amount,
    this.percent,
    this.matches = 'ALL',
  });

  final double? amount;
  final double? percent;
  final String matches;

  factory DeltaPriceModel.fromEntity(DeltaPrice deltaPrice) {
    return DeltaPriceModel(
      amount: deltaPrice.amount,
      percent: deltaPrice.percent,
      matches: deltaPrice.matches,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (amount != null) 'amount': amount,
      if (percent != null) 'percent': percent,
      'matches': matches,
    };
  }
}

