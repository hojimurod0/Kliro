import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/entities/hotel.dart';
import '../bloc/hotel_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safe_network_image.dart';
import 'hotel_map_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HotelFilterPage extends StatefulWidget {
  final HotelFilter initialFilter;
  final List<dynamic>? hotels; // List of hotels to show on map

  const HotelFilterPage({
    Key? key,
    required this.initialFilter,
    this.hotels,
  }) : super(key: key);

  @override
  State<HotelFilterPage> createState() => _HotelFilterPageState();
}

class _HotelFilterPageState extends State<HotelFilterPage> {
  late RangeValues _priceRange;
  late List<bool> _selectedStars;
  String? _cancellationType;
  List<int> _selectedHotelTypes = [];
  List<int> _selectedFacilities = [];
  List<int> _selectedEquipments = [];
  bool _showMap = true; // Default ochiq - xarita ko'rinadi

  // Expandable card states
  bool _showPriceRange = true; // Default ochiq - narx diapazoni ko'rinadi
  bool _showCancellation = false;
  bool _showRoomType = false;
  bool _showHotelRating = false;
  bool _showFacilities = false;
  bool _showEquipment = false;

  // Cached reference data
  double _minPrice = 0;
  double _maxPrice = 10000000;
  List<int> _availableStars = [1, 2, 3, 4, 5];
  List<HotelType> _hotelTypes = [];
  List<Facility> _facilities = [];
  List<Equipment> _equipment = [];

  bool _isLoadingPriceRange = false;
  bool _isLoadingStars = false;
  bool _isLoadingHotelTypes = false;
  bool _isLoadingFacilities = false;
  bool _isLoadingEquipment = false;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.initialFilter.minPrice?.toDouble() ?? 0,
      widget.initialFilter.maxPrice?.toDouble() ?? 10000000,
    );
    // Ensure _selectedStars is always length 5
    _selectedStars = List.generate(5, (index) {
      if (widget.initialFilter.stars != null) {
        return widget.initialFilter.stars!.contains(index + 1);
      }
      return false;
    });
    _cancellationType = widget.initialFilter.cancellationType;
    _selectedHotelTypes = List.from(widget.initialFilter.hotelTypes ?? []);
    _selectedFacilities = List.from(widget.initialFilter.facilities ?? []);
    _selectedEquipments = List.from(widget.initialFilter.equipments ?? []);

    // Load reference data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<HotelBloc>();
        bloc.add(const GetPriceRangeRequested());
        bloc.add(const GetStarsRequested());
        bloc.add(const GetHotelTypesRequested());
        bloc.add(const GetFacilitiesRequested());
        bloc.add(const GetEquipmentRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'hotel.filter.title'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocListener<HotelBloc, HotelState>(
        listener: (context, state) {
          if (!mounted) return;

          // Update cache when new state arrives - batch setState calls
          bool shouldUpdate = false;

          if (state is HotelPriceRangeSuccess) {
            _minPrice = state.priceRange.minPrice;
            _maxPrice = state.priceRange.maxPrice;
            _isLoadingPriceRange = false;
            // Update price range if it's still default
            if (_priceRange.start == 0 && _priceRange.end == 10000000) {
              _priceRange = RangeValues(_minPrice, _maxPrice);
            }
            shouldUpdate = true;
          } else if (state is HotelPriceRangeLoading) {
            _isLoadingPriceRange = true;
            shouldUpdate = true;
          } else if (state is HotelPriceRangeFailure) {
            _isLoadingPriceRange = false;
            shouldUpdate = true;
          }

          if (state is HotelStarsSuccess) {
            _availableStars = state.stars
                .map((s) => s.value)
                .where((v) => v > 0 && v <= 5)
                .toList();
            _isLoadingStars = false;
            shouldUpdate = true;
          } else if (state is HotelStarsLoading) {
            _isLoadingStars = true;
            shouldUpdate = true;
          } else if (state is HotelStarsFailure) {
            _isLoadingStars = false;
            shouldUpdate = true;
          }

          if (state is HotelTypesSuccess) {
            _hotelTypes = state.types;
            _isLoadingHotelTypes = false;
            shouldUpdate = true;
          } else if (state is HotelTypesLoading) {
            _isLoadingHotelTypes = true;
            shouldUpdate = true;
          } else if (state is HotelTypesFailure) {
            _isLoadingHotelTypes = false;
            shouldUpdate = true;
          }

          if (state is HotelFacilitiesSuccess) {
            _facilities = state.facilities;
            _isLoadingFacilities = false;
            shouldUpdate = true;
          } else if (state is HotelFacilitiesLoading) {
            _isLoadingFacilities = true;
            shouldUpdate = true;
          } else if (state is HotelFacilitiesFailure) {
            _isLoadingFacilities = false;
            shouldUpdate = true;
          }

          if (state is HotelEquipmentSuccess) {
            _equipment = state.equipment;
            _isLoadingEquipment = false;
            shouldUpdate = true;
          } else if (state is HotelEquipmentLoading) {
            _isLoadingEquipment = true;
            shouldUpdate = true;
          } else if (state is HotelEquipmentFailure) {
            _isLoadingEquipment = false;
            shouldUpdate = true;
          }

          if (shouldUpdate && mounted) {
            setState(() {});
          }
        },
        child: BlocBuilder<HotelBloc, HotelState>(
          builder: (context, state) {
            // Use cached data
            final minPrice = _minPrice;
            final maxPrice = _maxPrice;
            final availableStars = _availableStars;
            final hotelTypes = _hotelTypes;
            final facilities = _facilities;
            final equipment = _equipment;

            return Column(
              children: [
                // Top action items: View on map and Search again
                Column(
                  children: [
                    // View on map
                    if (widget.hotels != null && widget.hotels!.isNotEmpty)
                      _buildActionItem(
                        icon: Icons.map,
                        title: 'hotel.filter.view_on_map'.tr(),
                        onTap: () {
                          final hotels = widget.hotels!.whereType<Hotel>().toList();
                          if (hotels.isEmpty) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HotelMapPage(hotels: hotels),
                            ),
                          );
                        },
                        trailing: const Icon(Icons.arrow_forward),
                      ),
                    // Search again
                    _buildActionItem(
                      icon: Icons.refresh,
                      title: 'hotel.filter.search_again'.tr(),
                      onTap: () {
                        Navigator.pop(context);
                        // This will trigger search again in the parent
                      },
                      trailing: Icon(Icons.arrow_forward),
                    ),
                    // Map preview (if expanded)
                    if (_showMap &&
                        widget.hotels != null &&
                        widget.hotels!.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildMapPreview(),
                      ),
                      SizedBox(height: 8.h),
                      Divider(height: 1),
                    ],
                  ],
                ),
                // Content - Expandable Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Range Card
                        _buildExpandableCard(
                          icon: Icons.account_balance_wallet,
                          title: 'hotel.filter.price_range'.tr(),
                          isExpanded: _showPriceRange,
                          onTap: () {
                            setState(() {
                              _showPriceRange = !_showPriceRange;
                            });
                          },
                          child: _isLoadingPriceRange
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: [
                                    SizedBox(height: 10.h),
                                    RangeSlider(
                                      values: _priceRange,
                                      min: minPrice > 0 ? minPrice : 0,
                                      max: maxPrice > minPrice
                                          ? maxPrice
                                          : minPrice + 1000,
                                      divisions: (maxPrice - minPrice) > 0
                                          ? ((maxPrice - minPrice) / 1000)
                                              .clamp(10, 50)
                                              .toInt()
                                          : 10,
                                      labels: RangeLabels(
                                        '${_formatPrice(_priceRange.start)}',
                                        '${_formatPrice(_priceRange.end)}',
                                      ),
                                      onChanged: (values) {
                                        if (values.start >= minPrice &&
                                            values.end <= maxPrice &&
                                            values.start <= values.end) {
                                          setState(() {
                                            _priceRange = values;
                                          });
                                        }
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatPrice(_priceRange.start),
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grayText),
                                        ),
                                        Text(
                                          _formatPrice(_priceRange.end),
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grayText),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: 10.h),

                        // Cancellation Policy Card
                        _buildExpandableCard(
                          icon: Icons.shield,
                          title: 'hotel.filter.cancellation'.tr(),
                          isExpanded: _showCancellation,
                          onTap: () {
                            setState(() {
                              _showCancellation = !_showCancellation;
                            });
                          },
                          child: Column(
                            children: [
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: [
                                  _buildChoiceChip(
                                    'hotel.filter.refundable'.tr(),
                                    'rf',
                                    _cancellationType == 'rf',
                                  ),
                                  _buildChoiceChip(
                                    'hotel.filter.non_refundable'.tr(),
                                    'nrf',
                                    _cancellationType == 'nrf',
                                  ),
                                  _buildChoiceChip(
                                    'hotel.filter.all'.tr(),
                                    'all',
                                    _cancellationType == 'all' ||
                                        _cancellationType == null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Room Type Card
                        if (hotelTypes.isNotEmpty || _isLoadingHotelTypes)
                          _buildExpandableCard(
                            icon: Icons.bed,
                            title: 'hotel.filter.hotel_types'.tr(),
                            isExpanded: _showRoomType,
                            onTap: () {
                              setState(() {
                                _showRoomType = !_showRoomType;
                              });
                            },
                            child: _isLoadingHotelTypes
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    children: [
                                      SizedBox(height: 10.h),
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children: hotelTypes.map((type) {
                                          final isSelected = _selectedHotelTypes
                                              .contains(type.id);
                                          final locale =
                                              context.locale.toString();
                                          final displayName =
                                              type.getDisplayName(locale);
                                          return FilterChip(
                                            label: Text(displayName, style: TextStyle(fontSize: 12.sp)),
                                            selected: isSelected,
                                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  _selectedHotelTypes
                                                      .add(type.id);
                                                } else {
                                                  _selectedHotelTypes
                                                      .remove(type.id);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                          ),
                        if (hotelTypes.isNotEmpty || _isLoadingHotelTypes)
                          SizedBox(height: 10.h),

                        // Hotel Rating (Stars) Card
                        _buildExpandableCard(
                          icon: Icons.star,
                          title: 'hotel.filter.stars'.tr(),
                          isExpanded: _showHotelRating,
                          onTap: () {
                            setState(() {
                              _showHotelRating = !_showHotelRating;
                            });
                          },
                          child: _isLoadingStars
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: [
                                    SizedBox(height: 10.h),
                                    Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children: availableStars
                                          .where((starValue) =>
                                              starValue > 0 && starValue <= 5)
                                          .map((starValue) {
                                            final index = starValue - 1;
                                            // Ensure _selectedStars has correct length
                                            if (_selectedStars.length != 5) {
                                              _selectedStars = List.generate(
                                                  5, (i) => false);
                                            }
                                            // Skip if index is invalid
                                            if (index < 0 ||
                                                index >=
                                                    _selectedStars.length) {
                                              return const SizedBox.shrink();
                                            }
                                            final isSelected =
                                                _selectedStars[index];
                                            return FilterChip(
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.star,
                                                      size: 14.sp,
                                                      color: Colors.amber),
                                                  SizedBox(width: 4.w),
                                                  Text('$starValue', style: TextStyle(fontSize: 12.sp)),
                                                ],
                                              ),
                                              selected: isSelected,
                                              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              onSelected: (selected) {
                                                if (index >= 0 &&
                                                    index <
                                                        _selectedStars.length) {
                                                  setState(() {
                                                    _selectedStars[index] =
                                                        selected;
                                                  });
                                                }
                                              },
                                            );
                                          })
                                          .where(
                                              (widget) => widget is! SizedBox)
                                          .toList(),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: 10.h),

                        // Facilities Card
                        if (facilities.isNotEmpty || _isLoadingFacilities)
                          _buildExpandableCard(
                            icon: Icons.room_service,
                            title: 'hotel.filter.facilities'.tr(),
                            isExpanded: _showFacilities,
                            onTap: () {
                              setState(() {
                                _showFacilities = !_showFacilities;
                              });
                            },
                            child: _isLoadingFacilities
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    children: [
                                      SizedBox(height: 10.h),
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children:
                                            facilities.take(15).map((facility) {
                                          final isSelected = _selectedFacilities
                                              .contains(facility.id);
                                          final locale =
                                              context.locale.toString();
                                          final displayName =
                                              facility.getDisplayName(locale);
                                          return FilterChip(
                                            label: Text(displayName, style: TextStyle(fontSize: 12.sp)),
                                            selected: isSelected,
                                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  if (!_selectedFacilities
                                                      .contains(facility.id)) {
                                                    _selectedFacilities
                                                        .add(facility.id);
                                                  }
                                                } else {
                                                  _selectedFacilities
                                                      .remove(facility.id);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                          ),
                        if (facilities.isNotEmpty || _isLoadingFacilities)
                          SizedBox(height: 10.h),

                        // Equipment Card
                        if (equipment.isNotEmpty || _isLoadingEquipment)
                          _buildExpandableCard(
                            icon: Icons.build,
                            title: 'hotel.filter.equipment'.tr(),
                            isExpanded: _showEquipment,
                            onTap: () {
                              setState(() {
                                _showEquipment = !_showEquipment;
                              });
                            },
                            child: _isLoadingEquipment
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    children: [
                                      SizedBox(height: 10.h),
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children: equipment.take(15).map((eq) {
                                          final isSelected = _selectedEquipments
                                              .contains(eq.id);
                                          final locale =
                                              context.locale.toString();
                                          final displayName =
                                              eq.getDisplayName(locale);
                                          return FilterChip(
                                            label: Text(displayName, style: TextStyle(fontSize: 12.sp)),
                                            selected: isSelected,
                                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  if (!_selectedEquipments
                                                      .contains(eq.id)) {
                                                    _selectedEquipments
                                                        .add(eq.id);
                                                  }
                                                } else {
                                                  _selectedEquipments
                                                      .remove(eq.id);
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _priceRange = RangeValues(
                                minPrice > 0 ? minPrice : 0,
                                maxPrice > minPrice
                                    ? maxPrice
                                    : minPrice + 1000,
                              );
                              _selectedStars = List.generate(5, (_) => false);
                              _cancellationType = null;
                              _selectedHotelTypes.clear();
                              _selectedFacilities.clear();
                              _selectedEquipments.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text('hotel.filter.reset'.tr()),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            // Build selected stars list safely
                            final selectedStars = <int>[];
                            for (int i = 0;
                                i < _selectedStars.length && i < 5;
                                i++) {
                              if (_selectedStars[i]) {
                                selectedStars.add(i + 1);
                              }
                            }

                            // Validate price range
                            final validMinPrice =
                                _priceRange.start >= minPrice &&
                                        _priceRange.start <= maxPrice
                                    ? _priceRange.start
                                    : minPrice;
                            final validMaxPrice = _priceRange.end >= minPrice &&
                                    _priceRange.end <= maxPrice &&
                                    _priceRange.end >= validMinPrice
                                ? _priceRange.end
                                : maxPrice;

                            final filter = widget.initialFilter.copyWith(
                              minPrice: validMinPrice,
                              maxPrice: validMaxPrice,
                              stars:
                                  selectedStars.isEmpty ? null : selectedStars,
                              cancellationType: _cancellationType,
                              hotelTypes: _selectedHotelTypes.isEmpty
                                  ? null
                                  : _selectedHotelTypes,
                              facilities: _selectedFacilities.isEmpty
                                  ? null
                                  : _selectedFacilities,
                              equipments: _selectedEquipments.isEmpty
                                  ? null
                                  : _selectedEquipments,
                            );

                            if (context.mounted) {
                              Navigator.pop(context, filter);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'hotel.filter.apply'.tr(),
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBg(
            Theme.of(context).brightness == Brightness.dark),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.getBorderColor(
                  Theme.of(context).brightness == Brightness.dark)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10.r),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Icon(icon, size: 18.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, bool selected) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      selected: selected,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (selected) {
        setState(() {
          _cancellationType = selected ? value : null;
        });
      },
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }

  Widget _buildMapPreview() {
    if (widget.hotels == null || widget.hotels!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hotels = widget.hotels!.whereType<Hotel>().toList();
    final withCoords = hotels
        .where((h) => h.latitude != null && h.longitude != null)
        .toList();

    if (withCoords.isEmpty) {
      // No coordinates to show – fallback placeholder
      return GestureDetector(
        onTap: _openMapWithHotels,
        child: Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.getCardBg(
                Theme.of(context).brightness == Brightness.dark),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 36.sp, color: AppColors.gray500),
                SizedBox(height: 6.h),
                Text(
                  'hotel.filter.map_not_available'.tr(),
                  style: TextStyle(color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final center = LatLng(withCoords.first.latitude!, withCoords.first.longitude!);
    final markers = withCoords.take(20).map<Marker>((h) {
      return Marker(
        width: 28,
        height: 28,
        point: LatLng(h.latitude!, h.longitude!),
        child: const Icon(Icons.location_on, color: Colors.redAccent, size: 24),
      );
    }).toList();

    return GestureDetector(
      onTap: _openMapWithHotels,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.getCardBg(
                Theme.of(context).brightness == Brightness.dark),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: AppColors.getBorderColor(
                      Theme.of(context).brightness == Brightness.dark)
                  .withOpacity(0.3),
            ),
          ),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uz.kliro.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMapWithHotels() async {
    if (widget.hotels == null || widget.hotels!.isEmpty || !mounted) return;

    try {
      // Open map with first hotel as center, but show all hotels
      final firstAny = widget.hotels!.first;
      if (firstAny is! Hotel) return;
      final firstHotel = firstAny as Hotel;

      // Prefer coordinates if present
      Uri url;
      if (firstHotel.latitude != null && firstHotel.longitude != null) {
        final q = '${firstHotel.latitude},${firstHotel.longitude}';
        url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
      } else {
        final query = '${firstHotel.name}, ${firstHotel.address}';
        if (query.trim().isEmpty) return;
        final encodedQuery = Uri.encodeComponent(query);
        url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('hotel.filter.map_error'.tr()),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hotel.filter.map_error'.tr()),
          ),
        );
      }
    }
  }
}

