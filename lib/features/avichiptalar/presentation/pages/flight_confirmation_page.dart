import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/offer_model.dart';
import '../widgets/primary_button.dart';

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

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _children = widget.childrenCount;
    _babies = widget.babies;
  }

  // Calculate total price based on number of passengers
  String _calculateTotalPrice() {
    return widget.totalPrice;
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
      backgroundColor: AppColors.getScaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getCardBg(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.getTextColor(isDark),
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'avia.confirmation.title'.tr(),
          style: TextStyle(
            color: AppColors.getTextColor(isDark),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Flight info card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.getCardBg(isDark),
                      borderRadius: BorderRadius.circular(16.r),
                      border: isDark
                          ? Border.all(color: AppColors.darkBorder, width: 1)
                          : null,
                    ),
                    padding: EdgeInsets.all(AppSpacing.md),
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
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.getBorderColor(isDark),
                          ),
                          SizedBox(height: AppSpacing.md),
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
                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          // Footer with price and button
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.getCardBg(isDark),
              border: isDark
                  ? Border(
                      top: BorderSide(color: AppColors.darkBorder, width: 1),
                    )
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'avia.confirmation.total'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.getSubtitleColor(isDark),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${_calculateTotalPrice()} ${widget.currency}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: PrimaryButton(
                        text: 'avia.confirmation.next'.tr(),
                        onPressed: () async {
                          try {
                            // First check if user is authenticated via AuthService
                            final authService = AuthService.instance;
                            final user = await authService.fetchActiveUser();
                            if (!context.mounted) return;
                            final isAuthenticated = user != null;

                            AppLogger.debug(
                                'Auth check: isAuthenticated = $isAuthenticated');

                            if (isAuthenticated) {
                              // User is already logged in, proceed directly to formalization
                              AppLogger.success(
                                  'User already authenticated, proceeding to formalization');
                              context.router.push(
                                FlightFormalizationRoute(
                                  outboundOffer: widget.outboundOffer,
                                  returnOffer: widget.returnOffer,
                                  totalPrice: _calculateTotalPrice(),
                                  currency: widget.currency,
                                  adults: _adults,
                                  childrenCount: _children,
                                  babies: _babies,
                                ),
                              );
                            } else {
                              // User is not logged in, show login dialog
                              AppLogger.warning(
                                  'User not authenticated, showing login dialog');

                              final shouldLogin = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text('avia.login_required.title'.tr()),
                                  content:
                                      Text('avia.login_required.message'.tr()),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext)
                                              .pop(false),
                                      child: Text(
                                          'avia.login_required.cancel'.tr()),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                      ),
                                      child: Text(
                                        'avia.login_required.login'.tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (!context.mounted) return;

                              AppLogger.debug(
                                  'User chose to login: $shouldLogin');

                              if (shouldLogin == true) {
                                // Navigate to main login page
                                final loginResult = await context.router
                                    .push(const LoginRoute());
                                if (!context.mounted) return;

                                AppLogger.debug('Login result: $loginResult');

                                // After login, check if user is now authenticated
                                final userAfterLogin =
                                    await authService.fetchActiveUser();
                                if (!context.mounted) return;
                                final isAuthenticatedAfterLogin =
                                    userAfterLogin != null;

                                AppLogger.debug(
                                    'Is authenticated after login: $isAuthenticatedAfterLogin');

                                if (isAuthenticatedAfterLogin) {
                                  AppLogger.success(
                                      'User authenticated after login, proceeding to formalization');

                                  // Proceed to formalization
                                  context.router.push(
                                    FlightFormalizationRoute(
                                      outboundOffer: widget.outboundOffer,
                                      returnOffer: widget.returnOffer,
                                      totalPrice: _calculateTotalPrice(),
                                      currency: widget.currency,
                                      adults: _adults,
                                      childrenCount: _children,
                                      babies: _babies,
                                    ),
                                  );
                                } else {
                                  AppLogger.error(
                                      'User not authenticated after login');
                                  if (!context.mounted) return;
                                  SnackbarHelper.showWarning(
                                    context,
                                    'avia.login_required.cancelled_or_failed'
                                        .tr(),
                                  );
                                }
                              }
                            }
                          } catch (e, stackTrace) {
                            AppLogger.error(
                                'Error in login flow', e, stackTrace);

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
                  ],
                ),
              ],
            ),
          ),
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

    // Parse dates
    final departureDateTime = _parseDateTime(firstSegment.departureTime);
    final arrivalDateTime = _parseDateTime(lastSegment.arrivalTime);
    
    // Calculate total duration
    final duration = _calculateDuration(departureDateTime, arrivalDateTime);

    // Get flight info
    final flightNumber = firstSegment.flightNumber ?? 'N/A';
    final aircraft = firstSegment.aircraft ?? 'Boeing 737'; 
    final airline = firstSegment.airline ?? 'Uzbekistan Airways'; // Fallback or use data

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Airline Icon/Name and Total Duration
        Row(
          children: [
            // Airline Logo Placeholder (Circle with Airline Code or Icon)
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.airlines_rounded,
                color: AppColors.primaryBlue,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airline,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  Text(
                    '${'avia.confirmation.flight'.tr()} $flightNumber • $aircraft',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSubtitleColor(isDark),
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
                  Icon(
                    Icons.access_time_rounded,
                    size: 12.sp,
                    color: AppColors.getSubtitleColor(isDark),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSpacing.lg),

        // Route Visualizer (Departure -> Visual -> Arrival)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Departure
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
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  Text(
                    _formatDate(departureDateTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSubtitleColor(isDark),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    firstSegment.departureAirport ?? 'TAS',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    firstSegment.departureAirportName ?? _getCityName(firstSegment.departureAirport ?? ''),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getTextColor(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Visual Path
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Divider(
                        color: AppColors.getBorderColor(isDark),
                        thickness: 1,
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          Icons.flight,
                          color: AppColors.primaryBlue,
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
                        color: AppColors.dangerRed,
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

            // Arrival
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
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  Text(
                    _formatDate(arrivalDateTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSubtitleColor(isDark),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    lastSegment.arrivalAirport ?? 'DXB',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    lastSegment.arrivalAirportName ?? _getCityName(lastSegment.arrivalAirport ?? ''),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getTextColor(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
         
        // Return flight label if requested
        if (!isOutbound && widget.returnOffer != null) ...[
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: AppColors.primaryBlue),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'avia.booking_details.return_flight'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
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
    // uses the current default locale set by easy_localization
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
    // Basic fallback map, ideally this should come from API/Model
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
