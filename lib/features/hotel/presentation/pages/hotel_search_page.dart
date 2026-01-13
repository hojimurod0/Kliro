import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/city.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/city_input.dart';
import 'hotel_results_page.dart'; // Import Results page
import 'hotel_loading_page.dart'; // Import Loading page
import 'guest_selector_page.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({Key? key}) : super(key: key);

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  final TextEditingController _cityController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;
  int? _selectedCityId;
  int? _selectedHotelId;
  List<City> _citiesList = [];

  @override
  void initState() {
    super.initState();
    // No need to preload cities; HotelInput will fetch hotels list on focus
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _onSearch() {
    // Validation
    if (_selectedHotelId == null &&
        _selectedCityId == null &&
        _cityController.text.trim().isEmpty) {
      SnackbarHelper.showError(
        context,
        'hotel.search.select_city'.tr(),
      );
      return;
    }

    if (_checkInDate == null || _checkOutDate == null) {
      SnackbarHelper.showError(
        context,
        'hotel.search.select_dates'.tr(),
      );
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!) ||
        _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      SnackbarHelper.showError(
        context,
        'hotel.search.invalid_dates'.tr(),
      );
      return;
    }

    // Agar hotel tanlangan bo'lsa, to'g'ridan-to'g'ri hotelIds bilan ishlaymiz
    if (_selectedHotelId != null) {
      if (_checkInDate == null || _checkOutDate == null) {
        SnackbarHelper.showError(
          context,
          'hotel.search.select_dates'.tr(),
        );
        return;
      }

      final occupancies = [
        Occupancy(
          adults: _adults,
          childrenAges: [],
        ),
      ];

      final filter = HotelFilter(
        hotelIds: [_selectedHotelId!],
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        occupancies: occupancies,
        currency: 'uzs',
        nationality: 'uz',
        residence: 'uz',
        isResident: false,
        city: _cityController.text,
        guests: _adults,
      );
      context.read<HotelBloc>().add(SearchHotelsRequested(filter));
      return;
    }

    // City ID ni aniqlash
    int? cityId = _selectedCityId;

    // Agar city_id yo'q bo'lsa, city name dan topishga harakat qilamiz
    if (cityId == null && _cityController.text.trim().isNotEmpty) {
      final cityName = _cityController.text.trim().toLowerCase();
      // Cities list'dan qidirish
      final foundCity = _citiesList.firstWhere(
        (city) {
          final cityNameLower = city.name.toLowerCase();
          final namesLower =
              city.names?.values.map((v) => v.toLowerCase()).toList() ?? [];
          return cityNameLower.contains(cityName) ||
              cityName.contains(cityNameLower) ||
              namesLower
                  .any((n) => n.contains(cityName) || cityName.contains(n));
        },
        orElse: () => const City(id: 0, name: ''),
      );

      if (foundCity.id != 0) {
        cityId = foundCity.id;
      }
    }

    if (cityId == null) {
      SnackbarHelper.showError(
        context,
        'hotel.search.city_not_found'.tr(),
      );
      return;
    }

    // Occupancies yaratish (simple logic: divide adults among rooms if needed, or 1 room per occupancy?)
    // API logic suggests occupancies list. For now, creating 1 occupancy per room or 1 unified occupancy.
    // If multiple rooms, usually we list multiple occupancies.
    // Assuming 1 search param for simple view.
    final occupancies = List.generate(
        _rooms,
        (index) => Occupancy(
              adults: (_adults / _rooms)
                  .ceil(), // Distribute adults roughly? Or just 1 per room?
              // Simple logic: Put all adults/children in first room or duplicate?
              // Let's stick to 1 occupancy with total adults/children for now unless API requires distinct rooms.
              // Actually, HotelFilter has 'rooms' and 'guests' legacy fields, and 'occupancies'.
              // Let's create `_rooms` number of occupancies.
              childrenAges: [],
            ));

    // Better Logic: Just 1 occupancy with all people, as UI doesn't split them.
    // BUT we must pass 'rooms' count if API supports it separate from occupancies length.
    // HotelFilter has 'rooms'. Let's use that.

    final filter = HotelFilter(
      cityId: cityId,
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      occupancies: occupancies,
      currency: 'uzs',
      nationality: 'uz',
      residence: 'uz',
      isResident: false,
      // Legacy support
      city: _cityController.text,
      guests: _adults,
      rooms: _rooms,
    );
    context.read<HotelBloc>().add(SearchHotelsRequested(filter));
    // Note: The BlocListener in build() will handle navigation to loading/results page
  }

  void _showGuestSelector() async {
    final result = await Navigator.of(context).push<Map<String, int>>(
      MaterialPageRoute(
        builder: (context) => GuestSelectorPage(
          initialAdults: _adults,
          initialChildren: _children,
          initialRooms: _rooms,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _adults = result['adults'] ?? 1;
        _children = result['children'] ?? 0;
        _rooms = result['rooms'] ?? 1;
      });
    }
  }

  Future<void> _selectCheckInDate() async {
    final now = DateTime.now();
    final initialDate = _checkInDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primaryBlue,
                    onPrimary: AppColors.white,
                    onSurface: AppColors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.primaryBlue,
                    onPrimary: AppColors.white,
                    onSurface: AppColors.black,
                  ),
            dialogBackgroundColor:
                isDark ? AppColors.darkCardBg : AppColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        // If checkout is before checkin, automatically adjust it
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = _checkInDate!.add(const Duration(days: 1));
        }
      });
      // Automatically open check-out picker if it wasn't set or was reset
      if (_checkOutDate == null) {
        _selectCheckOutDate();
      }
    }
  }

  Future<void> _selectCheckOutDate() async {
    final now = DateTime.now();
    // Start date for checkout must be checkin date or today
    final firstDate = _checkInDate ?? now;
    final initialDate = _checkOutDate ?? firstDate.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primaryBlue,
                    onPrimary: AppColors.white,
                    onSurface: AppColors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.primaryBlue,
                    onPrimary: AppColors.white,
                    onSurface: AppColors.black,
                  ),
            dialogBackgroundColor:
                isDark ? AppColors.darkCardBg : AppColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'hotel.search.title'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        body: BlocListener<HotelBloc, HotelState>(
          listener: (context, state) {
            // Получаем список городов из блока
            if (state is HotelCitiesWithIdsSuccess) {
              setState(() {
                _citiesList = state.cities;
              });
            }

            if (state is HotelSearchLoading) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HotelLoadingPage(
                    filter: state.filter, // Ensure loading state has filter
                  ),
                ),
              );
            } else if (state is HotelSearchSuccess) {
              // Close Loading Page (if it was open) and remove it from stack
              // Then navigate to Results Page
              final hotelBloc = context.read<HotelBloc>();

              // Remove loading page and navigate to results
              // This ensures that when user goes back from results, they go to search page, not loading page
              // First, pop the loading page if it exists
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              // Then push results page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: hotelBloc,
                    child: HotelResultsPage(
                      result: state.result,
                      city: _cityController.text,
                      checkInDate: _checkInDate,
                      checkOutDate: _checkOutDate,
                      guests: _adults,
                      filter: null,
                    ),
                  ),
                ),
              );
            } else if (state is HotelSearchFailure) {
              // Close Loading Page
              Navigator.of(context).pop();
              // Show error with retry option
              _showSearchErrorDialog(context, state.message, state.filter);
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Form Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // City Input with list of cities
                      CityInput(
                        label: 'hotel.search.city_or_hotel'.tr(),
                        hint: 'hotel.search.city_hint'.tr(),
                        icon: Icons.location_on,
                        controller: _cityController,
                        onCitySelected: (city) {
                          setState(() {
                            _selectedCityId = city.id;
                            _selectedHotelId = null;
                          });
                        },
                        onHotelSelected: (hotel) {
                          setState(() {
                            _selectedCityId = null;
                            _selectedHotelId = hotel.hotelId;
                          });
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectCheckInDate,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel(
                                      'hotel.search.check_in'.tr()),
                                  SizedBox(height: 8.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14.h, horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20.sp,
                                          color: AppColors.primaryBlue,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _checkInDate != null
                                              ? DateFormat('dd.MM.yyyy')
                                                  .format(_checkInDate!)
                                              : 'dd.MM.yyyy',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color: _checkInDate != null
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color
                                                  : AppColors.grayText),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectCheckOutDate,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel(
                                      'hotel.search.check_out'.tr()),
                                  SizedBox(height: 8.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14.h, horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20.sp,
                                          color: AppColors.primaryBlue,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _checkOutDate != null
                                              ? DateFormat('dd.MM.yyyy')
                                                  .format(_checkOutDate!)
                                              : 'dd.MM.yyyy',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color: _checkOutDate != null
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color
                                                  : AppColors.grayText),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Guests & Rooms
                      GestureDetector(
                        onTap: _showGuestSelector,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('hotel.search.guests_rooms'
                                .tr()), // "Mehmonlar va xonalar"
                            SizedBox(height: 8.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14.h, horizontal: 12.w),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      color: AppColors.primaryBlue),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      '$_adults ${"hotel.search.person".tr()}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(
                                      width: 1,
                                      height: 16.h,
                                      color:
                                          AppColors.gray500.withOpacity(0.3)),
                                  SizedBox(width: 12.w),
                                  const Icon(Icons.bed_outlined,
                                      color: AppColors.primaryBlue),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      '$_rooms ${"hotel.search.room".tr()}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.gray500),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _onSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: AppColors.white),
                              SizedBox(width: 8.w),
                              Text(
                                'hotel.common.search'.tr(),
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                Text(
                  'hotel.search.recommended'.tr(),
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                _buildRecommendedList(),
              ],
            ),
          ),
        ));
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color:
            Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grayText,
      ),
    );
  }

  Widget _buildRecommendedList() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/hotel_recommended_placeholder.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hyatt Regency Tashkent',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: AppColors.white.withOpacity(0.7), size: 14),
                      Text(
                        'Tashkent, Uzbekistan',
                        style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error dialog with retry option
  void _showSearchErrorDialog(
      BuildContext context, String message, HotelFilter? filter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('hotel.search.error_title'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('hotel.common.close'.tr()),
          ),
          if (filter != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<HotelBloc>().add(SearchHotelsRequested(filter));
              },
              child: Text('hotel.common.retry'.tr()),
            ),
        ],
      ),
    );
  }
}
