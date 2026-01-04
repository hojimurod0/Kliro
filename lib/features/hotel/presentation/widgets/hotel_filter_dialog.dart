import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/hotel_filter.dart';
import '../../domain/entities/reference_data.dart';
import '../bloc/hotel_bloc.dart';

class HotelFilterDialog extends StatefulWidget {
  final HotelFilter initialFilter;

  const HotelFilterDialog({
    Key? key,
    required this.initialFilter,
  }) : super(key: key);

  @override
  State<HotelFilterDialog> createState() => _HotelFilterDialogState();
}

class _HotelFilterDialogState extends State<HotelFilterDialog> {
  late RangeValues _priceRange;
  late List<bool> _selectedStars;
  String? _cancellationType;
  List<int> _selectedHotelTypes = [];
  List<int> _selectedFacilities = [];
  List<int> _selectedEquipments = [];
  
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
    _selectedStars = List.generate(5, (index) {
      if (widget.initialFilter.stars != null) {
        return widget.initialFilter.stars!.contains(index + 1);
      }
      return false;
    });
    _cancellationType = widget.initialFilter.cancellationType;
    _selectedHotelTypes = widget.initialFilter.hotelTypes ?? [];
    _selectedFacilities = widget.initialFilter.facilities ?? [];
    _selectedEquipments = widget.initialFilter.equipments ?? [];

    // Load reference data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelBloc>().add(const GetPriceRangeRequested());
      context.read<HotelBloc>().add(const GetStarsRequested());
      context.read<HotelBloc>().add(const GetHotelTypesRequested());
      context.read<HotelBloc>().add(const GetFacilitiesRequested());
      context.read<HotelBloc>().add(const GetEquipmentRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HotelBloc, HotelState>(
      listener: (context, state) {
        // Update cache when new state arrives
        if (state is HotelPriceRangeSuccess) {
          setState(() {
            _minPrice = state.priceRange.minPrice;
            _maxPrice = state.priceRange.maxPrice;
            _isLoadingPriceRange = false;
            // Update price range if it's still default
            if (_priceRange.start == 0 && _priceRange.end == 10000000) {
              _priceRange = RangeValues(_minPrice, _maxPrice);
            }
          });
        } else if (state is HotelPriceRangeLoading) {
          setState(() {
            _isLoadingPriceRange = true;
          });
        } else if (state is HotelPriceRangeFailure) {
          setState(() {
            _isLoadingPriceRange = false;
          });
        }

        if (state is HotelStarsSuccess) {
          setState(() {
            _availableStars = state.stars.map((s) => s.value).toList();
            _isLoadingStars = false;
          });
        } else if (state is HotelStarsLoading) {
          setState(() {
            _isLoadingStars = true;
          });
        } else if (state is HotelStarsFailure) {
          setState(() {
            _isLoadingStars = false;
          });
        }

        if (state is HotelTypesSuccess) {
          setState(() {
            _hotelTypes = state.types;
            _isLoadingHotelTypes = false;
          });
        } else if (state is HotelTypesLoading) {
          setState(() {
            _isLoadingHotelTypes = true;
          });
        } else if (state is HotelTypesFailure) {
          setState(() {
            _isLoadingHotelTypes = false;
          });
        }

        if (state is HotelFacilitiesSuccess) {
          setState(() {
            _facilities = state.facilities;
            _isLoadingFacilities = false;
          });
        } else if (state is HotelFacilitiesLoading) {
          setState(() {
            _isLoadingFacilities = true;
          });
        } else if (state is HotelFacilitiesFailure) {
          setState(() {
            _isLoadingFacilities = false;
          });
        }

        if (state is HotelEquipmentSuccess) {
          setState(() {
            _equipment = state.equipment;
            _isLoadingEquipment = false;
          });
        } else if (state is HotelEquipmentLoading) {
          setState(() {
            _isLoadingEquipment = true;
          });
        } else if (state is HotelEquipmentFailure) {
          setState(() {
            _isLoadingEquipment = false;
          });
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

        return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'hotel.filter.title'.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range
                    _buildSectionTitle('hotel.filter.price_range'.tr()),
                    SizedBox(height: 16.h),
                    if (_isLoadingPriceRange)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        children: [
                          RangeSlider(
                            values: _priceRange,
                            min: minPrice,
                            max: maxPrice,
                            divisions: 100,
                            labels: RangeLabels(
                              '${_formatPrice(_priceRange.start)}',
                              '${_formatPrice(_priceRange.end)}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatPrice(_priceRange.start),
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                              ),
                              Text(
                                _formatPrice(_priceRange.end),
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: 24.h),

                    // Stars
                    _buildSectionTitle('hotel.filter.stars'.tr()),
                    SizedBox(height: 16.h),
                    if (_isLoadingStars)
                      const Center(child: CircularProgressIndicator())
                    else
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: availableStars.map((starValue) {
                          final index = starValue - 1;
                          if (index < 0 || index >= _selectedStars.length) {
                            _selectedStars = List.generate(5, (i) => false);
                          }
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 16.sp, color: Colors.amber),
                                SizedBox(width: 4.w),
                                Text('$starValue'),
                              ],
                            ),
                            selected: index < _selectedStars.length && _selectedStars[index],
                            onSelected: (selected) {
                              setState(() {
                                if (index < _selectedStars.length) {
                                  _selectedStars[index] = selected;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 24.h),

                    // Hotel Types
                    if (hotelTypes.isNotEmpty || _isLoadingHotelTypes)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('hotel.filter.hotel_types'.tr()),
                          SizedBox(height: 16.h),
                          if (_isLoadingHotelTypes)
                            const Center(child: CircularProgressIndicator())
                          else
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: hotelTypes.map((type) {
                                final isSelected = _selectedHotelTypes.contains(type.id);
                                final locale = context.locale.toString();
                                final displayName = type.getDisplayName(locale);
                                return FilterChip(
                                  label: Text(displayName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedHotelTypes.add(type.id);
                                      } else {
                                        _selectedHotelTypes.remove(type.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // Facilities
                    if (facilities.isNotEmpty || _isLoadingFacilities)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('hotel.filter.facilities'.tr()),
                          SizedBox(height: 16.h),
                          if (_isLoadingFacilities)
                            const Center(child: CircularProgressIndicator())
                          else
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: facilities.take(10).map((facility) {
                                final isSelected = _selectedFacilities.contains(facility.id);
                                final locale = context.locale.toString();
                                final displayName = facility.getDisplayName(locale);
                                return FilterChip(
                                  label: Text(displayName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedFacilities.add(facility.id);
                                      } else {
                                        _selectedFacilities.remove(facility.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // Equipment
                    if (equipment.isNotEmpty || _isLoadingEquipment)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('hotel.filter.equipment'.tr()),
                          SizedBox(height: 16.h),
                          if (_isLoadingEquipment)
                            const Center(child: CircularProgressIndicator())
                          else
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: equipment.take(10).map((eq) {
                                final isSelected = _selectedEquipments.contains(eq.id);
                                final locale = context.locale.toString();
                                final displayName = eq.getDisplayName(locale);
                                return FilterChip(
                                  label: Text(displayName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedEquipments.add(eq.id);
                                      } else {
                                        _selectedEquipments.remove(eq.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // Cancellation Type
                    _buildSectionTitle('hotel.filter.cancellation'.tr()),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
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
                          _cancellationType == 'all' || _cancellationType == null,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
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
                          _priceRange = RangeValues(minPrice, maxPrice);
                          _selectedStars = List.generate(5, (index) => false);
                          _cancellationType = null;
                          _selectedHotelTypes = [];
                          _selectedFacilities = [];
                          _selectedEquipments = [];
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
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
                        final selectedStars = <int>[];
                        for (int i = 0; i < _selectedStars.length; i++) {
                          if (_selectedStars[i]) {
                            selectedStars.add(i + 1);
                          }
                        }

                        final filter = widget.initialFilter.copyWith(
                          minPrice: _priceRange.start,
                          maxPrice: _priceRange.end,
                          stars: selectedStars.isEmpty ? null : selectedStars,
                          cancellationType: _cancellationType,
                          hotelTypes: _selectedHotelTypes.isEmpty ? null : _selectedHotelTypes,
                          facilities: _selectedFacilities.isEmpty ? null : _selectedFacilities,
                          equipments: _selectedEquipments.isEmpty ? null : _selectedEquipments,
                        );

                        Navigator.pop(context, filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'hotel.filter.apply'.tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, bool selected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
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
}

