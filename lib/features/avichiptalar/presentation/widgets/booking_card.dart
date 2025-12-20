import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final VoidCallback onPdfDownload;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    required this.onPdfDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingStatus = booking.status?.toLowerCase() ?? '';
    final isSuccess = bookingStatus == 'success' || bookingStatus == 'paid' || bookingStatus == 'confirmed';
    String date = '';
    if (booking.createdAt != null) {
      try {
        final parsedDate = DateTime.tryParse(booking.createdAt!);
        if (parsedDate != null) {
          date = DateFormat('dd.MM.yyyy HH:mm').format(parsedDate);
        } else {
          date = booking.createdAt!;
        }
      } catch (e) {
        date = booking.createdAt!;
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'avia.orders.id_label'.tr()}: ${booking.id}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSuccess 
                          ? AppColors.accentGreen.withValues(alpha: 0.1) 
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _translateStatus(booking.status),
                      style: TextStyle(
                        color: isSuccess ? AppColors.accentGreen : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (booking.payer != null) ...[
                Text(
                  booking.payer?.name ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                '${'avia.orders.date_label'.tr()}: $date',
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.price ?? 0} ${booking.currency ?? ''}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  if (isSuccess)
                    IconButton(
                      onPressed: onPdfDownload,
                      icon: const Icon(Icons.picture_as_pdf),
                      color: AppColors.primaryBlue,
                      tooltip: 'avia.orders.download_receipt'.tr(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateStatus(String? status) {
    if (status == null) return '';
    final statusLower = status.toLowerCase();
    final key = 'avia.statuses.$statusLower';
    final translated = key.tr();
    return translated == key ? status : translated;
  }
}
