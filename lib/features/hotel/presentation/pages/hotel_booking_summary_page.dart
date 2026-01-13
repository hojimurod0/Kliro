import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../features/avichiptalar/presentation/bloc/payment_bloc.dart';
import '../../../../features/avichiptalar/data/models/invoice_request_model.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_booking.dart';
import '../../domain/entities/reference_data.dart';
import '../bloc/hotel_bloc.dart';
import 'hotel_success_page.dart';

class HotelBookingSummaryPage extends StatefulWidget {
  final Hotel hotel;
  final HotelOption? selectedOption;
  final String? quoteId;
  
  // Guest Information
  final String? personTitle;
  final String? firstName;
  final String? lastName;
  final String? nationality;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final int adultCount;
  
  // Special Requests
  final String? comment;

  const HotelBookingSummaryPage({
    Key? key,
    required this.hotel,
    this.selectedOption,
    this.quoteId,
    this.personTitle,
    this.firstName,
    this.lastName,
    this.nationality,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.adultCount = 1,
    this.comment,
  }) : super(key: key);

  @override
  State<HotelBookingSummaryPage> createState() => _HotelBookingSummaryPageState();
}

class _HotelBookingSummaryPageState extends State<HotelBookingSummaryPage> with WidgetsBindingObserver {
  bool _isLoading = false;
  List<RoomType> _roomTypes = [];
  
  // Payment related
  late PaymentBloc _paymentBloc;
  HotelBooking? _currentBooking;
  
  // Payment status polling
  String? _currentInvoiceUuid;
  bool _urlLaunched = false;
  Timer? _statusPollingTimer;
  
  // Card expansion states
  bool _isHotelInfoExpanded = true;
  bool _isGuestInfoExpanded = true;
  bool _isBookingSummaryExpanded = true;
  bool _isImportantNotesExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // PaymentBloc ni ServiceLocator dan olish
    _paymentBloc = ServiceLocator.resolve<PaymentBloc>();
    
    // Load room types for displaying room type name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<HotelBloc>()
          .add(GetHotelRoomTypesRequested(widget.hotel.hotelId));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStatusPolling();
    // PaymentBloc registerFactory bilan ro'yxatdan o'tkazilgan,
    // har safar yangi instance yaratiladi, shuning uchun close() qilish xavfsiz
    try {
      if (!_paymentBloc.isClosed) {
        _paymentBloc.close();
      }
    } catch (e) {
      // Error closing PaymentBloc - ignore
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _urlLaunched &&
        _currentInvoiceUuid != null) {
      _checkPaymentStatus();
      // Polling ni qayta boshlash (agar to'xtatilgan bo'lsa)
      if (_statusPollingTimer == null || !_statusPollingTimer!.isActive) {
        _startStatusPolling();
      }
    } else if (state == AppLifecycleState.paused) {
      // App paused bo'lganda polling ni to'xtatish (battery saqlash uchun)
      _stopStatusPolling();
    }
  }

  int _calculateNights() {
    return widget.hotel.checkOutDate.difference(widget.hotel.checkInDate).inDays;
  }

  String _getRoomTypeName() {
    if (widget.selectedOption?.roomTypeId == null) {
      return 'hotel.details.room'.tr();
    }

    if (_roomTypes.isEmpty) {
      return '${'hotel.details.room'.tr()} #${widget.selectedOption!.roomTypeId}';
    }

    try {
      final matching = _roomTypes.firstWhere(
        (rt) => rt.id == widget.selectedOption!.roomTypeId,
      );
      // Safe locale extraction with fallback
      Locale locale;
      try {
        locale = context.locale;
      } catch (e) {
        // Fallback to default locale if context.locale fails
        locale = const Locale('uz');
      }
      final normalizedLocale = _normalizeLocale(locale);
      return matching.getDisplayName(normalizedLocale);
    } catch (e) {
      // Room type not found, return fallback
      return '${'hotel.details.room'.tr()} #${widget.selectedOption!.roomTypeId}';
    }
  }

  /// Normalize locale for API
  String _normalizeLocale(Locale locale) {
    try {
      // Handle Cyrillic Uzbek specially
      if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
        return 'uz_CYR'; // API format
      }

      // For other locales, use just the language code
      // en_US -> en, ru_RU -> ru, uz -> uz
      return locale.languageCode.isNotEmpty ? locale.languageCode : 'uz';
    } catch (e) {
      // Fallback to default locale if error occurs
      return 'uz';
    }
  }

  String _getMealPlan() {
    if (widget.selectedOption?.includedMealOptions != null && 
        widget.selectedOption!.includedMealOptions!.isNotEmpty) {
      return widget.selectedOption!.includedMealOptions!.first;
    }
    return 'Room Only';
  }

  String _getCancellationPolicy() {
    if (widget.selectedOption?.cancellationPolicy != null) {
      final policy = widget.selectedOption!.cancellationPolicy!;
      if (policy['free_cancellation'] == true) {
        return 'hotel.summary.free_cancellation'.tr();
      }
      return 'hotel.summary.cancellation_policy_applies'.tr();
    }
    return 'hotel.summary.cancellation_policy_applies'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final nights = _calculateNights();
    final totalAmount = widget.selectedOption?.price ?? widget.hotel.price ?? 0;
    final currency = widget.selectedOption?.currency ?? 'uzs';
    final roomTypeName = _getRoomTypeName();
    final mealPlan = _getMealPlan();
    final cancellationPolicy = _getCancellationPolicy();

    return MultiBlocListener(
      listeners: [
        BlocListener<HotelBloc, HotelState>(
          listener: (context, state) {
            if (state is HotelRoomTypesSuccess) {
              setState(() {
                _roomTypes = state.roomTypes;
              });
            } else if (state is HotelBookingCreateFailure) {
              setState(() => _isLoading = false);
              // Show error with retry option
              _showBookingErrorDialog(context, state.message);
            } else if (state is HotelBookingConfirmSuccess) {
              setState(() => _isLoading = false);
              // To'lov muvaffaqiyatli bo'lganda success page'ga o'tish
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HotelSuccessPage(booking: state.booking),
                ),
                (route) => route.isFirst,
              );
            } else if (state is HotelBookingConfirmFailure) {
              setState(() => _isLoading = false);
              // Show error with retry option
              _showBookingErrorDialog(context, state.message);
            }
          },
        ),
        BlocListener<PaymentBloc, PaymentState>(
          bloc: _paymentBloc,
          listener: (context, state) {
            if (state is InvoiceCreatedSuccess) {
              // Invoice yaratilganda checkoutUrl'ni ochish
              if (state.invoice.checkoutUrl.isEmpty) {
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'To\'lov linki topilmadi',
                  );
                }
                return;
              }
              if (mounted) {
                setState(() {
                  _currentInvoiceUuid = state.invoice.uuid;
                  _urlLaunched = false;
                });
                _launchPaymentUrl(state.invoice.checkoutUrl);
              }
            } else if (state is PaymentStatusSuccess) {
              // To'lov holati tekshirildi
              if (state.status == 'paid' || state.status == 'success') {
                // To'lov muvaffaqiyatli bo'lganda polling ni to'xtatish va booking'ni confirm qilish
                _stopStatusPolling();
                if (mounted && _currentBooking != null) {
                  _confirmBooking(_currentBooking!.bookingId);
                  setState(() {
                    _currentInvoiceUuid = null;
                    _urlLaunched = false;
                  });
                }
              } else if (state.status == 'failed' || state.status == 'canceled') {
                _stopStatusPolling();
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'To\'lov bekor qilindi yoki xatolik: ${state.status}',
                  );
                  setState(() {
                    _currentInvoiceUuid = null;
                    _urlLaunched = false;
                  });
                }
              }
            } else if (state is PaymentFailure) {
              setState(() => _isLoading = false);
              if (mounted) {
                SnackbarHelper.showError(context, state.message);
              }
            }
          },
        ),
      ],
      child: _buildContent(context, nights, totalAmount, currency, roomTypeName, mealPlan, cancellationPolicy),
    );
  }

  Widget _buildContent(
    BuildContext context,
    int nights,
    double totalAmount,
    String currency,
    String roomTypeName,
    String mealPlan,
    String cancellationPolicy,
  ) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hotel.summary.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Information Card
            _buildHotelInfoCard(context, roomTypeName),
            SizedBox(height: 14.h),

            // Guest Information Card
            _buildGuestInfoCard(context),
            SizedBox(height: 14.h),

            // Booking Summary Card
            _buildBookingSummaryCard(
              context,
              nights: nights,
              totalAmount: totalAmount,
              currency: currency,
              mealPlan: mealPlan,
              cancellationPolicy: cancellationPolicy,
            ),
            SizedBox(height: 14.h),

            // Important Notes Card
            _buildImportantNotesCard(context),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'hotel.summary.go_back'.tr(),
                    style: TextStyle(fontSize: 14.sp),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _proceedToPayment(context),
                  icon: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.payment, size: 18.sp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  label: Text(
                    'hotel.summary.make_payment'.tr(),
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelInfoCard(BuildContext context, String roomTypeName) {
    final checkInDate = DateFormat('dd MMM yyyy').format(widget.hotel.checkInDate);
    final checkOutDate = DateFormat('dd MMM yyyy').format(widget.hotel.checkOutDate);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isHotelInfoExpanded = !_isHotelInfoExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              padding: EdgeInsets.all(18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.location_on, color: Colors.blue, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'hotel.summary.hotel_info'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isHotelInfoExpanded) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  widget.hotel.name,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isHotelInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_isHotelInfoExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotel.name,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place, size: 16.sp, color: Colors.grey.shade600),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          widget.hotel.address,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildInfoRowWithIcon(
                    Icons.hotel,
                    'hotel.summary.room_type'.tr(),
                    roomTypeName,
                  ),
                  SizedBox(height: 14.h),
                  _buildInfoRowWithIcon(
                    Icons.people,
                    'hotel.summary.number_of_guests'.tr(),
                    '${widget.adultCount} ${widget.adultCount == 1 ? 'hotel.summary.adult'.tr() : 'hotel.summary.adults'.tr()}',
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDateRow(
                          Icons.login,
                          'hotel.summary.check_in'.tr(),
                          checkInDate,
                          '14:00',
                        ),
                        SizedBox(height: 12.h),
                        Divider(height: 1, color: Colors.grey.shade300),
                        SizedBox(height: 12.h),
                        _buildDateRow(
                          Icons.logout,
                          'hotel.summary.check_out'.tr(),
                          checkOutDate,
                          '12:00',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestInfoCard(BuildContext context) {
    final guestName = widget.personTitle != null && widget.firstName != null && widget.lastName != null
        ? '${widget.personTitle} ${widget.firstName} ${widget.lastName}'
        : 'hotel.summary.not_specified'.tr();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isGuestInfoExpanded = !_isGuestInfoExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              padding: EdgeInsets.all(18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.person, color: Colors.green, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'hotel.summary.guest_info'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isGuestInfoExpanded && guestName != 'hotel.summary.not_specified'.tr()) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  guestName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isGuestInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_isGuestInfoExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16.sp, color: Colors.blue),
                            SizedBox(width: 8.w),
                            Text(
                              'hotel.summary.main_guest'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          guestName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.contactName != null || widget.contactEmail != null || widget.contactPhone != null) ...[
                    SizedBox(height: 16.h),
                    Text(
                      'hotel.summary.contact_info'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (widget.contactName != null)
                      _buildContactRow(Icons.badge, widget.contactName!),
                    if (widget.contactEmail != null) ...[
                      if (widget.contactName != null) SizedBox(height: 10.h),
                      _buildContactRow(Icons.email, widget.contactEmail!),
                    ],
                    if (widget.contactPhone != null) ...[
                      if (widget.contactName != null || widget.contactEmail != null) SizedBox(height: 10.h),
                      _buildContactRow(Icons.phone, widget.contactPhone!),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingSummaryCard(
    BuildContext context, {
    required int nights,
    required double totalAmount,
    required String currency,
    required String mealPlan,
    required String cancellationPolicy,
  }) {
    final formattedAmount = NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: currency == 'uzs' ? 'so\'m' : currency.toUpperCase(),
      decimalDigits: 0,
    ).format(totalAmount);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isBookingSummaryExpanded = !_isBookingSummaryExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              padding: EdgeInsets.all(18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.receipt_long, color: Colors.orange, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'hotel.summary.booking_summary'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isBookingSummaryExpanded) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  formattedAmount,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isBookingSummaryExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_isBookingSummaryExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRowWithIcon(
                    Icons.bed,
                    'hotel.summary.nights'.tr(),
                    '$nights ${nights == 1 ? 'hotel.summary.night'.tr() : 'hotel.summary.nights_plural'.tr()}',
                  ),
                  SizedBox(height: 14.h),
                  _buildInfoRowWithIcon(
                    Icons.hotel,
                    'hotel.summary.rooms'.tr(),
                    '1 ${'hotel.summary.rooms_plural'.tr()}',
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'hotel.summary.total_amount'.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          formattedAmount,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildInfoRowWithIcon(
                    Icons.account_balance_wallet,
                    'hotel.summary.tourist_tax'.tr(),
                    'hotel.summary.included'.tr(),
                  ),
                  SizedBox(height: 14.h),
                  _buildInfoRowWithIcon(
                    Icons.restaurant,
                    'hotel.summary.meal_plan'.tr(),
                    mealPlan,
                  ),
                  SizedBox(height: 14.h),
                  _buildInfoRowWithIcon(
                    Icons.cancel_outlined,
                    'hotel.summary.cancellation_policy_applies'.tr(),
                    cancellationPolicy,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportantNotesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isImportantNotesExpanded = !_isImportantNotesExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              padding: EdgeInsets.all(18.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.info_outline, color: Colors.amber.shade700, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'hotel.summary.important_notes'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isImportantNotesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_isImportantNotesExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNoteItem(Icons.access_time, 'hotel.summary.note_checkin_time'.tr()),
                  SizedBox(height: 14.h),
                  _buildNoteItem(Icons.credit_card, 'hotel.summary.note_passport_required'.tr()),
                  SizedBox(height: 14.h),
                  _buildNoteItem(Icons.cancel_presentation, 'hotel.summary.note_cancellation_policy'.tr()),
                  SizedBox(height: 14.h),
                  _buildNoteItem(Icons.phone_in_talk, 'hotel.summary.note_contact_hotel'.tr()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade600),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                flex: 3,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(IconData icon, String label, String date, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.blue),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                date,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade600),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4.h, right: 12.w),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: Colors.amber.shade700),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _proceedToPayment(BuildContext context) {
    if (widget.quoteId == null) {
      SnackbarHelper.showError(
        context,
        'hotel.booking.quote_not_found'.tr(),
      );
      return;
    }

    setState(() => _isLoading = true);

    // To'g'ridan-to'g'ri invoice yaratish va multicardga o'tish (booking yaratmasdan)
    _createInvoiceAndLaunchDirectly();
  }

  /// Create invoice directly without creating booking first
  Future<void> _createInvoiceAndLaunchDirectly() async {
    // Narxni selectedOption yoki hotel price'dan olish
    final totalAmount = widget.selectedOption?.price ?? widget.hotel.price ?? 0.0;
    
    if (totalAmount <= 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarHelper.showError(
          context,
          'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.',
        );
      }
      return;
    }

    // API eng kichik birlikda amount kutadi (masalan, 500000)
    // UZS uchun: 5000 UZS = 500000 (100 ga ko'paytiriladi)
    // Boshqa valyutalar uchun ham 100 ga ko'paytiriladi (cents uchun)
    // Narxga API'dan kelgan chegirma allaqachon qo'llangan, shuning uchun qo'shimcha komissiya qo'shmaslik
    final amount = (totalAmount * 100).toInt();

    // Amount musbat bo'lishi kerak (backend talabi)
    if (amount <= 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarHelper.showError(
          context,
          'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.',
        );
      }
      return;
    }

    // Invoice ID formatini Postman collection bo'yicha yaratish
    final random = DateTime.now().millisecondsSinceEpoch % 10000000;
    final invoiceId = 'hotel${random.toString().padLeft(7, '0')}';

    if (!mounted || _paymentBloc.isClosed) {
      return;
    }

    final request = InvoiceRequestModel(
      amount: amount,
      invoiceId: invoiceId,
      lang: context.locale.languageCode,
      returnUrl: 'https://kliro.uz',
      callbackUrl: 'https://api.kliro.uz/payment/callback/success',
    );

    _paymentBloc.add(CreateInvoiceRequested(request));
  }

  /// Create invoice and launch payment URL (similar to avia)
  /// This method is used when booking is already created
  Future<void> _createInvoiceAndLaunch(HotelBooking booking) async {
    // Narxni booking model'dan olish
    final totalAmount = booking.totalAmount ?? 
                       widget.selectedOption?.price ?? 
                       widget.hotel.price ?? 0.0;
    
    if (totalAmount <= 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarHelper.showError(
          context,
          'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.',
        );
      }
      return;
    }

    // API eng kichik birlikda amount kutadi (masalan, 500000)
    // UZS uchun: 5000 UZS = 500000 (100 ga ko'paytiriladi)
    // Boshqa valyutalar uchun ham 100 ga ko'paytiriladi (cents uchun)
    // Narxga API'dan kelgan chegirma allaqachon qo'llangan, shuning uchun qo'shimcha komissiya qo'shmaslik
    final amount = (totalAmount * 100).toInt();

    // Amount musbat bo'lishi kerak (backend talabi)
    if (amount <= 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarHelper.showError(
          context,
          'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.',
        );
      }
      return;
    }

    // Invoice ID formatini Postman collection bo'yicha yaratish
    final random = DateTime.now().millisecondsSinceEpoch % 10000000;
    final invoiceId = 'hotel${random.toString().padLeft(7, '0')}';

    if (!mounted || _paymentBloc.isClosed) {
      return;
    }

    final request = InvoiceRequestModel(
      amount: amount,
      invoiceId: invoiceId,
      lang: context.locale.languageCode,
      returnUrl: 'https://kliro.uz',
      callbackUrl: 'https://api.kliro.uz/payment/callback/success',
    );

    _paymentBloc.add(CreateInvoiceRequested(request));
  }

  Future<void> _launchPaymentUrl(String checkoutUrl) async {
    try {
      if (checkoutUrl.isEmpty) {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'To\'lov linki topilmadi',
          );
        }
        return;
      }

      final uri = Uri.parse(checkoutUrl);

      // Android'da canLaunchUrl ba'zida false qaytaradi, lekin launchUrl ishlaydi
      // Shuning uchun to'g'ridan-to'g'ri launchUrl'ni chaqiramiz
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched || true) {
          // Ba'zida launchUrl false qaytaradi, lekin brauzer ochiladi
          if (mounted) {
            setState(() {
              _urlLaunched = true;
            });
            // Status polling ni boshlash
            _startStatusPolling();
          }
        }
      } catch (launchError) {
        // Fallback: canLaunchUrl tekshirish
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (mounted) {
            setState(() {
              _urlLaunched = true;
            });
            _startStatusPolling();
          }
        } else {
          if (mounted) {
            SnackbarHelper.showError(
              context,
              'To\'lov sahifasini ochib bo\'lmadi. Iltimos, qo\'lda oching: $checkoutUrl',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'To\'lov sahifasini ochishda xatolik: $e',
        );
      }
    }
  }

  void _checkPaymentStatus() {
    if (_currentInvoiceUuid != null && mounted && !_paymentBloc.isClosed) {
      _paymentBloc.add(CheckStatusRequested(_currentInvoiceUuid!));
    }
  }

  void _startStatusPolling() {
    // Avval barcha timer'larni to'xtatish
    _stopStatusPolling();
    if (_currentInvoiceUuid != null && mounted) {
      _statusPollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!mounted || _currentInvoiceUuid == null) {
          timer.cancel();
          return;
        }
        _checkPaymentStatus();
      });
    }
  }

  void _stopStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = null;
  }

  void _confirmBooking(String bookingId) {
    // Invoice UUID ni transactionId sifatida ishlatish (avia kabi)
    // Agar invoice UUID bo'lmasa, fallback ID yaratish
    final transactionId = _currentInvoiceUuid ?? 
        'hotel${DateTime.now().millisecondsSinceEpoch % 10000000}';
    
    final paymentInfo = PaymentInfo(
      paymentMethod: 'multicard', // Multicard to'lov tizimi (avia kabi)
      transactionId: transactionId,
    );

    context.read<HotelBloc>().add(
      ConfirmBookingRequested(
        bookingId: bookingId,
        paymentInfo: paymentInfo,
      ),
    );
  }


  /// Show error dialog with retry option for booking failures
  void _showBookingErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('hotel.booking.error_title'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('hotel.common.close'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Retry booking creation
              if (widget.quoteId != null && widget.selectedOption != null) {
                _proceedToPayment(context);
              }
            },
            child: Text('hotel.common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

