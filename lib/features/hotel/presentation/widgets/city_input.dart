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
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    _isLoadingCities = true; // Start loading
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    // Load cities
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('🔍 CityInput: initState postFrameCallback called');
      if (!mounted) {
        debugPrint('⚠️ CityInput: Widget not mounted, skipping city load');
        return;
      }

      try {
        final bloc = context.read<HotelBloc>();
        debugPrint(
            '🔍 CityInput: Got HotelBloc, current state: ${bloc.state.runtimeType}');

        // Check if data is already loaded to avoid stuck loading state
        if (bloc.state is HotelCitiesWithIdsSuccess) {
          final successState = bloc.state as HotelCitiesWithIdsSuccess;
          debugPrint(
              '✅ CityInput: Cities already loaded: ${successState.cities.length} cities');
          setState(() {
            _citiesWithIds = successState.cities;
            _isLoadingCities = false;
          });
        } else {
          debugPrint(
              '🔍 CityInput: Requesting cities with countryId: ${widget.countryId}');
          bloc.add(GetCitiesWithIdsRequested(countryId: widget.countryId));

          // Timeout: agar 10 soniyadan keyin javob kelmasa, loading state ni o'chirish
          Future.delayed(const Duration(seconds: 10), () {
            if (mounted && _isLoadingCities) {
              debugPrint(
                  '⚠️ CityInput: Loading timeout after 10 seconds, setting _isLoadingCities = false');
              setState(() {
                _isLoadingCities = false;
              });
            }
          });
        }
      } catch (e, stackTrace) {
        debugPrint('❌ CityInput: Error in initState: $e');
        debugPrint('❌ CityInput: Stack trace: $stackTrace');
        if (mounted) {
          setState(() {
            _isLoadingCities = false;
          });
        }
      }

      // Hotels are no longer loaded - only cities are shown
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
        } else if (text.length >= 1) {
          // Allow search from 1 character (for "tosh" case)
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
        // Focus bo'lganda va text bo'sh bo'lsa, barcha takliflarni ko'rsatish
        if (_citiesWithIds.isNotEmpty) {
          _showAllSuggestions();
        } else {
          _removeOverlay();
        }
      } else if (text.length >= 2) {
        _filterAndShowSuggestions(text);
      } else {
        // 1 ta belgi yozilganda ham barcha takliflarni ko'rsatish
        if (_citiesWithIds.isNotEmpty) {
          _showAllSuggestions();
        } else {
          _removeOverlay();
        }
      }
    }
  }

  List<SearchSuggestion> _getFilteredSuggestions(String searchText) {
    final searchTextLower = searchText.toLowerCase().trim();
    if (searchTextLower.isEmpty) {
      return [];
    }

    final List<SearchSuggestion> suggestions = [];

    if (_citiesWithIds.isEmpty) {
      debugPrint('⚠️ _getFilteredSuggestions: _citiesWithIds is empty!');
      return [];
    }

    final locale = context.locale.toString();

    // Handle "toshent" typo -> convert to "toshkent" for matching
    String normalizedSearch = searchTextLower;
    if (normalizedSearch.contains('toshent')) {
      normalizedSearch = normalizedSearch.replaceAll('toshent', 'toshkent');
    }

    // Create search variants (handle 'tosh' <-> 'tash' conversion and typos)
    final searchVariants = <String>{
      searchTextLower,
      normalizedSearch,
    };

    // Add "tosh" <-> "tash" variants
    if (searchTextLower.contains('tosh')) {
      searchVariants.add(searchTextLower.replaceAll('tosh', 'tash'));
    }
    if (searchTextLower.contains('tash')) {
      searchVariants.add(searchTextLower.replaceAll('tash', 'tosh'));
    }

    // If user types "tosh", also add "toshkent" and "tashkent" for better matching
    if (searchTextLower == 'tosh' || searchTextLower.startsWith('tosh')) {
      searchVariants.add('toshkent');
      searchVariants.add('tashkent');
    }

    debugPrint('🔍 _getFilteredSuggestions: Searching for "$searchTextLower"');
    debugPrint('🔍 _getFilteredSuggestions: Normalized: "$normalizedSearch"');
    debugPrint('🔍 _getFilteredSuggestions: Search variants: $searchVariants');
    debugPrint(
        '🔍 _getFilteredSuggestions: Total cities: ${_citiesWithIds.length}');

    // Debug: Print all city names for "tosh" search
    if (searchTextLower == 'tosh' ||
        searchTextLower.contains('tosh') ||
        searchTextLower.contains('toshent')) {
      final allCityNames = _citiesWithIds.map((c) {
        final names = <String>[c.name];
        if (c.names != null) {
          names.addAll(c.names!.values);
        }
        return '${c.id}: ${names.join(", ")}';
      }).toList();
      debugPrint(
          '🔍 All city names (first 20): ${allCityNames.take(20).toList()}');

      // Find any city with "tosh" or "tash" in name
      final toshkentCities = _citiesWithIds.where((c) {
        final nameLower = c.name.toLowerCase();
        final namesLower =
            c.names?.values.map((v) => v.toLowerCase()).toList() ?? [];
        return nameLower.contains('tosh') ||
            nameLower.contains('tash') ||
            namesLower.any((n) => n.contains('tosh') || n.contains('tash'));
      }).toList();
      debugPrint(
          '🔍 Cities with "tosh"/"tash" in name: ${toshkentCities.length}');
      for (final city in toshkentCities.take(5)) {
        debugPrint(
            '  - ${city.name} (id: ${city.id}, names: ${city.names?.values.toList()})');
      }
    }

    for (final city in _citiesWithIds) {
      // Get all possible city name variants to search
      final allNameVariants = <String>{
        city.name.toLowerCase(),
        ...(city.names?.values.map((v) => v.toLowerCase()) ?? []),
      };

      bool cityMatches = false;

      // Check each search variant against all name variants
      for (final searchVariant in searchVariants) {
        if (searchVariant.isEmpty) continue;

        for (final nameVariant in allNameVariants) {
          // Normalize name variant - handle "toshent" typo in city names too
          String normalizedName = nameVariant;
          if (nameVariant.contains('toshent')) {
            normalizedName = nameVariant.replaceAll('toshent', 'toshkent');
          }

          // Check if name starts with or contains the search text
          if (nameVariant.startsWith(searchVariant) ||
              nameVariant.contains(searchVariant)) {
            cityMatches = true;
            if (searchTextLower == 'tosh' ||
                searchTextLower.contains('tosh') ||
                searchTextLower.contains('toshent')) {
              debugPrint(
                  '✅ Match found: "$nameVariant" matches "$searchVariant" (city: ${city.name}, id: ${city.id})');
            }
            break;
          } else if (normalizedName.startsWith(normalizedSearch) ||
              normalizedName.contains(normalizedSearch)) {
            cityMatches = true;
            if (searchTextLower == 'tosh' ||
                searchTextLower.contains('tosh') ||
                searchTextLower.contains('toshent')) {
              debugPrint(
                  '✅ Match found (normalized): "$normalizedName" matches "$normalizedSearch" (city: ${city.name}, id: ${city.id})');
            }
            break;
          }
        }
        if (cityMatches) break;
      }

      if (cityMatches) {
        suggestions.add(SearchSuggestion(
          id: city.id.toString(),
          name: city.getDisplayName(locale),
          type: 'city',
          originalObject: city,
        ));
      }
    }

    debugPrint(
        '🔍 _getFilteredSuggestions: Found ${suggestions.length} matching cities');
    if (suggestions.isNotEmpty) {
      debugPrint(
          '🔍 Matched cities: ${suggestions.map((s) => s.name).take(10).toList()}');
    } else {
      debugPrint('⚠️ No cities matched for "$searchTextLower"');
    }

    // Sort cities: prioritize Toshkent when searching for "tosh"
    suggestions.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final searchLower = searchTextLower;

      // Prioritize Toshkent/Tashkent when searching for "tosh" or "toshent"
      if (searchLower.contains('tosh') ||
          searchLower.contains('tash') ||
          searchLower.contains('toshent')) {
        final aIsToshkent = aName.contains('tosh') || aName.contains('tash');
        final bIsToshkent = bName.contains('tosh') || bName.contains('tash');

        if (aIsToshkent && !bIsToshkent) return -1;
        if (!aIsToshkent && bIsToshkent) return 1;
      }

      // Then sort alphabetically
      return a.name.compareTo(b.name);
    });

    return suggestions;
  }

  void _filterAndShowSuggestions(String searchText) {
    final trimmedText = searchText.trim();
    debugPrint('🔍 _filterAndShowSuggestions: searchText = "$trimmedText"');
    debugPrint(
        '🔍 _filterAndShowSuggestions: _citiesWithIds.length = ${_citiesWithIds.length}');
    debugPrint(
        '🔍 _filterAndShowSuggestions: _isLoadingCities = $_isLoadingCities');

    // Debug: print first few city names for debugging
    if (_citiesWithIds.isNotEmpty) {
      debugPrint(
          '🔍 First 5 cities: ${_citiesWithIds.take(5).map((c) => c.name).toList()}');
      // Check if Toshkent/Tashkent exists in the list
      final toshkentCities = _citiesWithIds.where((c) {
        final nameLower = c.name.toLowerCase();
        final namesLower =
            c.names?.values.map((v) => v.toLowerCase()).toList() ?? [];
        return nameLower.contains('tosh') ||
            nameLower.contains('tash') ||
            namesLower.any((n) => n.contains('tosh') || n.contains('tash'));
      }).toList();
      if (toshkentCities.isNotEmpty) {
        debugPrint(
            '🔍 Found Toshkent/Tashkent cities: ${toshkentCities.map((c) => '${c.name} (names: ${c.names?.values.toList()})').toList()}');
      } else {
        debugPrint('⚠️ No Toshkent/Tashkent cities found in _citiesWithIds!');
      }
    } else {
      debugPrint('⚠️ _citiesWithIds is EMPTY!');
    }

    final suggestions = _getFilteredSuggestions(trimmedText);
    debugPrint(
        '🔍 _filterAndShowSuggestions: Found ${suggestions.length} suggestions');

    // Debug: print found city names
    if (suggestions.isNotEmpty) {
      debugPrint(
          '🔍 Found cities: ${suggestions.map((s) => s.name).take(10).toList()}');
    } else {
      debugPrint('⚠️ No suggestions found for "$trimmedText"');
    }

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

    final locale = context.locale.toString();
    final List<SearchSuggestion> suggestions = [];

    // Faqat shaharlarni qo'shish
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

    // Faqat shaharlarni alfavit bo'yicha tartiblash
    suggestions.sort((a, b) => a.name.compareTo(b.name));

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
                        // Only cities are shown, so type is always 'city'
                        final city = suggestion.originalObject as City;

                        return InkWell(
                          onTap: () {
                            widget.controller.text = suggestion.name;
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
                                  Icons.location_city,
                                  size: 20.sp,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    suggestion.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
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
        } else if (state is HotelCitiesWithIdsFailure) {
          setState(() {
            _isLoadingCities = false;
          });
          debugPrint('❌ CityInput: Failed to load cities: ${state.message}');
          _refreshOverlayIfHasFocus();
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
                          // Keep it safe for spannable selection edge cases
                          widget.controller.selection =
                              const TextSelection.collapsed(offset: 0);
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
        // Text bo'sh bo'lsa, barcha takliflarni ko'rsatish
        if (_citiesWithIds.isNotEmpty) {
          debugPrint(
              '🔍 _refreshOverlayIfHasFocus: Calling _showAllSuggestions() because text is empty');
          _showAllSuggestions();
        } else {
          debugPrint(
              '🔍 _refreshOverlayIfHasFocus: Calling _removeOverlay() because text is empty and no data');
          _removeOverlay();
        }
      } else if (searchText.length >= 2) {
        debugPrint(
            '🔍 _refreshOverlayIfHasFocus: Calling _filterAndShowSuggestions("$searchText")');
        _filterAndShowSuggestions(searchText);
      } else {
        // 1 ta belgi yozilganda ham barcha takliflarni ko'rsatish
        if (_citiesWithIds.isNotEmpty) {
          _showAllSuggestions();
        } else {
          _removeOverlay();
        }
      }
    } else {
      debugPrint(
          '⚠️ _refreshOverlayIfHasFocus: Focus is LOST, not refreshing overlay');
    }
  }
}
