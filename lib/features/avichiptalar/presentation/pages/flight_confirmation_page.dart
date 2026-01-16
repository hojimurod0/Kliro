import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/offer_model.dart';
import '../widgets/primary_button.dart';
import '../../domain/constants/airline_logo_manifest.dart';

@RoutePage(name: 'FlightConfirmationRoute')
class FlightConfirmationPage extends StatefulWidget {
  final OfferModel outboundOffer;
  final OfferModel? returnOffer;
  final String totalPrice;
  final String currency;
  final int adults;
  final int childrenCount;
  final int babies;

  const FlightConfirmationPage({
    super.key,
    required this.outboundOffer,
    this.returnOffer,
    required this.totalPrice,
    required this.currency,
    this.adults = 1,
    this.childrenCount = 0,
    this.babies = 0,
  });

  @override
  State<FlightConfirmationPage> createState() => _FlightConfirmationPageState();
}

class _FlightConfirmationPageState extends State<FlightConfirmationPage> {
  late int _adults;
  late int _children;
  late int _babies;

  // Card expansion states
  bool _isFlightInfoExpanded = true;
  bool _isPassengerInfoExpanded = false;
  bool _isBookingSummaryExpanded = false;
  bool _isImportantNotesExpanded = false;

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _children = widget.childrenCount;
    _babies = widget.babies;
  }

  String _formatPrice(String price) {
    try {
      final cleanPrice = price.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanPrice.isEmpty) return price;

      final priceNum = int.tryParse(cleanPrice);
      if (priceNum == null) return price;

      // Format with spaces for thousands (e.g., 1320000 -> "1, 320 000")
      if (priceNum >= 1000000) {
        final millions = priceNum ~/ 1000000;
        final remainder = priceNum % 1000000;
        if (remainder == 0) {
          return '$millions, 000 000';
        } else {
          final remainderStr = remainder.toString().padLeft(6, '0');
          final thousands = remainderStr.substring(0, 3);
          final hundreds = remainderStr.substring(3);
          if (hundreds == '000') {
            return '$millions, $thousands 000';
          } else {
            return '$millions, $thousands $hundreds';
          }
        }
      } else if (priceNum >= 1000) {
        final thousands = priceNum ~/ 1000;
        final remainder = priceNum % 1000;
        if (remainder == 0) {
          return '$thousands 000';
        } else {
          return '$thousands ${remainder.toString().padLeft(3, '0')}';
        }
      }

      return priceNum.toString();
    } catch (e) {
      return price;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'avia.confirmation.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flight Information Card
            _buildFlightInfoCard(context, isDark),
            SizedBox(height: 14.h),

            // Passenger Information Card
            _buildPassengerInfoCard(context, isDark),
            SizedBox(height: 14.h),

            // Booking Summary Card
            _buildBookingSummaryCard(context, isDark),
            SizedBox(height: 14.h),

            // Important Notes Card
            _buildImportantNotesCard(context, isDark),
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
          child: PrimaryButton(
            text: 'avia.confirmation.next'.tr(),
            onPressed: () async {
              try {
                final authService = AuthService.instance;
                final user = await authService.fetchActiveUser();
                if (!context.mounted) return;
                final isAuthenticated = user != null;

                AppLogger.debug('Auth check: isAuthenticated = $isAuthenticated');

                if (isAuthenticated) {
                  AppLogger.success('User already authenticated, proceeding to formalization');
                  context.router.push(
                    FlightFormalizationRoute(
                      outboundOffer: widget.outboundOffer,
                      returnOffer: widget.returnOffer,
                      totalPrice: widget.totalPrice,
                      currency: widget.currency,
                      adults: _adults,
                      childrenCount: _children,
                      babies: _babies,
                    ),
                  );
                } else {
                  AppLogger.warning('User not authenticated, showing login dialog');
                  final shouldLogin = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('avia.login_required.title'.tr()),
                      content: Text('avia.login_required.message'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: Text('avia.login_required.cancel'.tr()),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: Text(
                            'avia.login_required.login'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (!context.mounted) return;

                  AppLogger.debug('User chose to login: $shouldLogin');

                  if (shouldLogin == true) {
                    final loginResult = await context.router.push(const LoginRoute());
                    if (!context.mounted) return;

                    AppLogger.debug('Login result: $loginResult');

                    final userAfterLogin = await authService.fetchActiveUser();
                    if (!context.mounted) return;
                    final isAuthenticatedAfterLogin = userAfterLogin != null;

                    AppLogger.debug('Is authenticated after login: $isAuthenticatedAfterLogin');

                    if (isAuthenticatedAfterLogin) {
                      AppLogger.success('User authenticated after login, proceeding to formalization');
                      context.router.push(
                        FlightFormalizationRoute(
                          outboundOffer: widget.outboundOffer,
                          returnOffer: widget.returnOffer,
                          totalPrice: widget.totalPrice,
                          currency: widget.currency,
                          adults: _adults,
                          childrenCount: _children,
                          babies: _babies,
                        ),
                      );
                    } else {
                      AppLogger.error('User not authenticated after login');
                      if (!context.mounted) return;
                      SnackbarHelper.showWarning(
                        context,
                        'avia.login_required.cancelled_or_failed'.tr(),
                      );
                    }
                  }
                }
              } catch (e, stackTrace) {
                AppLogger.error('Error in login flow', e, stackTrace);
                if (context.mounted) {
                  SnackbarHelper.showError(
                    context,
                    '${'avia.status.error_message'.tr()}: ${e.toString()}',
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  String? _normalizeIataCode(String? raw) {
    final c = (raw ?? '').trim().toUpperCase();
    if (c.isEmpty) return null;
    final candidates = <String>{
      c,
      if (c.length >= 2) c.substring(0, 2),
      if (c.length > 2) c.substring(c.length - 2),
    };
    for (final cand in candidates) {
      if (cand.length == 2 && airlineLogoAssetCodes.contains(cand)) {
        return cand;
      }
    }
    return null;
  }

  String? _mapAirlineNameToIata(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final normalized = name.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
    final lowerNormalized = normalized.toLowerCase();

    if (normalized.contains('UZBEK') ||
        normalized.contains('OZBEK') ||
        normalized.contains("O'ZBEK") ||
        lowerNormalized.contains('uzbek')) return 'HY';

    if (normalized.contains('FLYDUBAI') ||
        normalized.contains('FLY DUBAI') ||
        lowerNormalized.contains('flydubai') ||
        lowerNormalized.contains('fly dubai') ||
        name.contains('Флайдубай') ||
        name.contains('ФЛАЙДУБАЙ')) return 'FZ';

    return null;
  }

  String? _extractIataFromSegments(List segments) {
    if (segments.isEmpty) return null;
    final first = segments.first;
    final fn = (first.flightNumber ?? '').trim();
    if (fn.isNotEmpty) {
      final m = RegExp(r'^([A-Za-z]{2,3})').firstMatch(fn);
      if (m != null) return m.group(1)!.toUpperCase();
    }
    final a = (first.airline ?? '').trim();
    if (a.length >= 2 && a.length <= 3) return a.toUpperCase();
    return null;
  }

  String? _resolveAirlineLogoCode(List segments, {String? offerAirline}) {
    final fromSegment = _normalizeIataCode(_extractIataFromSegments(segments));
    if (fromSegment != null) return fromSegment;

    if (segments.isNotEmpty) {
      final mapped = _mapAirlineNameToIata(segments.first.airline);
      final normalized = _normalizeIataCode(mapped);
      if (normalized != null) return normalized;
    }

    if (offerAirline != null && offerAirline.trim().isNotEmpty) {
      final mapped = _mapAirlineNameToIata(offerAirline);
      final normalized = _normalizeIataCode(mapped);
      if (normalized != null) return normalized;
    }

    return null;
  }

  String? _airlineLogoPath(List segments, {String? offerAirline}) {
    final code = _resolveAirlineLogoCode(segments, offerAirline: offerAirline);
    return code == null ? null : 'assets/svgs/$code.svg';
  }

  Widget _buildFlightInfoCard(BuildContext context, bool isDark) {
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
                _isFlightInfoExpanded = !_isFlightInfoExpanded;
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
                          child: Icon(Icons.flight, color: Colors.blue, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'avia.confirmation.flight_info'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isFlightInfoExpanded) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  _getFlightSummary(),
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
                    _isFlightInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_isFlightInfoExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outbound flight
                  _buildFlightSection(
                    context: context,
                    offer: widget.outboundOffer,
                    isOutbound: true,
                    isDark: isDark,
                  ),
                  // Return flight if exists
                  if (widget.returnOffer != null) ...[
                    SizedBox(height: 20.h),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 20.h),
                    _buildFlightSection(
                      context: context,
                      offer: widget.returnOffer!,
                      isOutbound: false,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlightSection({
    required BuildContext context,
    required OfferModel offer,
    required bool isOutbound,
    required bool isDark,
  }) {
    final segments = offer.segments ?? [];
    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstSegment = segments.first;
    final lastSegment = segments.last;

    final departureDateTime = _parseDateTime(firstSegment.departureTime);
    final arrivalDateTime = _parseDateTime(lastSegment.arrivalTime);
    final duration = _calculateDuration(departureDateTime, arrivalDateTime);
    final flightNumber = firstSegment.flightNumber ?? 'N/A';
    final airline = firstSegment.airline ?? 'Uzbekistan Airways';
    final logoPath = _airlineLogoPath(segments, offerAirline: airline);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOutbound) ...[
            Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: Colors.blue),
                SizedBox(width: 8.w),
                Text(
                  'avia.booking_details.return_flight'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    logoPath != null
                        ? SizedBox(
                            height: 20.h,
                            child: SvgPicture.asset(
                              logoPath,
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                            ),
                          )
                        : Text(
                            airline,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    Text(
                      '${'avia.confirmation.flight'.tr()} $flightNumber',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.grey.shade600),
                    SizedBox(width: 4.w),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(departureDateTime),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(departureDateTime),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      firstSegment.departureAirport ?? 'TAS',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      firstSegment.departureAirportName ?? _getCityName(firstSegment.departureAirport ?? ''),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                        RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.flight,
                            color: Colors.blue,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (segments.length > 1)
                      Text(
                        'avia.details.transit_count'.tr(namedArgs: {'count': '${segments.length - 1}'}),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.red,
                        ),
                      )
                    else
                      Text(
                        'avia.filter.direct'.tr(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(arrivalDateTime),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(arrivalDateTime),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      lastSegment.arrivalAirport ?? 'DXB',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      lastSegment.arrivalAirportName ?? _getCityName(lastSegment.arrivalAirport ?? ''),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfoCard(BuildContext context, bool isDark) {
    final totalPassengers = _adults + _children + _babies;
    final passengerSummary = _getPassengerSummary();

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
                _isPassengerInfoExpanded = !_isPassengerInfoExpanded;
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
                                'avia.confirmation.selected_passengers'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isPassengerInfoExpanded) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  passengerSummary,
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
                    _isPassengerInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_isPassengerInfoExpanded) ...[
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
                        _buildInfoRowWithIcon(
                          Icons.people,
                          'avia.confirmation.total_passengers'.tr(),
                          '$totalPassengers ${totalPassengers == 1 ? 'avia.confirmation.passenger_count'.tr() : 'avia.confirmation.passenger_count'.tr()}',
                        ),
                        if (_adults > 0) ...[
                          SizedBox(height: 12.h),
                          _buildInfoRowWithIcon(
                            Icons.person,
                            'avia.confirmation.adults'.tr(),
                            '$_adults',
                          ),
                        ],
                        if (_children > 0) ...[
                          SizedBox(height: 12.h),
                          _buildInfoRowWithIcon(
                            Icons.child_care,
                            'avia.confirmation.children'.tr(),
                            '$_children',
                          ),
                        ],
                        if (_babies > 0) ...[
                          SizedBox(height: 12.h),
                          _buildInfoRowWithIcon(
                            Icons.baby_changing_station,
                            'avia.confirmation.babies'.tr(),
                            '$_babies',
                          ),
                        ],
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

  Widget _buildBookingSummaryCard(BuildContext context, bool isDark) {
    final formattedPrice = _formatPrice(widget.totalPrice);

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
                                'avia.confirmation.total'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isBookingSummaryExpanded) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  '$formattedPrice ${widget.currency.toUpperCase()}',
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
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'avia.confirmation.total'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$formattedPrice ${widget.currency.toUpperCase()}',
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportantNotesCard(BuildContext context, bool isDark) {
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.info_outline, color: Colors.red, size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'avia.confirmation.important_notes'.tr(),
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
                  _buildNoteItem('• ${'avia.confirmation.note_passport'.tr()}'),
                  SizedBox(height: 8.h),
                  _buildNoteItem('• ${'avia.confirmation.note_checkin'.tr()}'),
                  SizedBox(height: 8.h),
                  _buildNoteItem('• ${'avia.confirmation.note_cancellation'.tr()}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.grey.shade700,
        height: 1.5,
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.blue),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getFlightSummary() {
    final segments = widget.outboundOffer.segments ?? [];
    if (segments.isEmpty) return '';
    final first = segments.first;
    final last = segments.last;
    return '${first.departureAirport ?? ''} → ${last.arrivalAirport ?? ''}';
  }

  String _getPassengerSummary() {
    final parts = <String>[];
    if (_adults > 0) parts.add('$_adults ${_adults == 1 ? 'avia.confirmation.adult'.tr() : 'avia.confirmation.adults'.tr()}');
    if (_children > 0) parts.add('$_children ${_children == 1 ? 'avia.confirmation.child'.tr() : 'avia.confirmation.children'.tr()}');
    if (_babies > 0) parts.add('$_babies ${_babies == 1 ? 'avia.confirmation.baby'.tr() : 'avia.confirmation.babies'.tr()}');
    return parts.isEmpty ? 'avia.confirmation.no_passengers'.tr() : parts.join(', ');
  }

  DateTime? _parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return null;
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('d MMM, EEE').format(dateTime);
  }

  String _calculateDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '--';
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _getCityName(String airportCode) {
    final cityMap = {
      'TAS': 'Tashkent',
      'DXB': 'Dubai',
      'IST': 'Istanbul',
      'MOW': 'Moscow',
      'JFK': 'New York',
      'LHR': 'London',
      'CDG': 'Paris',
    };
    return cityMap[airportCode] ?? airportCode;
  }
}
