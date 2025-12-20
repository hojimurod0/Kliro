import '../../../../core/errors/exceptions.dart';
import '../models/create_booking_request_model.dart';

/// Booking request validation va sanitization uchun helper class
class ValidationHelper {
  /// Booking request ni validate va sanitize qiladi
  static Map<String, dynamic> sanitizeBookingRequest(
    CreateBookingRequestModel request,
  ) {
    final payload = Map<String, dynamic>.from(request.toJson());

    // Telefon raqamlarini tozalash
    if (payload['payer_tel'] is String) {
      payload['payer_tel'] = _sanitizePhoneNumber(
        payload['payer_tel'] as String,
      );
    }

    // Passengers ma'lumotlarini sanitize qilish
    if (payload['passengers'] is List) {
      final passengers = payload['passengers'] as List;
      payload['passengers'] = passengers.map((p) {
        if (p is Map) {
          return _sanitizePassengerData(Map<String, dynamic>.from(p));
        }
        return p;
      }).toList();
    }

    return payload;
  }

  /// Telefon raqamini tozalash - faqat raqamlar va + belgisini qoldiradi
  static String _sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  /// Passenger ma'lumotlarini sanitize qilish
  static Map<String, dynamic> _sanitizePassengerData(
    Map<String, dynamic> passenger,
  ) {
    // Telefon raqamini tozalash
    if (passenger['tel'] is String) {
      passenger['tel'] = _sanitizePhoneNumber(passenger['tel'] as String);
    }

    // Doc type konvertatsiyasi: 'A' -> 'P'
    if (passenger['doc_type'] is String) {
      final docType = (passenger['doc_type'] as String).toUpperCase();
      if (docType == 'A') {
        passenger['doc_type'] = 'P';
      }
    }

    return passenger;
  }

  /// Offer ID ni validate qiladi
  static void validateOfferId(String offerId) {
    if (offerId.isEmpty) {
      throw ValidationException('Offer ID bo\'sh bo\'lmasligi kerak');
    }
  }

  /// Booking ID ni validate qiladi
  static void validateBookingId(String bookingId) {
    if (bookingId.isEmpty) {
      throw ValidationException('Booking ID bo\'sh bo\'lmasligi kerak');
    }
  }

  /// Flight ID ni validate qiladi
  static void validateFlightId(String flightId) {
    if (flightId.isEmpty) {
      throw ValidationException('Flight ID bo\'sh bo\'lmasligi kerak');
    }
  }

  /// UUID ni validate qiladi
  static void validateUuid(String uuid) {
    if (uuid.isEmpty) {
      throw ValidationException('UUID bo\'sh bo\'lmasligi kerak');
    }
  }

  /// Phrase ni validate qiladi (airport hints uchun)
  static void validatePhrase(String phrase) {
    if (phrase.trim().isEmpty) {
      throw ValidationException('Qidiruv so\'zi bo\'sh bo\'lmasligi kerak');
    }
  }
}

// ValidationException core/errors/exceptions.dart dan import qilinadi


