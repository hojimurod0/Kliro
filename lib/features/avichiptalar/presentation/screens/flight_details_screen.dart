import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/avia_bloc.dart';
import '../widgets/primary_button.dart';
import '../../data/models/offer_model.dart';

@RoutePage(name: 'FlightDetailsRoute')
class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  String _buildFlightTitle(SegmentModel segment) {
    final flightNumber = segment.flightNumber ?? '';
    final airline = segment.airline ?? '';
    if (flightNumber.isNotEmpty && airline.isNotEmpty) {
      return '$airline $flightNumber';
    } else if (flightNumber.isNotEmpty) {
      return flightNumber;
    } else if (airline.isNotEmpty) {
      return airline;
    }
    return 'avia.confirmation.flight'.tr();
  }

  String? _extractTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return null;
    try {
      // ISO format: "2025-11-08T17:10:00" yoki "2025-11-08T17:10"
      final parts = dateTime.split('T');
      if (parts.length > 1) {
        final timePart = parts[1].split(':');
        if (timePart.length >= 2) {
          return '${timePart[0]}:${timePart[1]}';
        }
      }
      // Agar faqat vaqt bo'lsa: "17:10"
      if (dateTime.contains(':')) {
        final timeParts = dateTime.split(':');
        if (timeParts.length >= 2) {
          return '${timeParts[0]}:${timeParts[1]}';
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String? _formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return null;
    try {
      final parts = dateTime.split('T');
      if (parts.isNotEmpty) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);
          final date = DateTime(year, month, day);

          final months = [
            'avia.months.full.january'.tr(),
            'avia.months.full.february'.tr(),
            'avia.months.full.march'.tr(),
            'avia.months.full.april'.tr(),
            'avia.months.full.may'.tr(),
            'avia.months.full.june'.tr(),
            'avia.months.full.july'.tr(),
            'avia.months.full.august'.tr(),
            'avia.months.full.september'.tr(),
            'avia.months.full.october'.tr(),
            'avia.months.full.november'.tr(),
            'avia.months.full.december'.tr(),
          ];

          final weekdays = [
            'avia.weekdays.monday'.tr(),
            'avia.weekdays.tuesday'.tr(),
            'avia.weekdays.wednesday'.tr(),
            'avia.weekdays.thursday'.tr(),
            'avia.weekdays.friday'.tr(),
            'avia.weekdays.saturday'.tr(),
            'avia.weekdays.sunday'.tr(),
          ];

          final monthName = months[(month - 1).clamp(0, 11)];
          final weekdayName = weekdays[(date.weekday - 1).clamp(0, 6)];

          return '$day $monthName, $weekdayName';
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String? _extractCityName(String? airport) {
    if (airport == null || airport.isEmpty) return null;
    // Aeroport nomidan shahar nomini ajratish
    // Masalan: "Tashkent International Airport" -> "Tashkent"
    final parts = airport.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return airport;
  }

  String? _buildTransitInfo(List<SegmentModel> segments) {
    if (segments.length < 2) return null;
    final transitCount = segments.length - 1;
    if (transitCount == 1) {
      return '${'avia.details.transit'.tr()}: ${segments[0].arrivalAirport ?? ''}';
    }
    return 'avia.details.transit_count'.tr(
      namedArgs: {'count': transitCount.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'avia.details.title'.tr(),
          style: AppTypography.headingL.copyWith(
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: BlocBuilder<AviaBloc, AviaState>(
        builder: (context, state) {
          if (state is AviaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AviaOfferDetailFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${'avia.common.error'.tr()}: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('avia.common.back'.tr()),
                  ),
                ],
              ),
            );
          }

          final offer = state is AviaOfferDetailSuccess ? state.offer : null;
          if (offer == null) {
            return Center(child: Text('avia.booking_success.data_not_found'.tr()));
          }

          final segments = offer.segments ?? [];
          if (segments.isEmpty) {
            return Center(child: Text('avia.booking_success.data_not_found'.tr()));
          }

          // Birinchi parvoz (borish)
          final firstSegment = segments.first;
          final lastSegment = segments.length > 1 ? segments.last : firstSegment;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FlightInfoCard(
                        title: _buildFlightTitle(firstSegment),
                        departure: _FlightInfo(
                          time: _extractTime(firstSegment.departureTime) ?? '--:--',
                          date: _formatDate(firstSegment.departureTime) ?? '',
                          city: _extractCityName(firstSegment.departureAirport) ?? '',
                          airport: firstSegment.departureAirport ?? '',
                        ),
                        arrival: _FlightInfo(
                          time: _extractTime(lastSegment.arrivalTime) ?? '--:--',
                          date: _formatDate(lastSegment.arrivalTime) ?? '',
                          city: _extractCityName(lastSegment.arrivalAirport) ?? '',
                          airport: lastSegment.arrivalAirport ?? '',
                        ),
                        transit: segments.length > 1 ? _buildTransitInfo(segments) : null,
                        duration: offer.duration,
                      ),
                      // Qaytish parvozlari (agar mavjud bo'lsa)
                      if (segments.length > 2) ...[
                        SizedBox(height: 16.h),
                        _FlightInfoCard(
                          title: 'avia.details.return_flights'.tr(),
                          departure: _FlightInfo(
                            time: _extractTime(segments[segments.length ~/ 2].departureTime) ?? '--:--',
                            date: _formatDate(segments[segments.length ~/ 2].departureTime) ?? '',
                            city: _extractCityName(segments[segments.length ~/ 2].departureAirport) ?? '',
                            airport: segments[segments.length ~/ 2].departureAirport ?? '',
                          ),
                          arrival: _FlightInfo(
                            time: _extractTime(segments.last.arrivalTime) ?? '--:--',
                            date: _formatDate(segments.last.arrivalTime) ?? '',
                            city: _extractCityName(segments.last.arrivalAirport) ?? '',
                            airport: segments.last.arrivalAirport ?? '',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: theme.brightness == Brightness.dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'avia.confirmation.total'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          offer.price != null
                              ? () {
                                  // Parse price and add 10% commission
                                  final rawPrice = offer.price!.replaceAll(RegExp(r'[^\d.]'), '');
                                  final priceValue = double.tryParse(rawPrice) ?? 0.0;
                                  final priceWithCommission = (priceValue * 1.10).toStringAsFixed(0);
                                  final formattedPrice = priceWithCommission.replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]} ',
                                  );
                                  return '$formattedPrice ${offer.currency ?? 'sum'}';
                                }()
                              : 'avia.common.na'.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: PrimaryButton(
                        text: 'avia.formalization.formalize'.tr(),
                        onPressed: () {
                          if (offer.id != null) {
                            context.router.push(AviaBookingRoute(offerId: offer.id!));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlightInfo {
  final String time;
  final String date;
  final String city;
  final String airport;

  _FlightInfo({
    required this.time,
    required this.date,
    required this.city,
    required this.airport,
  });
}

class _FlightInfoCard extends StatelessWidget {
  final String title;
  final _FlightInfo departure;
  final _FlightInfo arrival;
  final String? transit;
  final String? duration;

  const _FlightInfoCard({
    required this.title,
    required this.departure,
    required this.arrival,
    this.transit,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            if (duration != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${'avia.results.duration'.tr()} $duration',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
            _buildFlightPoint(departure, true, context),
            if (transit != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 24.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    transit!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
            _buildFlightPoint(arrival, false, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightPoint(_FlightInfo info, bool isDeparture, BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isDeparture ? Icons.flight_takeoff : Icons.flight_land,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
            SizedBox(height: 8.h),
            Container(
              width: 2,
              height: 40.h,
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.time,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                info.date,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                info.city,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                info.airport,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
