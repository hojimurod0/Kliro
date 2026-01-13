import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/hotel.dart';
import '../bloc/hotel_bloc.dart';
import '../../../../core/constants/app_colors.dart';

class HotelInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(Hotel)? onHotelSelected;

  const HotelInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.onHotelSelected,
  }) : super(key: key);

  @override
  State<HotelInput> createState() => _HotelInputState();
}

class _HotelInputState extends State<HotelInput> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  List<Hotel> _hotels = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelBloc>().add(const GetHotelsListRequested());
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
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final text = widget.controller.text.trim();
      if (_focusNode.hasFocus) {
        if (text.isEmpty) {
          _showAllHotels();
        } else if (text.length >= 2) {
          _filterAndShowHotels(text);
        } else {
          _removeOverlay();
        }
      }
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) _removeOverlay();
      });
    } else {
      final text = widget.controller.text.trim();
      if (text.isEmpty) {
        _showAllHotels();
      } else if (text.length >= 2) {
        _filterAndShowHotels(text);
      } else {
        _removeOverlay();
      }
    }
  }

  void _filterAndShowHotels(String searchText) {
    if (_hotels.isEmpty) return;
    final searchLower = searchText.toLowerCase();
    final filtered = _hotels.where((h) {
      final name = h.name.toLowerCase();
      return name.contains(searchLower) || h.city.toLowerCase().contains(searchLower);
    }).toList();
    if (filtered.isNotEmpty) {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }
    if (filtered.isNotEmpty && _focusNode.hasFocus) {
      _showOverlayFromHotels(filtered);
    } else if (_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _showAllHotels() {
    if (_hotels.isEmpty || !_focusNode.hasFocus) return;
    final sorted = List<Hotel>.from(_hotels)..sort((a, b) => a.name.compareTo(b.name));
    _showOverlayFromHotels(sorted);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlayFromHotels(List<Hotel> hotels) {
    _removeOverlay();
    if (hotels.isEmpty) return;

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
              constraints: BoxConstraints(maxHeight: 280.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  return InkWell(
                    onTap: () {
                      widget.controller.text = hotel.name;
                      _focusNode.unfocus();
                      _removeOverlay();
                      widget.onHotelSelected?.call(hotel);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hotel, 
                            size: 20.sp, 
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel.name, 
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                if (hotel.city.isNotEmpty)
                                  Text(
                                    hotel.city, 
                                    style: TextStyle(
                                      fontSize: 12.sp, 
                                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grayText,
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
        if (state is HotelHotelsListSuccess) {
          setState(() {
            _hotels = state.hotels;
          });
          final text = widget.controller.text.trim();
          if (_focusNode.hasFocus) {
            if (text.isEmpty) {
              _showAllHotels();
            } else if (text.length >= 2) {
              _filterAndShowHotels(text);
            }
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
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.grayText,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(
                  widget.icon, 
                  color: AppColors.primaryBlue,
                ),
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
