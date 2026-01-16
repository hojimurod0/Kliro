import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../bloc/avia_bloc.dart';
import '../widgets/custom_input.dart';
import '../widgets/airport_input.dart';
import '../widgets/primary_button.dart';
import '../widgets/passenger_selector_dialog.dart';
import '../../data/models/search_offers_request_model.dart';
import 'flight_results_screen.dart';

@RoutePage(name: 'FlightSearchRoute')
class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  late AviaBloc _aviaBloc;
  final _fromCityController = TextEditingController();
  final _toCityController = TextEditingController();
  final _departureDateController = TextEditingController();
  final _returnDateController = TextEditingController();

  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  int _infantsWithSeat = 0;
  bool _isRoundTrip = true;

  // Aeroport kodlarini saqlash
  String? _fromAirportCode;
  String? _toAirportCode;

  @override
  void initState() {
    super.initState();
    // ALWAYS use bloc from widget tree (provided by AvichiptalarModule)
    // DO NOT create a new instance from ServiceLocator
    // This ensures we use the SAME bloc instance throughout the flow
    _aviaBloc = context.read<AviaBloc>();
  }

  @override
  void dispose() {
    _fromCityController.dispose();
    _toCityController.dispose();
    _departureDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _selectPassengers() async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (_) => PassengerSelectorDialog(
        initialAdults: _adults,
        initialChildren: _children,
        initialInfants: _infants,
        initialInfantsWithSeat: _infantsWithSeat,
      ),
    );
    if (result != null) {
      setState(() {
        _adults = result['adults'] ?? 1;
        _children = result['children'] ?? 0;
        _infants = result['infants'] ?? 0;
        _infantsWithSeat = result['infantsWithSeat'] ?? 0;
      });
    }
  }

  void _searchFlights() {
    final departureDate = _parseDate(_departureDateController.text);
    final returnDate =
        _isRoundTrip ? _parseDate(_returnDateController.text) : null;

    if (departureDate == null) {
      SnackbarHelper.showError(
        context,
        'avia.search.select_departure_date'.tr(),
      );
      return;
    }

    // Aeroport kodlarini ishlatish, agar mavjud bo'lsa
    final fromAirport = _fromAirportCode ?? _fromCityController.text.trim();
    final toAirport = _toAirportCode ?? _toCityController.text.trim();

    if (fromAirport.isEmpty || toAirport.isEmpty) {
      SnackbarHelper.showError(context, 'avia.search.fill_fields'.tr());
      return;
    }

    // Agar aeroportlar bir xil bo'lsa, xatolik ko'rsatish
    if (fromAirport == toAirport) {
      SnackbarHelper.showError(context, 'avia.search.same_airports'.tr());
      return;
    }

    final request = SearchOffersRequestModel(
      adults: _adults,
      children: _children,
      infants: _infants,
      infantsWithSeat: _infantsWithSeat,
      serviceClass: 'A',
      directions: [
        DirectionModel(
          departureAirport: fromAirport,
          arrivalAirport: toAirport,
          date: _formatDate(departureDate),
        ),
        if (returnDate != null)
          DirectionModel(
            departureAirport: toAirport,
            arrivalAirport: fromAirport,
            date: _formatDate(returnDate),
          ),
      ],
    );

    // Event yuborish - navigation BlocListener orqali qilinadi
    // Bu hotel qismidagi kabi ishlaydi - state o'zgarganda navigation qilinadi
    _aviaBloc.add(SearchOffersRequested(request));
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _getPassengerText() {
    final total = _adults + _children + _infants + _infantsWithSeat;
    if (total == 1) {
      return '01 ${'avia.search.person'.tr()}';
    }
    return '${total.toString().padLeft(2, '0')} ${'avia.search.persons'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _aviaBloc,
      child: BlocListener<AviaBloc, AviaState>(
        bloc: _aviaBloc,
        listener: (context, state) {
          if (!mounted) return;

          if (state is AviaSearchLoading) {
            // Loading holatida results screen'ga o'tish
            if (kDebugMode) {
              AppLogger.debug(
                  'FlightSearchScreen: AviaSearchLoading - navigating to results');
              AppLogger.debug('🔥 Navigation bloc hash: ${_aviaBloc.hashCode}');
            }
            // Use Navigator.push with MaterialPageRoute to preserve bloc instance
            // Auto_route doesn't support passing BlocProvider.value directly
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: _aviaBloc,
                  child: const FlightResultsScreen(),
                ),
              ),
            );
          } else if (state is AviaSearchFailure) {
            if (kDebugMode) {
              AppLogger.error(
                  'FlightSearchScreen: AviaSearchFailure - ${state.message}');
            }
            SnackbarHelper.showError(
              context,
              '${'avia.common.error'.tr()}: ${state.message}',
            );
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'avia.title'.tr(),
              style: AppTypography.headingL(context).copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: theme.iconTheme.color),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isRoundTrip = true),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: _isRoundTrip
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Center(
                                child: Text(
                                  'avia.search.round_trip'.tr(),
                                  style: TextStyle(
                                    color: _isRoundTrip
                                        ? AppColors.white
                                        : theme.textTheme.titleLarge?.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isRoundTrip = false),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: !_isRoundTrip
                                    ? AppColors.primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Center(
                                child: Text(
                                  'avia.search.one_way'.tr(),
                                  style: TextStyle(
                                    color: !_isRoundTrip
                                        ? AppColors.white
                                        : theme.textTheme.titleLarge?.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // From City
                  AirportInput(
                    label: 'avia.search.from'.tr(),
                    hint: 'avia.search.from_hint'.tr(),
                    icon: Icons.flight_takeoff,
                    controller: _fromCityController,
                    onAirportSelected: (airport) {
                      // Aeroport tanlanganda kodini saqlash
                      setState(() {
                        _fromAirportCode = airport.code;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _fromAirportCode = null;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  // To City
                  AirportInput(
                    label: 'avia.search.to'.tr(),
                    hint: 'avia.search.to_hint'.tr(),
                    icon: Icons.flight_land,
                    controller: _toCityController,
                    onAirportSelected: (airport) {
                      // Aeroport tanlanganda kodini saqlash
                      setState(() {
                        _toAirportCode = airport.code;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _toAirportCode = null;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          label: 'avia.search.departure_date'.tr(),
                          hint: 'avia.search.date_hint'.tr(),
                          icon: Icons.calendar_today,
                          controller: _departureDateController,
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _departureDateController),
                        ),
                      ),
                      if (_isRoundTrip) ...[
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomInput(
                            label: 'avia.search.return_date'.tr(),
                            hint: 'avia.search.date_hint'.tr(),
                            icon: Icons.calendar_today,
                            controller: _returnDateController,
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, _returnDateController),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Passengers
                  InkWell(
                    onTap: _selectPassengers,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: theme.iconTheme.color ?? AppColors.grayText,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'avia.search.passengers'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7) ??
                                  Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _getPassengerText(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color:
                                theme.iconTheme.color?.withValues(alpha: 0.5) ??
                                    Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Search Button
                  BlocBuilder<AviaBloc, AviaState>(
                    bloc: _aviaBloc,
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'avia.search.search_button'.tr(),
                        isLoading: state is AviaSearchLoading,
                        onPressed:
                            state is AviaSearchLoading ? null : _searchFlights,
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
