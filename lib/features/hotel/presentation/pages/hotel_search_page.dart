import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/city.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/city_input.dart';

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
  int? _selectedCityId;
  List<City> _citiesList = [];

  @override
  void initState() {
    super.initState();
    // Load cities with IDs on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelBloc>().add(const GetCitiesWithIdsRequested(countryId: 1));
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _onSearch() {
    // Validation
    if (_selectedCityId == null && _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('hotel.search.select_city'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('hotel.search.select_dates'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!) || 
        _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('hotel.search.invalid_dates'.tr()),
          backgroundColor: Colors.red,
        ),
      );
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
          final namesLower = city.names?.values.map((v) => v.toLowerCase()).toList() ?? [];
          return cityNameLower.contains(cityName) || 
                 cityName.contains(cityNameLower) ||
                 namesLower.any((n) => n.contains(cityName) || cityName.contains(n));
        },
        orElse: () => const City(id: 0, name: ''),
      );
      
      if (foundCity.id != 0) {
        cityId = foundCity.id;
      }
    }

    if (cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('hotel.search.city_not_found'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Occupancies yaratish
    final occupancies = [
      Occupancy(
        adults: _adults,
        childrenAges: List.generate(_children, (index) => 10), // Default age 10
      ),
    ];
    
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
      guests: _adults + _children,
    );
    context.read<HotelBloc>().add(SearchHotelsRequested(filter));
  }

  void _showGuestSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hotel.search.guests_title'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            _buildCounterRow(
              'hotel.search.adults'.tr(),
              '18+',
              _adults,
              (val) => setState(() => _adults = val),
              min: 1,
            ),
            SizedBox(height: 20.h),
            _buildCounterRow(
              'hotel.search.children'.tr(),
              '0-17',
              _children,
              (val) => setState(() => _children = val),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'hotel.common.apply'.tr(),
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(
      String title, String subtitle, int value, Function(int) onChanged,
      {int min = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            Text(subtitle,
                style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed:
                  value > min ? () => onChanged(value - 1) : null,
              icon: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, size: 16.sp),
              ),
            ),
            Text('$value',
                style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 16.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _checkInDate != null && _checkOutDate != null
          ? DateTimeRange(start: _checkInDate!, end: _checkOutDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
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
      body: SingleChildScrollView(
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // City Input with Autocomplete
                  CityInput(
                    label: 'hotel.search.city'.tr(),
                    hint: 'hotel.search.city_hint'.tr(),
                    icon: Icons.location_on,
                    controller: _cityController,
                    countryId: 1, // Uzbekistan
                    onCitySelected: (city) {
                      setState(() {
                        _selectedCityId = city.id != 0 ? city.id : null;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _selectedCityId = null;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDateRange,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('hotel.search.check_in'.tr()),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 18.sp, color: Colors.blue),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _checkInDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(_checkInDate!)
                                          : 'dd/mm/yyyy',
                                      style: TextStyle(
                                          color: _checkInDate != null
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                              : Colors.grey),
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
                          onTap: _selectDateRange,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('hotel.search.check_out'.tr()),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.h, horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 18.sp, color: Colors.blue),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _checkOutDate != null
                                          ? DateFormat('dd/MM/yyyy')
                                              .format(_checkOutDate!)
                                          : 'dd/mm/yyyy',
                                      style: TextStyle(
                                          color: _checkOutDate != null
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                              : Colors.grey),
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

                  // Guests
                  GestureDetector(
                    onTap: _showGuestSelector,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('hotel.search.guests'.tr()),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 14.h, horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: Colors.blue),
                              SizedBox(width: 8.w),
                              Text(
                                '${_adults + _children} ${"hotel.search.person".tr()}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey),
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
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'hotel.common.search'.tr(),
                            style: TextStyle(
                                color: Colors.white,
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
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildRecommendedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildRecommendedList() {
    // Placeholder list
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 250.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/250x200'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 14),
                      Text(
                        'Tashkent, Uzbekistan',
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
