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
    try {
      // Parse base price (price for 1 passenger)
      final basePriceStr = widget.totalPrice.replaceAll(RegExp(r'[^\d]'), '');
      final basePrice = double.tryParse(basePriceStr) ?? 0;

      if (basePrice == 0) return widget.totalPrice;

      // Calculate total: adults pay full price, children usually 75%, babies usually 10%
      final adultsPrice = basePrice * _adults;
      final childrenPrice = basePrice * 0.75 * _children;
      final babiesPrice = basePrice * 0.1 * _babies;

      final totalPrice = (adultsPrice + childrenPrice + babiesPrice).toInt();

      // Format price
      return _formatPrice(totalPrice.toString());
    } catch (e) {
      return widget.totalPrice;
    }
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

    // Get flight info
    final flightNumber = firstSegment.flightNumber ?? 'N/A';
    final aircraft = 'Boeing 737-700'; // Default, can be from API

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flight info header
        Text(
          '${'avia.confirmation.flight'.tr()} $flightNumber | $aircraft | ${'avia.confirmation.economy'.tr()}',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.getSubtitleColor(isDark),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        // Departure
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(departureDateTime),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (departureDateTime != null)
                    Text(
                      _formatDate(departureDateTime),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.getSubtitleColor(isDark),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Text(
                    _getCityName(firstSegment.departureAirport ?? ''),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getAirportName(firstSegment.departureAirport ?? ''),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSubtitleColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.flight_takeoff_rounded,
              color: AppColors.primaryBlue,
              size: 24.sp,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        // Arrival
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(arrivalDateTime),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDark),
              ),
            ),
            SizedBox(height: 4.h),
            if (arrivalDateTime != null)
              Text(
                _formatDate(arrivalDateTime),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.getSubtitleColor(isDark),
                ),
              ),
            SizedBox(height: 8.h),
            Text(
              _getCityName(lastSegment.arrivalAirport ?? ''),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(isDark),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _getAirportName(lastSegment.arrivalAirport ?? ''),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.getSubtitleColor(isDark),
              ),
            ),
          ],
        ),
        // Transit info if exists
        if (segments.length > 1) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            _getTransitInfo(segments, arrivalDateTime),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.getSubtitleColor(isDark),
            ),
          ),
        ],
        // Return flight departure info
        if (!isOutbound && widget.returnOffer != null) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            _getReturnDepartureInfo(widget.returnOffer!),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.getSubtitleColor(isDark),
            ),
          ),
        ],
      ],
    );
  }

  DateTime? _parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return null;
    try {
      if (dateTimeStr.contains('T')) {
        return DateTime.parse(dateTimeStr);
      }
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'avia.months.english.jan'.tr(),
      'avia.months.english.feb'.tr(),
      'avia.months.english.mar'.tr(),
      'avia.months.english.apr'.tr(),
      'avia.months.english.may'.tr(),
      'avia.months.english.jun'.tr(),
      'avia.months.english.jul'.tr(),
      'avia.months.english.aug'.tr(),
      'avia.months.english.sep'.tr(),
      'avia.months.english.oct'.tr(),
      'avia.months.english.nov'.tr(),
      'avia.months.english.dec'.tr(),
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${weekdays[dateTime.weekday - 1]}';
  }

  String _getCityName(String airportCode) {
    // Map airport codes to city names
    final cityMap = {
      'TAS': 'Tashkent',
      'DXB': 'Dubai',
      'IST': 'Istanbul',
      'MOW': 'Moscow',
    };
    return cityMap[airportCode] ?? airportCode;
  }

  String _getAirportName(String airportCode) {
    // Map airport codes to airport names
    final airportMap = {
      'TAS': 'Mezhdunarodniy Aeroport Tashkent, TAS',
      'DXB': 'Dubai, DXB (Terminal 3)',
      'IST': 'Istanbul Airport, IST',
      'MOW': 'Moscow Airport, MOW',
    };
    return airportMap[airportCode] ?? airportCode;
  }

  String _getTransitInfo(List<SegmentModel> segments, DateTime? arrivalTime) {
    if (segments.length <= 1 || arrivalTime == null) return '';
    // Calculate transit time (simplified)
    return 'Arrival: ${_formatTime(arrivalTime)}, ${_formatDate(arrivalTime)}. In transit: 4 h (local airport time)';
  }

  String _getReturnDepartureInfo(OfferModel returnOffer) {
    final segments = returnOffer.segments ?? [];
    if (segments.isEmpty) return '';
    final firstSegment = segments.first;
    final departureDateTime = _parseDateTime(firstSegment.departureTime);
    if (departureDateTime == null) return '';
    return 'Departure: ${_formatTime(departureDateTime)}, ${_formatDate(departureDateTime)}. (local departure airport time)';
  }
}
