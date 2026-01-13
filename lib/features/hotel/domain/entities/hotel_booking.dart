import 'package:equatable/equatable.dart';
import 'hotel.dart';

/// Hotel Booking Entity
class HotelBooking extends Equatable {
  const HotelBooking({
    required this.bookingId,
    required this.status,
    this.confirmationNumber,
    this.hotelConfirmationNumber,
    this.voucherUrl,
    this.checkInInstructions,
    this.paymentDeadline,
    this.totalAmount,
    this.currency,
    this.paymentStatus,
    this.paymentUrl,
    this.cancellationPolicy,
    this.hotelInfo,
    this.roomInfo,
    this.guestInfo,
    this.dates,
  });

  final String bookingId;
  final String status; // pending_payment, confirmed, cancelled
  final String? confirmationNumber;
  final String? hotelConfirmationNumber;
  final String? voucherUrl;
  final String? checkInInstructions;
  final DateTime? paymentDeadline;
  final double? totalAmount;
  final String? currency;
  final String? paymentStatus;
  final String? paymentUrl; // Payment URL for redirecting to payment gateway
  final Map<String, dynamic>? cancellationPolicy;
  final Map<String, dynamic>? hotelInfo;
  final Map<String, dynamic>? roomInfo;
  final Map<String, dynamic>? guestInfo;
  final Map<String, dynamic>? dates;

  @override
  List<Object?> get props => [
        bookingId,
        status,
        confirmationNumber,
        hotelConfirmationNumber,
        voucherUrl,
        checkInInstructions,
        paymentDeadline,
        totalAmount,
        currency,
        paymentStatus,
        paymentUrl,
        cancellationPolicy,
        hotelInfo,
        roomInfo,
        guestInfo,
        dates,
      ];
}

/// Quote Entity - актуальные цены
class HotelQuote extends Equatable {
  const HotelQuote({
    required this.quoteId,
    required this.hotel,
  });

  final String quoteId;
  final Hotel hotel; // Hotel with updated prices

  @override
  List<Object?> get props => [quoteId, hotel];
}

/// Booking Guest Info
class BookingGuest extends Equatable {
  const BookingGuest({
    required this.personTitle, // MR, MRS, MS
    required this.firstName,
    required this.lastName,
    required this.nationality,
    this.age,
  });

  final String personTitle;
  final String firstName;
  final String lastName;
  final String nationality; // uz, us, ru
  final int? age;

  @override
  List<Object?> get props => [personTitle, firstName, lastName, nationality, age];
}

/// Booking Room Info
class BookingRoom extends Equatable {
  const BookingRoom({
    required this.optionRefId,
    required this.guests,
    required this.price,
  });

  final String optionRefId;
  final List<BookingGuest> guests;
  final double price;

  @override
  List<Object?> get props => [optionRefId, guests, price];
}

/// Create Booking Request
class CreateHotelBookingRequest extends Equatable {
  const CreateHotelBookingRequest({
    required this.quoteId,
    required this.externalId,
    required this.bookingRooms,
    this.comment,
    this.deltaPrice,
  });

  final String quoteId;
  final String externalId; // Unique internal booking ID
  final List<BookingRoom> bookingRooms;
  final String? comment;
  final DeltaPrice? deltaPrice;

  @override
  List<Object?> get props => [quoteId, externalId, bookingRooms, comment, deltaPrice];
}

/// Delta Price - допустимое отклонение цены
class DeltaPrice extends Equatable {
  const DeltaPrice({
    this.amount,
    this.percent,
    this.matches = 'ALL', // ALL or ANY
  });

  final double? amount;
  final double? percent;
  final String matches;

  @override
  List<Object?> get props => [amount, percent, matches];
}

/// Payment Info
class PaymentInfo extends Equatable {
  const PaymentInfo({
    required this.paymentMethod,
    this.cardNumber,
    this.transactionId,
  });

  final String paymentMethod; // card, cash, etc.
  final String? cardNumber;
  final String? transactionId;

  @override
  List<Object?> get props => [paymentMethod, cardNumber, transactionId];
}

