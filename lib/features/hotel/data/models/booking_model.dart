import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    super.paymentUrl,
    super.cancellationPolicy,
    super.hotelInfo,
    super.roomInfo,
    super.guestInfo,
    super.dates,
  });

  factory HotelBookingModel.fromJson(Map<String, dynamic> json) {
    try {
      // API response format: {"data": {...}} yoki to'g'ridan-to'g'ri data
      // Handle different response formats
      Map<String, dynamic> data = json;
      
      // Check if response has 'data' wrapper
      if (json.containsKey('data')) {
        if (json['data'] is Map) {
          data = json['data'] as Map<String, dynamic>;
        } else if (json['data'] is String) {
          // If data is a string, try to parse it
          try {
            final parsed = jsonDecode(json['data'] as String) as Map<String, dynamic>;
            data = parsed;
          } catch (_) {
            // If parsing fails, use original json
            data = json;
          }
        }
      }
      
      // Ensure data is a Map (data is already Map<String, dynamic> from above)
      // No need to check again

      // Convert snake_case to camelCase for generated code
      final normalizedJson = <String, dynamic>{};
      
      // booking_id -> bookingId
      normalizedJson['bookingId'] = data['booking_id'] ?? 
                                    data['bookingId'] ?? 
                                    data['id'] ?? 
                                    '';
      
      // status
      normalizedJson['status'] = data['status'] ?? 'pending_payment';
      
      // confirmation_number -> confirmationNumber
      normalizedJson['confirmationNumber'] = data['confirmation_number'] ?? 
                                            data['confirmationNumber'];
      
      // hotel_confirmation_number -> hotelConfirmationNumber
      normalizedJson['hotelConfirmationNumber'] = data['hotel_confirmation_number'] ?? 
                                                  data['hotelConfirmationNumber'];
      
      // voucher_url -> voucherUrl
      normalizedJson['voucherUrl'] = data['voucher_url'] ?? 
                                     data['voucherUrl'];
      
      // check_in_instructions -> checkInInstructions
      normalizedJson['checkInInstructions'] = data['check_in_instructions'] ?? 
                                            data['checkInInstructions'];
      
      // payment_deadline -> paymentDeadline
      if (data['payment_deadline'] != null || data['paymentDeadline'] != null) {
        final deadlineStr = data['payment_deadline'] ?? data['paymentDeadline'];
        if (deadlineStr is String) {
          try {
            normalizedJson['paymentDeadline'] = DateTime.parse(deadlineStr).toIso8601String();
          } catch (_) {
            normalizedJson['paymentDeadline'] = deadlineStr;
          }
        }
      }
      
      // total_amount -> totalAmount
      normalizedJson['totalAmount'] = data['total_amount'] ?? 
                                     data['totalAmount'];
      
      // currency
      normalizedJson['currency'] = data['currency'];
      
      // payment_status -> paymentStatus
      normalizedJson['paymentStatus'] = data['payment_status'] ?? 
                                       data['paymentStatus'];
      
      // payment_url -> payment_url (keep as is for now)
      normalizedJson['payment_url'] = data['payment_url'] ?? 
                                     data['paymentUrl'] ?? 
                                     data['payment_link'] ?? 
                                     data['paymentLink'];
      
      // cancellation_policy -> cancellationPolicy
      normalizedJson['cancellationPolicy'] = data['cancellation_policy'] ?? 
                                            data['cancellationPolicy'];
      
      // hotel_info -> hotelInfo
      normalizedJson['hotelInfo'] = data['hotel_info'] ?? 
                                   data['hotelInfo'];
      
      // room_info -> roomInfo
      normalizedJson['roomInfo'] = data['room_info'] ?? 
                                  data['roomInfo'];
      
      // guest_info -> guestInfo
      normalizedJson['guestInfo'] = data['guest_info'] ?? 
                                   data['guestInfo'];
      
      // dates
      normalizedJson['dates'] = data['dates'];

      // Payment URL ni alohida saqlash
      final paymentUrl = normalizedJson['payment_url'] as String?;

      // Generated fromJson'ni chaqirish
      final booking = _$HotelBookingModelFromJson(normalizedJson);

      // Payment URL'ni to'g'ridan-to'g'ri o'rnatish
      return HotelBookingModel(
        bookingId: booking.bookingId.isNotEmpty ? booking.bookingId : (data['booking_id']?.toString() ?? ''),
        status: booking.status.isNotEmpty ? booking.status : 'pending_payment',
        confirmationNumber: booking.confirmationNumber,
        hotelConfirmationNumber: booking.hotelConfirmationNumber,
        voucherUrl: booking.voucherUrl,
        checkInInstructions: booking.checkInInstructions,
        paymentDeadline: booking.paymentDeadline,
        totalAmount: booking.totalAmount,
        currency: booking.currency,
        paymentStatus: booking.paymentStatus,
        paymentUrl: paymentUrl?.isNotEmpty == true ? paymentUrl : null,
        cancellationPolicy: booking.cancellationPolicy,
        hotelInfo: booking.hotelInfo,
        roomInfo: booking.roomInfo,
        guestInfo: booking.guestInfo,
        dates: booking.dates,
      );
    } catch (e, stackTrace) {
      // Parsing error - return minimal booking model
      debugPrint('❌ HotelBookingModel.fromJson error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON keys: ${json.keys.toList()}');
      
      // Try to extract at least booking_id and status
      final data = json['data'] as Map<String, dynamic>? ?? json;
      return HotelBookingModel(
        bookingId: data['booking_id']?.toString() ?? 
                   data['bookingId']?.toString() ?? 
                   data['id']?.toString() ?? 
                   '',
        status: data['status']?.toString() ?? 'pending_payment',
        confirmationNumber: data['confirmation_number']?.toString() ?? 
                           data['confirmationNumber']?.toString(),
        hotelConfirmationNumber: data['hotel_confirmation_number']?.toString() ?? 
                               data['hotelConfirmationNumber']?.toString(),
        voucherUrl: data['voucher_url']?.toString() ?? 
                   data['voucherUrl']?.toString(),
        checkInInstructions: data['check_in_instructions']?.toString() ?? 
                            data['checkInInstructions']?.toString(),
        paymentDeadline: data['payment_deadline'] != null 
            ? DateTime.tryParse(data['payment_deadline'].toString())
            : null,
        totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 
                   (data['totalAmount'] as num?)?.toDouble(),
        currency: data['currency']?.toString(),
        paymentStatus: data['payment_status']?.toString() ?? 
                      data['paymentStatus']?.toString(),
        paymentUrl: data['payment_url']?.toString() ?? 
                   data['paymentUrl']?.toString() ?? 
                   data['payment_link']?.toString() ?? 
                   data['paymentLink']?.toString(),
        cancellationPolicy: data['cancellation_policy'] is Map 
            ? Map<String, dynamic>.from(data['cancellation_policy'] as Map)
            : data['cancellationPolicy'] is Map
                ? Map<String, dynamic>.from(data['cancellationPolicy'] as Map)
                : null,
        hotelInfo: data['hotel_info'] is Map 
            ? Map<String, dynamic>.from(data['hotel_info'] as Map)
            : data['hotelInfo'] is Map
                ? Map<String, dynamic>.from(data['hotelInfo'] as Map)
                : null,
        roomInfo: data['room_info'] is Map 
            ? Map<String, dynamic>.from(data['room_info'] as Map)
            : data['roomInfo'] is Map
                ? Map<String, dynamic>.from(data['roomInfo'] as Map)
                : null,
        guestInfo: data['guest_info'] is Map 
            ? Map<String, dynamic>.from(data['guest_info'] as Map)
            : data['guestInfo'] is Map
                ? Map<String, dynamic>.from(data['guestInfo'] as Map)
                : null,
        dates: data['dates'] is Map 
            ? Map<String, dynamic>.from(data['dates'] as Map)
            : null,
      );
    }
  }

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

  /// API talab qiladigan `{"data": {...}}` formatiga aylantirish
  Map<String, dynamic> toApiJson() => {
        'data': {
          'quote_id': quoteId,
          'external_id': externalId,
          'booking_rooms': bookingRooms.map((b) => b.toApiJson()).toList(),
          if (comment != null) 'comment': comment,
          if (deltaPrice != null) 'deltaPrice': deltaPrice!.toApiJson(),
        },
      };

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

  Map<String, dynamic> toApiJson() => {
        'option_ref_id': optionRefId,
        'guests': guests.map((g) => g.toApiJson()).toList(),
        'price': price,
      };

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

  Map<String, dynamic> toApiJson() => {
        'person_title': personTitle,
        'first_name': firstName,
        'last_name': lastName,
        'nationality': nationality,
        if (age != null) 'age': age,
      };

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

  Map<String, dynamic> toApiJson() => {
        if (amount != null) 'amount': amount,
        if (percent != null) 'percent': percent,
        'matches': matches,
      };

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
