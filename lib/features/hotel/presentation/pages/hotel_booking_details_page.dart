import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/hotel_booking.dart';
import '../bloc/hotel_bloc.dart';
import 'cancel_booking_confirm_page.dart';

class HotelBookingDetailsPage extends StatefulWidget {
  final HotelBooking booking;

  const HotelBookingDetailsPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<HotelBookingDetailsPage> createState() => _HotelBookingDetailsPageState();
}

class _HotelBookingDetailsPageState extends State<HotelBookingDetailsPage> {
  bool _isCancelling = false;
  HotelBooking? _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    // Load fresh booking data from server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelBloc>().add(
        ReadBookingRequested(widget.booking.bookingId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final booking = _currentBooking ?? widget.booking;
    final hotelName = booking.hotelInfo?['name'] as String? ?? 'Unknown Hotel';
    final hotelAddress = booking.hotelInfo?['address'] as String?;
    final checkIn = booking.dates?['check_in'] as String?;
    final checkOut = booking.dates?['check_out'] as String?;
    final totalAmount = booking.totalAmount ?? 0.0;
    final currency = booking.currency ?? 'uzs';
    final status = booking.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hotel.booking_details.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        actions: [
          if (status == 'pending_payment' || status == 'pending')
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _isCancelling ? null : _cancelBooking,
              tooltip: 'hotel.booking_details.cancel'.tr(),
            ),
        ],
      ),
      body: BlocListener<HotelBloc, HotelState>(
        listener: (context, state) {
          if (state is HotelBookingReadSuccess) {
            setState(() {
              _currentBooking = state.booking;
            });
          } else if (state is HotelBookingReadFailure) {
            // If read fails, continue with existing booking data
            // Don't show error to user as we already have booking data
          } else if (state is HotelBookingCancelSuccess) {
            setState(() => _isCancelling = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('hotel.booking_details.cancelled_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is HotelBookingCancelFailure) {
            setState(() => _isCancelling = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(status),
              SizedBox(height: 24.h),

              // Hotel Info
              _buildSectionTitle('hotel.booking_details.hotel_info'.tr()),
              SizedBox(height: 12.h),
              _buildInfoCard(
                title: hotelName,
                subtitle: hotelAddress,
                icon: Icons.hotel,
              ),
              SizedBox(height: 24.h),

              // Booking Dates
              _buildSectionTitle('hotel.booking_details.dates'.tr()),
              SizedBox(height: 12.h),
              _buildInfoCard(
                title: _formatDates(checkIn, checkOut),
                subtitle: _calculateNights(checkIn, checkOut),
                icon: Icons.calendar_today,
              ),
              SizedBox(height: 24.h),

              // Booking Details
              _buildSectionTitle('hotel.booking_details.booking_details'.tr()),
              SizedBox(height: 12.h),
              _buildDetailRow(
                'hotel.booking_details.booking_id'.tr(),
                booking.bookingId,
              ),
              if (booking.confirmationNumber != null)
                _buildDetailRow(
                  'hotel.booking_details.confirmation_number'.tr(),
                  booking.confirmationNumber!,
                ),
              if (booking.hotelConfirmationNumber != null)
                _buildDetailRow(
                  'hotel.booking_details.hotel_confirmation'.tr(),
                  booking.hotelConfirmationNumber!,
                ),
              SizedBox(height: 24.h),

              // Payment Info
              _buildSectionTitle('hotel.booking_details.payment'.tr()),
              SizedBox(height: 12.h),
              _buildInfoCard(
                title: NumberFormat.currency(
                  locale: 'uz_UZ',
                  symbol: currency == 'uzs' ? 'so\'m' : currency.toUpperCase(),
                  decimalDigits: 0,
                ).format(totalAmount),
                subtitle: 'hotel.booking_details.total_amount'.tr(),
                icon: Icons.payment,
              ),
              if (booking.paymentStatus != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: _buildDetailRow(
                    'hotel.booking_details.payment_status'.tr(),
                    booking.paymentStatus!,
                  ),
                ),
              SizedBox(height: 24.h),

              // Check-in Instructions
              if (booking.checkInInstructions != null) ...[
                _buildSectionTitle('hotel.booking_details.checkin_instructions'.tr()),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    booking.checkInInstructions!,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Voucher Download
              if (booking.voucherUrl != null) ...[
                ElevatedButton.icon(
                  onPressed: () => _downloadVoucher(booking.voucherUrl!),
                  icon: const Icon(Icons.download),
                  label: Text('hotel.booking_details.download_voucher'.tr()),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        statusText = 'hotel.bookings.status.confirmed'.tr();
        break;
      case 'pending_payment':
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.pending;
        statusText = 'hotel.bookings.status.pending'.tr();
        break;
      case 'cancelled':
      case 'canceled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        statusText = 'hotel.bookings.status.cancelled'.tr();
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.info;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 32.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.blue, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color ??
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color ??
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDates(String? checkIn, String? checkOut) {
    try {
      if (checkIn != null && checkOut != null) {
        final checkInDate = DateTime.parse(checkIn);
        final checkOutDate = DateTime.parse(checkOut);
        return '${DateFormat('dd MMM yyyy').format(checkInDate)} - ${DateFormat('dd MMM yyyy').format(checkOutDate)}';
      } else if (checkIn != null) {
        final checkInDate = DateTime.parse(checkIn);
        return DateFormat('dd MMM yyyy').format(checkInDate);
      }
      return '';
    } catch (e) {
      return checkIn ?? checkOut ?? '';
    }
  }

  String _calculateNights(String? checkIn, String? checkOut) {
    try {
      if (checkIn != null && checkOut != null) {
        final checkInDate = DateTime.parse(checkIn);
        final checkOutDate = DateTime.parse(checkOut);
        final nights = checkOutDate.difference(checkInDate).inDays;
        return '$nights ${'hotel.booking_details.nights'.tr()}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CancelBookingConfirmPage(),
      ),
    );

    if (confirmed == true) {
      setState(() => _isCancelling = true);
      context.read<HotelBloc>().add(
            CancelBookingRequested(
              bookingId: widget.booking.bookingId,
              cancellationReason: 'hotel.booking_details.user_cancelled'.tr(),
            ),
          );
    }
  }

  Future<void> _downloadVoucher(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('hotel.booking_details.voucher_error'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hotel.booking_details.voucher_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

