import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/navigation/app_router.dart';
import '../../domain/entities/hotel_booking.dart';
import '../services/hotel_voucher_pdf_builder.dart';

class HotelSuccessPage extends StatefulWidget {
  final HotelBooking? booking;

  const HotelSuccessPage({Key? key, this.booking}) : super(key: key);

  @override
  State<HotelSuccessPage> createState() => _HotelSuccessPageState();
}

class _HotelSuccessPageState extends State<HotelSuccessPage> {
  bool _isDownloading = false;
  bool _isSharing = false;
  bool _autoTried = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking?.voucherUrl?.isNotEmpty == true && !_autoTried) {
      _autoTried = true;
      Future.microtask(() => _downloadVoucher());
    }
  }

  Future<void> _generateCustomVoucher() async {
    if (widget.booking == null) return;
    setState(() => _isGenerating = true);
    try {
      final bytes = await HotelVoucherPdfBuilder.generate(widget.booking!);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'hotel_voucher_custom_${widget.booking!.bookingId}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      if (mounted) {
        await OpenFile.open(filePath);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hotel.success.download_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _downloadVoucher() async {
    if (widget.booking?.voucherUrl == null || widget.booking!.voucherUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('hotel.success.voucher_not_available'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final dio = Dio();
      final response = await dio.get(
        widget.booking!.voucherUrl!,
        options: Options(responseType: ResponseType.bytes),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'hotel_voucher_${widget.booking!.bookingId}.pdf';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hotel.success.downloaded'.tr()),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'hotel.success.open'.tr(),
              onPressed: () async {
                // url_launcher file:// ba'zi qurilmalarda ishlamaydi,
                // OpenFile esa ko'proq barqaror.
                await OpenFile.open(filePath);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hotel.success.download_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _shareBooking() async {
    if (widget.booking == null) {
      return;
    }

    setState(() => _isSharing = true);

    try {
      final booking = widget.booking!;
      final shareText = StringBuffer();
      
      shareText.writeln('hotel.success.share_title'.tr());
      shareText.writeln('hotel.booking.title'.tr());
      shareText.writeln('');
      shareText.writeln('hotel.booking.name'.tr() + ': ${booking.guestInfo?['name'] ?? 'N/A'}');
      shareText.writeln('hotel.booking.phone'.tr() + ': ${booking.guestInfo?['phone'] ?? 'N/A'}');
      shareText.writeln('hotel.success.booking_id'.tr() + ': ${booking.bookingId}');
      
      if (booking.confirmationNumber != null) {
        shareText.writeln('hotel.success.confirmation'.tr() + ': ${booking.confirmationNumber}');
      }
      
      if (booking.totalAmount != null) {
        shareText.writeln('hotel.guest_details.total'.tr() + ': ${booking.totalAmount} ${booking.currency ?? 'UZS'}');
      }
      
      if (booking.dates != null) {
        shareText.writeln('hotel.search.check_in'.tr() + ': ${booking.dates!['check_in'] ?? 'N/A'}');
        shareText.writeln('hotel.search.check_out'.tr() + ': ${booking.dates!['check_out'] ?? 'N/A'}');
      }

      await Share.share(shareText.toString());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hotel.success.share_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon/Animation
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: Colors.green, size: 60.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                'hotel.success.title'.tr(),
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.booking != null
                    ? 'hotel.success.booking_id'.tr() + ': ${widget.booking!.bookingId}\n${widget.booking!.confirmationNumber != null ? "hotel.success.confirmation".tr() + ": ${widget.booking!.confirmationNumber}" : ""}'
                    : 'hotel.success.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              const Spacer(),
              
              // Actions
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: _isDownloading ? null : _downloadVoucher,
                  icon: _isDownloading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isDownloading
                      ? 'hotel.success.downloading'.tr()
                      : 'hotel.success.download'.tr()),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _generateCustomVoucher,
                  icon: _isGenerating
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    _isGenerating
                        ? 'hotel.success.downloading'.tr()
                        : 'Generate Custom Voucher',
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton.icon(
                  onPressed: _isSharing ? null : _shareBooking,
                  icon: _isSharing
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(_isSharing
                      ? 'hotel.success.sharing'.tr()
                      : 'hotel.success.share'.tr()),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      AutoRouter.of(context).replaceAll([HomeRoute()]);
                    } catch (_) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'hotel.common.close'.tr(),
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
