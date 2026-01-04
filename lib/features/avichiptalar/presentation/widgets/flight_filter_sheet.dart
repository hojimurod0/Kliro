import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/avichipta_filter.dart';
import '../../data/models/offer_model.dart';

class FlightFilterSheet extends StatefulWidget {
  final AvichiptaFilter initialFilter;
  final List<OfferModel> offers;

  const FlightFilterSheet({
    super.key,
    required this.initialFilter,
    required this.offers,
  });

  @override
  State<FlightFilterSheet> createState() => _FlightFilterSheetState();
}

class _FlightFilterSheetState extends State<FlightFilterSheet> {
  late AvichiptaFilter _filter;
  
  // Sorting options
  String _selectedSort = 'most_useful';
  
  List<Map<String, String>> get _sortOptions => [
    {'value': 'most_useful', 'label': 'avia.filter.sort_most_useful'.tr()},
    {'value': 'optimal', 'label': 'avia.filter.sort_optimal'.tr()},
    {'value': 'earlier', 'label': 'avia.filter.sort_earlier'.tr()},
    {'value': 'fastest', 'label': 'avia.filter.sort_fastest'.tr()},
  ];

  // Price range
  late RangeValues _priceRange;
  double _minPrice = 0;
  double _maxPrice = 100000000;

  // Luggage
  bool _withLuggage = false;

  // Transfers
  int? _maxTransfers; // null = any, 0 = direct, 1 = 1 transfer, 2 = 2+ transfers

  // Airlines
  final Map<String, bool> _selectedAirlines = {};
  final Map<String, int> _airlineCounts = {};

  // Service classes
  final Map<String, bool> _selectedServiceClasses = {};
  final Map<String, int> _serviceClassCounts = {};

  // Time ranges
  late RangeValues _departureTimeRange;
  late RangeValues _arrivalTimeRange;

  // Section expansion states
  final Map<String, bool> _expandedSections = {
    'sort': true,
    'price': true,
    'luggage': true,
    'return': false,
    'transfers': true,
    'airlines': true,
    'service': true,
    'time': true,
  };

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    
    // Initialize price range from offers
    _initializePriceRange();
    
    // Initialize airlines and service classes from offers
    _initializeFilters();
    
    // Initialize time ranges
    _departureTimeRange = RangeValues(
      (widget.initialFilter.departureTimeStart ?? 0).toDouble(),
      (widget.initialFilter.departureTimeEnd ?? 1440).toDouble(),
    );
    _arrivalTimeRange = RangeValues(
      (widget.initialFilter.arrivalTimeStart ?? 0).toDouble(),
      (widget.initialFilter.arrivalTimeEnd ?? 1440).toDouble(),
    );
    
    // Initialize other filters
    _selectedSort = widget.initialFilter.sortBy ?? 'most_useful';
    _withLuggage = widget.initialFilter.withLuggage ?? false;
    _maxTransfers = widget.initialFilter.maxTransfers;
    
    // Initialize selected airlines and service classes
    if (widget.initialFilter.airlines != null) {
      for (var airline in widget.initialFilter.airlines!) {
        _selectedAirlines[airline] = true;
      }
    }
    if (widget.initialFilter.serviceClasses != null) {
      for (var serviceClass in widget.initialFilter.serviceClasses!) {
        final normalized = _normalizeServiceClass(serviceClass);
        _selectedServiceClasses[normalized] = true;
      }
    }
  }

  void _initializePriceRange() {
    double min = double.infinity;
    double max = 0;
    
    for (var offer in widget.offers) {
      final priceStr = offer.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';
      final price = double.tryParse(priceStr);
      if (price != null) {
        final commissionPrice = price * 1.1; // Apply 10% commission
        if (commissionPrice < min) min = commissionPrice;
        if (commissionPrice > max) max = commissionPrice;
      }
    }
    
    if (min == double.infinity) min = 0;
    if (max == 0) max = 100000000;
    
    _minPrice = min;
    _maxPrice = max;
    
    _priceRange = RangeValues(
      widget.initialFilter.minPrice?.toDouble() ?? min,
      widget.initialFilter.maxPrice?.toDouble() ?? max,
    );
  }

  void _initializeFilters() {
    // Count airlines and service classes
    for (var offer in widget.offers) {
      if (offer.airline != null) {
        _airlineCounts[offer.airline!] = (_airlineCounts[offer.airline!] ?? 0) + 1;
      }
      
      // Count service classes from segments
      if (offer.segments != null) {
        for (var segment in offer.segments!) {
          if (segment.cabinClass != null) {
            final serviceClass = _normalizeServiceClass(segment.cabinClass!);
            _serviceClassCounts[serviceClass] = (_serviceClassCounts[serviceClass] ?? 0) + 1;
          }
        }
      }
    }
  }
  
  String _normalizeServiceClass(String cabinClass) {
    final normalized = cabinClass.toLowerCase().trim();
    // Handle common service class codes
    if (['economy', 'eco', 'y', 'e'].contains(normalized)) {
      return 'economy';
    }
    if (['business', 'biz', 'j', 'c', 'b'].contains(normalized)) {
      return 'business';
    }
    if (['first', 'f'].contains(normalized)) {
      return 'first';
    }
    return normalized;
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
  
  String _getServiceClassName(String serviceClass) {
    final normalized = _normalizeServiceClass(serviceClass);
    switch (normalized) {
      case 'economy':
        return 'avia.filter.service_economy'.tr();
      case 'business':
        return 'avia.filter.service_business'.tr();
      case 'first':
        return 'avia.filter.service_first'.tr();
      default:
        // If it's a single letter code, show full name
        if (serviceClass.length == 1) {
          switch (serviceClass.toUpperCase()) {
            case 'E':
            case 'Y':
              return 'avia.filter.service_economy'.tr();
            case 'B':
            case 'J':
            case 'C':
              return 'avia.filter.service_business'.tr();
            case 'F':
              return 'avia.filter.service_first'.tr();
            default:
              return serviceClass;
          }
        }
        return serviceClass;
    }
  }
  
  String _formatPrice(double price) {
    // Format price with spaces for thousands (e.g., 6 138 040)
    final priceStr = price.toStringAsFixed(0);
    final reversed = priceStr.split('').reversed.join();
    final formatted = reversed.replaceAllMapped(
      RegExp(r'.{3}'),
      (match) => '${match.group(0)} ',
    ).trim().split('').reversed.join();
    return formatted;
  }

  void _applyFilter() {
    final selectedAirlines = _selectedAirlines.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final selectedServiceClasses = _selectedServiceClasses.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    
    final updatedFilter = _filter.copyWith(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      airlines: selectedAirlines.isEmpty ? null : selectedAirlines,
      serviceClasses: selectedServiceClasses.isEmpty ? null : selectedServiceClasses,
      sortBy: _selectedSort,
      maxTransfers: _maxTransfers,
      withLuggage: _withLuggage,
      departureTimeStart: _departureTimeRange.start.toInt(),
      departureTimeEnd: _departureTimeRange.end.toInt(),
      arrivalTimeStart: _arrivalTimeRange.start.toInt(),
      arrivalTimeEnd: _arrivalTimeRange.end.toInt(),
    );
    
    Navigator.of(context).pop(updatedFilter);
  }

  void _resetFilter() {
    setState(() {
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _withLuggage = false;
      _maxTransfers = null;
      _selectedAirlines.clear();
      _selectedServiceClasses.clear();
      _departureTimeRange = RangeValues(0, 1440);
      _arrivalTimeRange = RangeValues(0, 1440);
      _selectedSort = 'most_useful';
    });
  }

  Widget _buildSection({
    required String key,
    required String title,
    required Widget child,
    bool isExpanded = true,
  }) {
    final expanded = _expandedSections[key] ?? isExpanded;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[key] = !expanded;
              });
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20.sp,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: child,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72.h,
        leadingWidth: 90.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _resetFilter,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'avia.filter.reset'.tr(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'avia.filter.title'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 24.sp,
                color: theme.iconTheme.color,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.all(12.w),
              constraints: const BoxConstraints(),
              tooltip: 'Close',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Column(
                children: [
                  // Sorting
                  _buildSection(
                    key: 'sort',
                    title: 'avia.filter.sort'.tr(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSort,
                          isExpanded: true,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          items: _sortOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(
                                option['label']!,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSort = value ?? 'most_useful';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Price
                  _buildSection(
                    key: 'price',
                    title: 'avia.filter.price'.tr(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatPrice(_priceRange.start)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              '${_formatPrice(_priceRange.end)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        RangeSlider(
                          values: _priceRange,
                          min: _minPrice,
                          max: _maxPrice,
                          divisions: 100,
                          activeColor: theme.colorScheme.primary,
                          inactiveColor: theme.dividerColor,
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Luggage
                  _buildSection(
                    key: 'luggage',
                    title: 'avia.filter.luggage'.tr(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'avia.filter.no_luggage'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          Switch(
                            value: _withLuggage,
                            onChanged: (value) {
                              setState(() {
                                _withLuggage = value;
                              });
                            },
                          ),
                        ],
                      ),
                  ),
                  
                  // Return and change (collapsed by default)
                  _buildSection(
                    key: 'return',
                    title: 'avia.filter.return_change'.tr(),
                    isExpanded: false,
                    child: Text(
                      'avia.filter.return_change_desc'.tr(),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  
                  // Transfers
                  _buildSection(
                    key: 'transfers',
                    title: 'avia.filter.transfers'.tr(),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSegmentedButton(
                              label: 'avia.filter.direct'.tr(),
                              selected: _maxTransfers == 0,
                              onTap: () {
                                setState(() {
                                  _maxTransfers = 0;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40.h,
                            color: theme.dividerColor,
                          ),
                          Expanded(
                            child: _buildSegmentedButton(
                              label: '1 ${'avia.filter.transfer'.tr()}',
                              selected: _maxTransfers == 1,
                              onTap: () {
                                setState(() {
                                  _maxTransfers = 1;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40.h,
                            color: theme.dividerColor,
                          ),
                          Expanded(
                            child: _buildSegmentedButton(
                              label: '2+ ${'avia.filter.transfers_plural'.tr()}',
                              selected: _maxTransfers == 2,
                              onTap: () {
                                setState(() {
                                  _maxTransfers = 2;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Airlines
                  if (_airlineCounts.isNotEmpty)
                    _buildSection(
                      key: 'airlines',
                      title: 'avia.filter.airlines'.tr(),
                      child: Column(
                        children: _airlineCounts.entries.map((entry) {
                          return CheckboxListTile(
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            subtitle: Text(
                              '(${entry.value})',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            value: _selectedAirlines[entry.key] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _selectedAirlines[entry.key] = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                  
                  // Service class
                  if (_serviceClassCounts.isNotEmpty)
                    _buildSection(
                      key: 'service',
                      title: 'avia.filter.service_class'.tr(),
                      child: Column(
                        children: _serviceClassCounts.entries.map((entry) {
                          final serviceClass = entry.key;
                          final displayName = _getServiceClassName(serviceClass);
                          return CheckboxListTile(
                            title: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            subtitle: Text(
                              '(${entry.value})',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            value: _selectedServiceClasses[serviceClass] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _selectedServiceClasses[serviceClass] = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                  
                  // Time
                  _buildSection(
                    key: 'time',
                    title: 'avia.filter.time'.tr(),
                    child: Column(
                      children: [
                        // Departure time
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            'avia.filter.departure'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_departureTimeRange.start.toInt()),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              _formatTime(_departureTimeRange.end.toInt()),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _departureTimeRange,
                          min: 0,
                          max: 1440,
                          divisions: 48,
                          activeColor: theme.colorScheme.primary,
                          inactiveColor: theme.dividerColor,
                          onChanged: (values) {
                            setState(() {
                              _departureTimeRange = values;
                            });
                          },
                        ),
                        SizedBox(height: 16.h),
                        // Arrival time
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            'avia.filter.arrival'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_arrivalTimeRange.start.toInt()),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              _formatTime(_arrivalTimeRange.end.toInt()),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: _arrivalTimeRange,
                          min: 0,
                          max: 1440,
                          divisions: 48,
                          activeColor: theme.colorScheme.primary,
                          inactiveColor: theme.dividerColor,
                          onChanged: (values) {
                            setState(() {
                              _arrivalTimeRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'avia.filter.apply'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: selected
                ? theme.textTheme.titleLarge?.color ?? Colors.black
                : theme.textTheme.bodyLarge?.color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

