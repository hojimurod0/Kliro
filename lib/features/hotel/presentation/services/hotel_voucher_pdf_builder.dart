import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/hotel_booking.dart';

class HotelVoucherPdfBuilder {
  static Future<Uint8List> generate(HotelBooking booking) async {
    final doc = pw.Document();

    final currency = (booking.currency ?? 'UZS').toUpperCase();
    final nf = NumberFormat.currency(
        locale: 'en_US',
        symbol: currency == 'UZS' ? "so'm" : currency,
        decimalDigits: 0);

    final checkIn = booking.dates?['check_in']?.toString();
    final checkOut = booking.dates?['check_out']?.toString();

    int? nights;
    try {
      if (checkIn != null && checkOut != null) {
        final a = DateTime.parse(checkIn);
        final b = DateTime.parse(checkOut);
        nights = b.difference(a).inDays;
      }
    } catch (_) {}

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(24),
        ),
        build: (context) => [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Hotel Booking Voucher',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Booking ID: ${booking.bookingId}',
                      style: const pw.TextStyle(fontSize: 12)),
                  if (booking.confirmationNumber != null)
                    pw.Text('Confirmation: ${booking.confirmationNumber}',
                        style: const pw.TextStyle(fontSize: 12)),
                  if (booking.hotelConfirmationNumber != null)
                    pw.Text('Hotel Conf.: ${booking.hotelConfirmationNumber}',
                        style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.blue200, width: 1),
                ),
                child: pw.Text(
                  booking.status.toUpperCase(),
                  style: pw.TextStyle(
                      color: PdfColors.blue800, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Hotel info
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Hotel',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(
                    booking.hotelInfo?['name']?.toString() ?? 'Unknown Hotel'),
                if (booking.hotelInfo?['address'] != null)
                  pw.Text(booking.hotelInfo!['address'].toString(),
                      style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          // Dates and guest
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dates',
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      if (checkIn != null) pw.Text('Check-in: $checkIn'),
                      if (checkOut != null) pw.Text('Check-out: $checkOut'),
                      if (nights != null) pw.Text('Nights: $nights'),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Guest',
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      pw.Text('Name: ${booking.guestInfo?['name'] ?? 'N/A'}'),
                      if (booking.guestInfo?['phone'] != null)
                        pw.Text('Phone: ${booking.guestInfo!['phone']}'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 12),

          // Room and price
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Room Info',
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      pw.Text(booking.roomInfo?['name']?.toString() ??
                          booking.roomInfo?['room_type']?.toString() ??
                          'N/A'),
                      if (booking.roomInfo?['description'] != null)
                        pw.Text(booking.roomInfo!['description'].toString(),
                            style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Payment',
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      pw.Text('Total: ${nf.format(booking.totalAmount ?? 0)}'),
                      if (booking.paymentStatus != null)
                        pw.Text('Status: ${booking.paymentStatus}'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 12),

          // Voucher URL and QR
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue300),
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Voucher',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                pw.Text(booking.voucherUrl ?? 'No voucher URL provided'),
                pw.SizedBox(height: 8),
                if ((booking.voucherUrl ?? '').isNotEmpty)
                  pw.Row(
                    children: [
                      pw.BarcodeWidget(
                        data: booking.voucherUrl!,
                        barcode: pw.Barcode.qrCode(),
                        width: 80,
                        height: 80,
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Text(
                          'Scan the QR code or visit the link to view the original voucher',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (booking.checkInInstructions != null) ...[
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Check-in Instructions',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text(booking.checkInInstructions!),
                ],
              ),
            ),
          ],

          if (booking.cancellationPolicy != null) ...[
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Cancellation Policy',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text(booking.cancellationPolicy.toString()),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }
}
