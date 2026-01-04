// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotelBookingModel _$HotelBookingModelFromJson(Map<String, dynamic> json) =>
    HotelBookingModel(
      bookingId: json['bookingId'] as String,
      status: json['status'] as String,
      confirmationNumber: json['confirmationNumber'] as String?,
      hotelConfirmationNumber: json['hotelConfirmationNumber'] as String?,
      voucherUrl: json['voucherUrl'] as String?,
      checkInInstructions: json['checkInInstructions'] as String?,
      paymentDeadline: json['paymentDeadline'] == null
          ? null
          : DateTime.parse(json['paymentDeadline'] as String),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      cancellationPolicy: json['cancellationPolicy'] as Map<String, dynamic>?,
      hotelInfo: json['hotelInfo'] as Map<String, dynamic>?,
      roomInfo: json['roomInfo'] as Map<String, dynamic>?,
      guestInfo: json['guestInfo'] as Map<String, dynamic>?,
      dates: json['dates'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$HotelBookingModelToJson(HotelBookingModel instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'status': instance.status,
      'confirmationNumber': instance.confirmationNumber,
      'hotelConfirmationNumber': instance.hotelConfirmationNumber,
      'voucherUrl': instance.voucherUrl,
      'checkInInstructions': instance.checkInInstructions,
      'paymentDeadline': instance.paymentDeadline?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'paymentStatus': instance.paymentStatus,
      'cancellationPolicy': instance.cancellationPolicy,
      'hotelInfo': instance.hotelInfo,
      'roomInfo': instance.roomInfo,
      'guestInfo': instance.guestInfo,
      'dates': instance.dates,
    };

CreateBookingRequestModel _$CreateBookingRequestModelFromJson(
        Map<String, dynamic> json) =>
    CreateBookingRequestModel(
      quoteId: json['quoteId'] as String,
      externalId: json['externalId'] as String,
      bookingRooms: (json['bookingRooms'] as List<dynamic>)
          .map((e) => BookingRoomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      deltaPrice: json['deltaPrice'] == null
          ? null
          : DeltaPriceModel.fromJson(
              json['deltaPrice'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateBookingRequestModelToJson(
        CreateBookingRequestModel instance) =>
    <String, dynamic>{
      'quoteId': instance.quoteId,
      'externalId': instance.externalId,
      'bookingRooms': instance.bookingRooms,
      'comment': instance.comment,
      'deltaPrice': instance.deltaPrice,
    };

BookingRoomModel _$BookingRoomModelFromJson(Map<String, dynamic> json) =>
    BookingRoomModel(
      optionRefId: json['optionRefId'] as String,
      guests: (json['guests'] as List<dynamic>)
          .map((e) => BookingGuestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$BookingRoomModelToJson(BookingRoomModel instance) =>
    <String, dynamic>{
      'optionRefId': instance.optionRefId,
      'guests': instance.guests,
      'price': instance.price,
    };

BookingGuestModel _$BookingGuestModelFromJson(Map<String, dynamic> json) =>
    BookingGuestModel(
      personTitle: json['personTitle'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      nationality: json['nationality'] as String,
      age: (json['age'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BookingGuestModelToJson(BookingGuestModel instance) =>
    <String, dynamic>{
      'personTitle': instance.personTitle,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'nationality': instance.nationality,
      'age': instance.age,
    };

DeltaPriceModel _$DeltaPriceModelFromJson(Map<String, dynamic> json) =>
    DeltaPriceModel(
      amount: (json['amount'] as num?)?.toDouble(),
      percent: (json['percent'] as num?)?.toDouble(),
      matches: json['matches'] as String? ?? 'ALL',
    );

Map<String, dynamic> _$DeltaPriceModelToJson(DeltaPriceModel instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'percent': instance.percent,
      'matches': instance.matches,
    };
