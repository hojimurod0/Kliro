import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/hotel.dart';
import '../bloc/hotel_bloc.dart';

class SearchSuggestion {
  final String id;
  final String name;
  final String type; // 'city' or 'hotel'
  final dynamic originalObject; // City or Hotel

  SearchSuggestion({
    required this.id,
    required this.name,
    required this.type,
    required this.originalObject,
  });
}

/// City/Hotel Input Widget with autocomplete
class CityInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final Function(City)? onCitySelected;
  final Function(Hotel)? onHotelSelected; // Callback for hotel selection
  final Function()? onClear;
  final int? countryId; // Default: 1 (Uzbekistan)

  const CityInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.onCitySelected,
    this.onHotelSelected,
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
  List<Hotel> _hotels = []; // List of hotels
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    _isLoadingCities = true; // Start loading
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    // Load cities
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bloc = context.read<HotelBloc>();
      // Check if data is already loaded to avoid stuck loading state
      if (bloc.state is HotelCitiesWithIdsSuccess) {
        setState(() {
          _citiesWithIds = (bloc.state as HotelCitiesWithIdsSuccess).cities;
          _isLoadingCities = false;
        });
      } else {
        bloc.add(GetCitiesWithIdsRequested(countryId: widget.countryId));
        // Timeout: agar 10 soniyadan keyin javob kelmasa, loading state ni o'chirish
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && _isLoadingCities) {
            debugPrint(
                '⚠️ CityInput: Loading timeout, setting _isLoadingCities = false');
            setState(() {
              _isLoadingCities = false;
            });
          }
        });
      }

      // Instead of relying on global 'list', we will search specifically if user types
      // or try to fetch popular hotels
      try {
        // Try simple list first
        bloc.add(const GetHotelsListRequested());
      } catch (e) {
        debugPrint('Initial hotel load error: $e');
      }
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
      if (_focusNode.hasFocus) {
        if (text.isEmpty) {
          _removeOverlay();
        } else if (text.length >= 2) {
          _filterAndShowSuggestions(text);
        } else {
          _removeOverlay();
        }
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
      if (text.isEmpty) {
        _removeOverlay();
      } else if (text.length >= 2) {
        _filterAndShowSuggestions(text);
      } else {
        _removeOverlay();
      }
    }
  }

  List<SearchSuggestion> _getFilteredSuggestions(String searchText) {
    final searchTextLower = searchText.toLowerCase();
    final List<SearchSuggestion> suggestions = [];
    final Set<String> addedHotelIds = {}; // Prevent duplicates

    // Handle Uzbek unification: 'tosh' <-> 'tash'
    final isToshSearch = searchTextLower.contains('tosh');
    final isTashSearch = searchTextLower.contains('tash');

    String? altSearchText;
    if (isToshSearch) {
      altSearchText = searchTextLower.replaceAll('tosh', 'tash');
    } else if (isTashSearch) {
      altSearchText = searchTextLower.replaceAll('tash', 'tosh');
    }

    // First, find matching cities
    final List<City> matchingCities = [];
    if (_citiesWithIds.isNotEmpty) {
      final locale = context.locale.toString();
      for (final city in _citiesWithIds) {
        final cityName = city.name.toLowerCase();
        final names =
            city.names?.values.map((v) => v.toLowerCase()).toList() ?? [];
        bool cityMatches = cityName.contains(searchTextLower) ||
            names.any((n) => n.contains(searchTextLower));
        if (!cityMatches && altSearchText != null) {
          final altText = altSearchText;
          cityMatches = cityName.contains(altText) ||
              names.any((n) => n.contains(altText));
        }

        if (cityMatches) {
          matchingCities.add(city);
          suggestions.add(SearchSuggestion(
            id: city.id.toString(),
            name: city.getDisplayName(locale),
            type: 'city',
            originalObject: city,
          ));
        }
      }
    }

    // Filter Hotels - show hotels that match city name or search text
    if (_hotels.isNotEmpty) {
      // Collect city names from matching cities for hotel filtering
      final Set<String> matchingCityNames = {};
      for (final city in matchingCities) {
        matchingCityNames.add(city.name.toLowerCase());
        if (city.names != null) {
          matchingCityNames
              .addAll(city.names!.values.map((v) => v.toLowerCase()));
        }
      }

      for (final hotel in _hotels) {
        if (addedHotelIds.contains(hotel.id)) continue; // Skip duplicates

        final nameLower = hotel.name.toLowerCase();
        final cityLower = hotel.city.toLowerCase();

        // Check if hotel name matches search text
        bool matches = nameLower.contains(searchTextLower);

        // Check if hotel city matches search text
        if (!matches) {
          matches = cityLower.contains(searchTextLower);
        }

        // Check with alternative search text (tosh/tash)
        if (!matches && altSearchText != null) {
          matches = nameLower.contains(altSearchText) ||
              cityLower.contains(altSearchText);
        }

        // Check if hotel's city matches any of the found cities
        if (!matches && matchingCityNames.isNotEmpty) {
          for (final cityName in matchingCityNames) {
            if (cityLower.contains(cityName) || cityName.contains(cityLower)) {
              matches = true;
              break;
            }
          }
        }

        if (matches) {
          addedHotelIds.add(hotel.id);
          suggestions.add(SearchSuggestion(
            id: hotel.id,
            name: hotel.name,
            type: 'hotel',
            originalObject: hotel,
          ));
        }
      }
    }

    // Sort: Cities first, then Hotels, then alphabetical
    suggestions.sort((a, b) {
      if (a.type != b.type) {
        return a.type == 'city' ? -1 : 1; // Cities first
      }
      return a.name.compareTo(b.name);
    });

    // Limit to 10000 items to show more hotels
    if (suggestions.length > 10000) {
      return suggestions.sublist(0, 10000);
    }

    return suggestions;
  }

  void _filterAndShowSuggestions(String searchText) {
    debugPrint('🔍 _filterAndShowSuggestions: searchText = "$searchText"');
    debugPrint(
        '🔍 _filterAndShowSuggestions: _citiesWithIds.length = ${_citiesWithIds.length}');
    final suggestions = _getFilteredSuggestions(searchText);
    debugPrint(
        '🔍 _filterAndShowSuggestions: Found ${suggestions.length} suggestions');

    if ((suggestions.isNotEmpty || _isLoadingCities) && _focusNode.hasFocus) {
      _showOverlayFromSuggestions(suggestions);
    } else if (_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _showAllSuggestions() {
    // This is no longer used for "Empty" state, but might be used explicitly?
    // User requested to NOT show all suggestions on empty focus.
    // So we effectively disable the callers of this function.
    if (!_focusNode.hasFocus) return;

    debugPrint(
        '🔍 _showAllSuggestions: _citiesWithIds.length = ${_citiesWithIds.length}');
    debugPrint('🔍 _showAllSuggestions: _hotels.length = ${_hotels.length}');

    final locale = context.locale.toString();
    final List<SearchSuggestion> suggestions = [];

    // Add Cities
    if (_citiesWithIds.isNotEmpty) {
      suggestions.addAll(_citiesWithIds.map((city) => SearchSuggestion(
            id: city.id.toString(),
            name: city.getDisplayName(locale),
            type: 'city',
            originalObject: city,
          )));
    } else {
      debugPrint('⚠️ _citiesWithIds is EMPTY!');
    }

    // Add Hotels (limit to avoid huge list)
    if (_hotels.isNotEmpty) {
      suggestions.addAll(_hotels.map((hotel) => SearchSuggestion(
            id: hotel.id,
            name: hotel.name,
            type: 'hotel',
            originalObject: hotel,
          )));
    }


    // Sort: Cities first, then Hotels, then alphabetical
    suggestions.sort((a, b) {
      if (a.type != b.type) {
        return a.type == 'city' ? -1 : 1; // Cities first
      }
      return a.name.compareTo(b.name);
    });

    // Limit total validation
    final limitedSuggestions = suggestions.length > 10000
        ? suggestions.sublist(0, 10000)
        : suggestions;

    debugPrint(
        '🔍 _showAllSuggestions: Total suggestions before limit = ${suggestions.length}');
    debugPrint(
        '🔍 _showAllSuggestions: Final suggestions count = ${limitedSuggestions.length}');

    // Always show overlay if loading, even if empty
    if (limitedSuggestions.isNotEmpty || _isLoadingCities) {
      _showOverlayFromSuggestions(limitedSuggestions);
    } else {
      // Agar hech narsa yo'q va loading ham yo'q bo'lsa, overlay ni yopish
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlayFromSuggestions(List<SearchSuggestion> suggestions) {
    _removeOverlay();

    if (suggestions.isEmpty && !_isLoadingCities) {
      debugPrint(
          '⚠️ _showOverlayFromSuggestions: suggestions is EMPTY and not loading');
      return;
    }

    debugPrint(
        '🔍 _showOverlayFromSuggestions: Showing ${suggestions.length} suggestions (Loading: $_isLoadingCities)');

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
              constraints: BoxConstraints(
                  maxHeight:
                      600.h), // Ko'proq elementlar uchun balandlikni oshirdik
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _isLoadingCities && suggestions.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                            SizedBox(width: 12.w),
                            Text("Ma'lumotlar yuklanmoqda...",
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        final isHotel = suggestion.type == 'hotel';

                        return InkWell(
                          onTap: () {
                            widget.controller.text = suggestion.name;
                            _focusNode.unfocus();
                            _removeOverlay();

                            if (isHotel) {
                              if (widget.onHotelSelected != null) {
                                widget.onHotelSelected!(
                                    suggestion.originalObject as Hotel);
                              }
                            } else {
                              if (widget.onCitySelected != null) {
                                widget.onCitySelected!(
                                    suggestion.originalObject as City);
                              }
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
                                  isHotel ? Icons.hotel : Icons.location_city,
                                  size: 20.sp,
                                  color: isHotel ? Colors.orange : Colors.blue,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestion.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          fontWeight: isHotel
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isHotel)
                                        Text(
                                          (suggestion.originalObject as Hotel)
                                              .city,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
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

        if (state is HotelCitiesWithIdsSuccess) {
          setState(() {
            _citiesWithIds = state.cities;
            _isLoadingCities = false;
          });
          debugPrint('🔍 CityInput: Loaded ${state.cities.length} cities');
          // for (final city in state.cities) {
          //   debugPrint('🔍 City: ${city.name} (id: ${city.id})');
          // }
          _refreshOverlayIfHasFocus();
        } else if (state is HotelHotelsListSuccess) {
          setState(() {
            _hotels = state.hotels;
          });
          debugPrint('🔍 CityInput: Loaded ${state.hotels.length} hotels');
          _refreshOverlayIfHasFocus();
        } else if (state is HotelCitiesWithIdsFailure) {
          setState(() {
            _isLoadingCities = false;
          });
          debugPrint('❌ CityInput: Failed to load cities: ${state.message}');
          _refreshOverlayIfHasFocus();
        } else if (state is HotelHotelsListFailure) {
          debugPrint('❌ Hotel list load failed: ${state.message}');
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
                prefixIcon: null,
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshOverlayIfHasFocus() {
    debugPrint(
        '🔍 _refreshOverlayIfHasFocus: hasFocus = ${_focusNode.hasFocus}');
    debugPrint(
        '🔍 _refreshOverlayIfHasFocus: text = "${widget.controller.text}"');
    debugPrint(
        '🔍 _refreshOverlayIfHasFocus: _citiesWithIds.length = ${_citiesWithIds.length}');

    if (_focusNode.hasFocus) {
      final searchText = widget.controller.text.trim();
      if (searchText.isEmpty) {
        debugPrint(
            '🔍 _refreshOverlayIfHasFocus: Calling _removeOverlay() because text is empty');
        _removeOverlay();
      } else if (searchText.length >= 2) {
        debugPrint(
            '🔍 _refreshOverlayIfHasFocus: Calling _filterAndShowSuggestions("$searchText")');
        _filterAndShowSuggestions(searchText);
      } else {
        _removeOverlay();
      }
    } else {
      debugPrint(
          '⚠️ _refreshOverlayIfHasFocus: Focus is LOST, not refreshing overlay');
    }
  }
}
