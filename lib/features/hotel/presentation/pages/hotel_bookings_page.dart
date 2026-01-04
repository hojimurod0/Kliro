import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hotel_booking.dart';
import '../bloc/hotel_bloc.dart';
import 'hotel_booking_details_page.dart';

class HotelBookingsPage extends StatefulWidget {
  const HotelBookingsPage({Key? key}) : super(key: key);

  @override
  State<HotelBookingsPage> createState() => _HotelBookingsPageState();
}

class _HotelBookingsPageState extends State<HotelBookingsPage> {
  @override
  void initState() {
    super.initState();
    // Load bookings when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelBloc>().add(const GetUserBookingsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hotel.bookings.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HotelBloc, HotelState>(
        builder: (context, state) {
          if (state is HotelUserBookingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotelUserBookingsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<HotelBloc>().add(const GetUserBookingsRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('hotel.common.retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is HotelUserBookingsSuccess) {
            final bookings = state.bookings;

            if (bookings.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HotelBloc>().add(const GetUserBookingsRequested());
                // Wait for state update
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildBookingCard(booking);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 24.h),
          Text(
            'hotel.bookings.empty_title'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'hotel.bookings.empty_subtitle'.tr(),
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(HotelBooking booking) {
    final hotelName = booking.hotelInfo?['name'] as String? ?? 'Unknown Hotel';
    final checkIn = booking.dates?['check_in'] as String?;
    final checkOut = booking.dates?['check_out'] as String?;
    final totalAmount = booking.totalAmount ?? 0.0;
    final currency = booking.currency ?? 'uzs';
    final status = booking.status;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HotelBookingDetailsPage(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hotelName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              SizedBox(height: 12.h),

              // Dates
              if (checkIn != null || checkOut != null)
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      _formatDates(checkIn, checkOut),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
              SizedBox(height: 8.h),

              // Booking ID
              Row(
                children: [
                  Icon(Icons.confirmation_number, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    '${'hotel.bookings.booking_id'.tr()}: ${booking.bookingId}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'hotel.bookings.total'.tr(),
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'uz_UZ',
                      symbol: currency == 'uzs' ? 'so\'m' : currency.toUpperCase(),
                      decimalDigits: 0,
                    ).format(totalAmount),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        statusText = 'hotel.bookings.status.confirmed'.tr();
        break;
      case 'pending_payment':
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        statusText = 'hotel.bookings.status.pending'.tr();
        break;
      case 'cancelled':
      case 'canceled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        statusText = 'hotel.bookings.status.cancelled'.tr();
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDates(String? checkIn, String? checkOut) {
    try {
      if (checkIn != null && checkOut != null) {
        final checkInDate = DateTime.parse(checkIn);
        final checkOutDate = DateTime.parse(checkOut);
        return '${DateFormat('dd MMM').format(checkInDate)} - ${DateFormat('dd MMM yyyy').format(checkOutDate)}';
      } else if (checkIn != null) {
        final checkInDate = DateTime.parse(checkIn);
        return DateFormat('dd MMM yyyy').format(checkInDate);
      }
      return '';
    } catch (e) {
      return checkIn ?? checkOut ?? '';
    }
  }
}

