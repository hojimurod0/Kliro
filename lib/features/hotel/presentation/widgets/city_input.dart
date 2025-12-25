import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/city.dart';
import '../bloc/hotel_bloc.dart';

/// City Input Widget with autocomplete
class CityInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(City)? onCitySelected;
  final Function()? onClear;
  final int? countryId; // Default: 1 (Uzbekistan)

  const CityInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.onCitySelected,
    this.onClear,
    this.countryId = 1,
  }) : super(key: key);

  @override
  State<CityInput> createState() => _CityInputState();
}

class _CityInputState extends State<CityInput> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  List<City> _citiesWithIds = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    // Load cities with IDs on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelBloc>().add(GetCitiesWithIdsRequested(countryId: widget.countryId));
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final text = widget.controller.text.trim();
      if (text.length >= 2 && _focusNode.hasFocus) {
        // Local filter from _citiesWithIds list
        _filterAndShowCities(text);
      } else {
        _removeOverlay();
      }
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    } else {
      final text = widget.controller.text.trim();
      if (text.length >= 2) {
        // Local filter from _citiesWithIds list
        _filterAndShowCities(text);
      }
    }
  }

  void _filterAndShowCities(String searchText) {
    if (_citiesWithIds.isEmpty) return;
    
    final searchTextLower = searchText.toLowerCase();
    final filtered = _citiesWithIds.where((city) {
      final cityName = city.name.toLowerCase();
      final names = city.names?.values.map((v) => v.toLowerCase()).toList() ?? [];
      return cityName.contains(searchTextLower) || 
             names.any((n) => n.contains(searchTextLower));
    }).toList();
    
    if (filtered.isNotEmpty && _focusNode.hasFocus) {
      _showOverlayFromCities(filtered);
    } else if (_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlayFromCities(List<City> cities) {
    _removeOverlay();

    if (cities.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return InkWell(
                    onTap: () {
                      widget.controller.text = city.name;
                      _focusNode.unfocus();
                      _removeOverlay();
                      
                      if (widget.onCitySelected != null) {
                        widget.onCitySelected!(city);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              city.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<HotelBloc, HotelState>(
      bloc: context.read<HotelBloc>(),
      listener: (context, state) {
        if (!mounted) return;

        if (!_focusNode.hasFocus) {
          return;
        }

        if (state is HotelCitiesWithIdsSuccess) {
          setState(() {
            _citiesWithIds = state.cities;
          });
          // Filter cities by search text va ko'rsatish
          final searchText = widget.controller.text.trim();
          if (searchText.length >= 2 && _focusNode.hasFocus) {
            _filterAndShowCities(searchText);
          }
        } else if (state is HotelCitiesWithIdsFailure) {
          if (_focusNode.hasFocus) {
            _removeOverlay();
          }
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(widget.icon, color: Colors.blue),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          widget.controller.clear();
                          if (widget.onClear != null) {
                            widget.onClear!();
                          }
                          if (mounted) setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

