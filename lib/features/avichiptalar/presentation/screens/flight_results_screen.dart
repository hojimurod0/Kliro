import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/logger.dart';
import '../bloc/avia_bloc.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/fare_family_model.dart';
import '../../data/models/search_offers_request_model.dart';
import '../widgets/flight_search_loading_widget.dart';
import '../widgets/flight_filter_sheet.dart';
import '../../data/models/fare_rules_model.dart';
import '../../domain/entities/avichipta_filter.dart';
import '../../domain/constants/airline_logo_manifest.dart';

double? _parsePriceValue(String? raw) {
  final s0 = (raw ?? '').trim();
  if (s0.isEmpty) return null;

  // Remove spaces & NBSP, unify decimal separator to "."
  var s = s0.replaceAll('\u00A0', '').replaceAll(' ', '').replaceAll(',', '.');
  // Keep only digits and dots
  s = s.replaceAll(RegExp(r'[^0-9.]'), '');
  if (s.isEmpty) return null;

  // If multiple dots, treat the last one as decimal separator and remove others.
  final parts = s.split('.');
  if (parts.length > 2) {
    final dec = parts.removeLast();
    final intPart = parts.join();
    s = dec.isEmpty ? intPart : '$intPart.$dec';
  }

  return double.tryParse(s);
}

String _formatPriceHuman(String raw) {
  final v = _parsePriceValue(raw);
  if (v == null) return raw;

  final intPart = v.floor();
  final frac = v - intPart;

  String groupInt(int n) {
    final s = n.toString();
    final rev = s.split('').reversed.toList();
    final buf = StringBuffer();
    for (var i = 0; i < rev.length; i++) {
      if (i > 0 && i % 3 == 0) buf.write(' ');
      buf.write(rev[i]);
    }
    return buf.toString().split('').reversed.join();
  }

  final intStr = groupInt(intPart);
  if (frac.abs() < 1e-9) return intStr;

  // Show up to 1 decimal (common for API like "16982131.1")
  final fixed = v.toStringAsFixed(1);
  final fixedParts = fixed.split('.');
  if (fixedParts.length != 2) return intStr;
  final dec = fixedParts[1].replaceFirst(RegExp(r'0+$'), '');
  if (dec.isEmpty) return intStr;
  return '$intStr,$dec';
}

String _apiOfferIdForApi(String? id) {
  final s = (id ?? '').trim();
  final m = RegExp(r'-(\d+)$').firstMatch(s);
  if (m == null) return s;
  final suffix = m.group(1);
  if ((suffix == '0' || suffix == '1') && s.length > 25) {
    return s.substring(0, m.start);
  }
  return s;
}

@RoutePage(name: 'FlightResultsRoute')
class FlightResultsScreen extends StatelessWidget {
  const FlightResultsScreen({super.key});

  // Helper function to format price for confirmation page
  static String _formatPriceForConfirmation(String price) {
    return _formatPriceHuman(price);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AviaBloc, AviaState>(
      builder: (context, state) {
        AppLogger.debug('FlightResultsScreen: State = ${state.runtimeType}');

        // Loading state - qidiruv davom etmoqda
        if (state is AviaSearchLoading) {
          AppLogger.debug('FlightResultsScreen: Showing loading...');
          return _FlightResultsScaffold(
            searchRequest: state.searchRequest,
            child: FlightSearchLoadingWidget(
              searchRequest: state.searchRequest,
            ),
          );
        }

        // Boshqa loading state
        if (state is AviaLoading) {
          return _FlightResultsScaffold(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
          );
        }

        // Xatolik holati
        if (state is AviaSearchFailure) {
          return _FlightResultsScaffold(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64.sp,
                      color: AppColors.dangerRed,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'avia.results.error'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'avia.common.back'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Muvaffaqiyatli natijalar
        if (state is AviaSearchSuccess) {
          final offers = state.offers;
          final searchRequest = state.searchRequest;
          final isRoundTrip = searchRequest?.directions.length == 2;

          AppLogger.success(
            'FlightResultsScreen: AviaSearchSuccess with ${offers.length} offers, isRoundTrip: $isRoundTrip',
          );

          return FlightSearchResultsPage(
            offers: offers,
            isRoundTrip: isRoundTrip,
            searchRequest: searchRequest,
            onOfferTap: (outboundOffer, returnOffer) {
              // Calculate total price
              // outboundOffer.price уже включает оба рейса (туда-обратно), если есть returnOffer
              // Не нужно добавлять returnOffer.price, так как это приведет к двойному расчету
              // Use the exact same price calculation as in the list view display
              // outboundOffer already has the correct price from _offerWithSelectedFare
              // This matches the calculation in _buildFlightCard:
              // rawParsedPrice = _FlightUtils.parsePriceValue(rawDisplayPrice) ?? 0
              // parsedPrice = rawParsedPrice * 1.1
              // displayPrice = parsedPrice.toStringAsFixed(0)
              final rawParsedPrice = _FlightUtils.parsePriceValue(outboundOffer.price) ?? 0;
              final parsedPrice = rawParsedPrice * 1.1; // Apply 10% commission
              // Round to integer (same as toStringAsFixed(0) in list view)
              final totalPriceNum = parsedPrice.round();
              final totalPrice = _formatPriceForConfirmation(
                totalPriceNum.toString(),
              );
              
              final currency = outboundOffer.currency ?? 'sum';

              // Get passenger counts from search request
              final adults = searchRequest?.adults ?? 1;
              final childrenCount = searchRequest?.children ?? 0;
              final babies = searchRequest?.infants ?? 0;

              // Navigate to confirmation page
              context.router.push(
                FlightConfirmationRoute(
                  outboundOffer: outboundOffer,
                  returnOffer: returnOffer,
                  totalPrice: totalPrice,
                  currency: currency,
                  adults: adults,
                  childrenCount: childrenCount,
                  babies: babies,
                ),
              );
            },
          );
        }

        // Boshqa holatlar uchun
        return _FlightResultsScaffold(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 64.sp,
                  color: AppColors.grayText,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'avia.search.search_button'.tr(),
                  style: TextStyle(fontSize: 16.sp, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Переиспользуемый Scaffold с AppBar
class _FlightResultsScaffold extends StatelessWidget {
  final Widget child;
  final SearchOffersRequestModel? searchRequest;

  const _FlightResultsScaffold({
    required this.child,
    this.searchRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _FlightAppBar(searchRequest: searchRequest),
      body: child,
    );
  }
}

// Оптимизированный AppBar виджет
class _FlightAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SearchOffersRequestModel? searchRequest;
  final List<Widget>? actions;

  const _FlightAppBar({this.searchRequest, this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Dynamic title and subtitle
    String title = 'avia.results.title'.tr();
    String subtitle = '';

    if (searchRequest != null && searchRequest!.directions.isNotEmpty) {
      final first = searchRequest!.directions.first;
      // Route: Toshkent ⇄ Dubay
      if (searchRequest!.directions.length > 1) {
        title = '${first.departureAirport} ⇄ ${first.arrivalAirport}';
      } else {
        title = '${first.departureAirport} → ${first.arrivalAirport}';
      }

      // Subtitle: Date • Passengers • Class
      final date = _formatDate(first.date);
      final passengers = searchRequest!.adults + searchRequest!.children + searchRequest!.infants;
      final cabin = searchRequest!.serviceClass; 
      // Localization for cabin can be added if needed, e.g. 'avia.class.$cabin'.tr()

      subtitle = '$date • $passengers ${'avia.search.passengers'.tr()} • $cabin';
    }

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: _buildBackButton(isDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grayBorder.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.sp,
          color: isDark ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMM', 'en').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

class FlightSearchResultsPage extends StatefulWidget {
  final List<OfferModel> offers;
  final Function(OfferModel, OfferModel?) onOfferTap;
  final bool isRoundTrip;
  final SearchOffersRequestModel? searchRequest;

  const FlightSearchResultsPage({
    super.key,
    required this.offers,
    required this.onOfferTap,
    this.isRoundTrip = false,
    this.searchRequest,
  });

  @override
  State<FlightSearchResultsPage> createState() =>
      _FlightSearchResultsPageState();
}

class _FlightSearchResultsPageState extends State<FlightSearchResultsPage> {
  bool _didPrefetch = false;
  AvichiptaFilter? _currentFilter;
  List<OfferModel> _filteredOffers = [];
  List<Map<String, dynamic>> _groupedOffers = [];

  @override
  void initState() {
    super.initState();
    _filteredOffers = widget.offers;
    _currentFilter = AvichiptaFilter.empty;
    _updateGroupedOffers();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prefetchTopTariffs();
    });
  }

  void _updateGroupedOffers() {
    _groupedOffers = _FlightUtils.groupOffers(
      _filteredOffers, 
      widget.isRoundTrip, 
      widget.searchRequest
    );
  }

  Future<void> _prefetchTopTariffs() async {
    if (_didPrefetch) return;
    _didPrefetch = true;

    final repo = context.read<AviaBloc>().repository;

    final ids = <String>[];
    final seen = <String>{};
    // Use the already computed groups
    for (var i = 0; i < _groupedOffers.length && i < 10; i++) {
      final outbound = _groupedOffers[i]['outbound'] as OfferModel;
      final id = _FlightUtils.apiOfferIdForApi(outbound.id);
      if (id.isEmpty) continue;
      if (seen.add(id)) ids.add(id);
    }

    // Small concurrency to avoid spamming the API.
    const batch = 3;
    for (var i = 0; i < ids.length; i += batch) {
      if (!mounted) return; 
      final slice =
          ids.sublist(i, (i + batch) > ids.length ? ids.length : (i + batch));
      await Future.wait(slice.map((id) => repo.fareFamily(id)));
    }
  }

  // ... (keeping _applyFilter as is, but ensuring it calls _updateGroupedOffers)
  
  List<OfferModel> _applyFilter(
      List<OfferModel> offers, AvichiptaFilter filter) {
      // ... existing filter logic ...
      // Can't replace the whole method content via this chunk if it's large, 
      // but I need to make sure _groupOffers is called after filtering.
      
      // RE-IMPLEMENTING _applyFilter content here for correctness since I'm implementing the class logic
      
     var filtered = offers;

    // Price filter
    if (filter.minPrice != null || filter.maxPrice != null) {
      filtered = filtered.where((offer) {
        final rawPrice = _parsePriceValue(offer.price);
        if (rawPrice == null) return false;
        final price = rawPrice * 1.1; // Apply 10% commission for filtering
        final meetsMin = filter.minPrice == null || price >= filter.minPrice!;
        final meetsMax = filter.maxPrice == null || price <= filter.maxPrice!;
        return meetsMin && meetsMax;
      }).toList();
    }

    // Airlines filter
    if (filter.airlines != null && filter.airlines!.isNotEmpty) {
      filtered = filtered.where((offer) {
        return offer.airline != null &&
            filter.airlines!.contains(offer.airline);
      }).toList();
    }

    // Service class filter
    if (filter.serviceClasses != null && filter.serviceClasses!.isNotEmpty) {
      filtered = filtered.where((offer) {
        if (offer.segments == null) return false;
        return offer.segments!.any((segment) {
          final cabinClass = segment.cabinClass?.toLowerCase();
          return cabinClass != null &&
              filter.serviceClasses!.contains(cabinClass);
        });
      }).toList();
    }

    // Transfers filter
    if (filter.maxTransfers != null) {
      filtered = filtered.where((offer) {
        final transfers = _countTransfers(offer);
        if (filter.maxTransfers == 0) {
          return transfers == 0; // Direct flights only
        } else if (filter.maxTransfers == 2) {
          return transfers >= 2; // 2+ transfers
        }
        return transfers <= filter.maxTransfers!;
      }).toList();
    }

    // Luggage filter
    if (filter.withLuggage == true) {
      filtered = filtered.where((offer) {
        if (offer.segments == null) return false;
        return offer.segments!.any((segment) {
          final baggage = segment.baggage?.toLowerCase() ?? '';
          return baggage.isNotEmpty && baggage != 'no' && baggage != 'none';
        });
      }).toList();
    }

    // Time filters
    if (filter.departureTimeStart != null || filter.departureTimeEnd != null) {
      filtered = filtered.where((offer) {
        if (offer.segments == null || offer.segments!.isEmpty) return false;
        final firstSegment = offer.segments!.first;
        final departureTime = firstSegment.departureTime;
        if (departureTime == null) return false;
        final timeMinutes = _parseTimeToMinutes(departureTime);
        final meetsStart = filter.departureTimeStart == null ||
            timeMinutes >= filter.departureTimeStart!;
        final meetsEnd = filter.departureTimeEnd == null ||
            timeMinutes <= filter.departureTimeEnd!;
        return meetsStart && meetsEnd;
      }).toList();
    }

    if (filter.arrivalTimeStart != null || filter.arrivalTimeEnd != null) {
      filtered = filtered.where((offer) {
        if (offer.segments == null || offer.segments!.isEmpty) return false;
        final lastSegment = offer.segments!.last;
        final arrivalTime = lastSegment.arrivalTime;
        if (arrivalTime == null) return false;
        final timeMinutes = _parseTimeToMinutes(arrivalTime);
        final meetsStart = filter.arrivalTimeStart == null ||
            timeMinutes >= filter.arrivalTimeStart!;
        final meetsEnd = filter.arrivalTimeEnd == null ||
            timeMinutes <= filter.arrivalTimeEnd!;
        return meetsStart && meetsEnd;
      }).toList();
    }

    // Sorting
    filtered = _applySorting(filtered, filter.sortBy);

    return filtered;
  }
  
  // Helpers wrapping static Utils
  double? _parsePriceValue(String? raw) => _FlightUtils.parsePriceValue(raw);
  
  int _parseTimeToMinutes(String timeStr) {
     final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
    if (timeMatch != null) {
      final hours = int.tryParse(timeMatch.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      return hours * 60 + minutes;
    }
    return 0;
  }

  int _countTransfers(OfferModel offer) {
    if (offer.segments == null) return 0;
    return offer.segments!.length - 1;
  }

  List<OfferModel> _applySorting(List<OfferModel> offers, String? sortBy) {
    final sorted = List<OfferModel>.from(offers);

    switch (sortBy) {
      case 'optimal':
        sorted.sort((a, b) {
           final priceA = _parsePriceValue(a.price) ?? 0;
           final priceB = _parsePriceValue(b.price) ?? 0;
           return priceA.compareTo(priceB);
        });
        break;
      case 'earlier':
        sorted.sort((a, b) {
          final timeA = a.segments?.isNotEmpty == true
              ? _parseTimeToMinutes(a.segments!.first.departureTime ?? '')
              : 0;
          final timeB = b.segments?.isNotEmpty == true
              ? _parseTimeToMinutes(b.segments!.first.departureTime ?? '')
              : 0;
          return timeA.compareTo(timeB);
        });
        break;
      case 'fastest':
        sorted.sort((a, b) {
          final durationA = _parseDuration(a.duration ?? '');
          final durationB = _parseDuration(b.duration ?? '');
          return durationA.compareTo(durationB);
        });
        break;
      case 'most_useful':
      default:
        sorted.sort((a, b) {
          final priceA = _parsePriceValue(a.price) ?? 0;
           final priceB = _parsePriceValue(b.price) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
    }
    return sorted;
  }

  int _parseDuration(String durationStr) {
    int totalMinutes = 0;
    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(durationStr);
    if (hourMatch != null) {
      totalMinutes += (int.tryParse(hourMatch.group(1) ?? '0') ?? 0) * 60;
    }
    final minuteMatch = RegExp(r'(\d+)\s*m').firstMatch(durationStr);
    if (minuteMatch != null) {
      totalMinutes += int.tryParse(minuteMatch.group(1) ?? '0') ?? 0;
    }
    return totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using pre-grouped offers
    final groupedOffers = _groupedOffers;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _FlightAppBar(
        searchRequest: widget.searchRequest,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: theme.iconTheme.color,
              size: 24.sp,
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push<AvichiptaFilter>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => FlightFilterSheet(
                    initialFilter: _currentFilter ?? AvichiptaFilter.empty,
                    offers: widget.offers,
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  _currentFilter = result;
                  _filteredOffers = _applyFilter(widget.offers, result);
                  _updateGroupedOffers();
                });
              }
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: groupedOffers.isEmpty
          ? _EmptyStateWidget(onBack: () => Navigator.of(context).pop())
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: groupedOffers.length,
              cacheExtent: 500,
              itemBuilder: (context, index) {
                final groupedOffer = groupedOffers[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  child: TicketCard(
                    key: ValueKey(groupedOffer['id'] ?? index),
                    offer: groupedOffer['outbound'] as OfferModel,
                    returnOffer: groupedOffer['inbound'] as OfferModel?,
                    isRoundTrip: widget.isRoundTrip,
                    prefetchTariffs: true,
                    onTap: (outbound, inbound) =>
                        widget.onOfferTap(outbound, inbound),
                  ),
                );
              },
            ),
    );
  }
}

// Utility class to keep logic clean and reusable
class _FlightUtils {
  static double? parsePriceValue(String? raw) {
    final s0 = (raw ?? '').trim();
    if (s0.isEmpty) return null;
    var s = s0.replaceAll('\u00A0', '').replaceAll(' ', '').replaceAll(',', '.');
    s = s.replaceAll(RegExp(r'[^0-9.]'), '');
    if (s.isEmpty) return null;
    final parts = s.split('.');
    if (parts.length > 2) {
      final dec = parts.removeLast();
      final intPart = parts.join();
      s = dec.isEmpty ? intPart : '$intPart.$dec';
    }
    return double.tryParse(s);
  }
  
  static String apiOfferIdForApi(String? id) {
    final s = (id ?? '').trim();
    final m = RegExp(r'-(\d+)$').firstMatch(s);
    if (m == null) return s;
    // logic preserved from original
    final suffix = m.group(1);
    if ((suffix == '0' || suffix == '1') && s.length > 25) {
      return s.substring(0, m.start);
    }
    return s;
  }

  static List<Map<String, dynamic>> groupOffers(
    List<OfferModel> offers,
    bool isRoundTrip,
    SearchOffersRequestModel? searchRequest,
  ) {
    if (!isRoundTrip || searchRequest == null) {
      // Single direction - simple map
      return offers
          .map((offer) => {'id': offer.id, 'outbound': offer, 'inbound': null})
          .toList();
    }

    final directions = searchRequest.directions;
    if (directions.length < 2) {
      return offers
          .map((offer) => {'id': offer.id, 'outbound': offer, 'inbound': null})
          .toList();
    }

    final outboundDirection = directions[0];
    final inboundDirection = directions[1];

    final grouped = <Map<String, dynamic>>[];
    final usedIndices = <int>{};

    for (var i = 0; i < offers.length; i++) {
        // ... (preserving logic but optimizing where possible in future)
      if (usedIndices.contains(i)) continue;

      final outboundOffer = offers[i];
      final outboundSegments = outboundOffer.segments ?? [];

      if (outboundSegments.isEmpty) continue;

      final firstDeparture = outboundSegments.first.departureAirport;
      final lastArrival = outboundSegments.last.arrivalAirport;

      final matchesOutbound =
          firstDeparture == outboundDirection.departureAirport &&
              lastArrival == outboundDirection.arrivalAirport;

      if (!matchesOutbound) {
        grouped.add({
          'id': outboundOffer.id,
          'outbound': outboundOffer,
          'inbound': null,
        });
        usedIndices.add(i);
        continue;
      }

      OfferModel? inboundOffer;
      int? inboundIndex;

      for (var j = i + 1; j < offers.length; j++) {
        if (usedIndices.contains(j)) continue;

        final candidateOffer = offers[j];
        final candidateSegments = candidateOffer.segments ?? [];

        if (candidateSegments.isEmpty) continue;

        final candidateDeparture = candidateSegments.first.departureAirport;
        final candidateArrival = candidateSegments.last.arrivalAirport;

        final matchesInbound =
            candidateDeparture == inboundDirection.departureAirport &&
                candidateArrival == inboundDirection.arrivalAirport;

        if (matchesInbound) {
          inboundOffer = candidateOffer;
          inboundIndex = j;
          break;
        }
      }

      grouped.add({
        'id': '${outboundOffer.id}_${inboundOffer?.id ?? 'single'}',
        'outbound': outboundOffer,
        'inbound': inboundOffer,
      });

      usedIndices.add(i);
      if (inboundIndex != null) {
        usedIndices.add(inboundIndex);
      }
    }

    for (var i = 0; i < offers.length; i++) {
      if (!usedIndices.contains(i)) {
        grouped.add({
          'id': offers[i].id,
          'outbound': offers[i],
          'inbound': null,
        });
      }
    }

    return grouped;
  }
}

// Оптимизированное пустое состояние
class _EmptyStateWidget extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyStateWidget({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff_rounded,
              size: 80.sp,
              color: AppColors.grayText.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'avia.results.not_found'.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'avia.results.change_search'.tr(),
              style: TextStyle(fontSize: 14.sp, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'avia.common.back'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Alohida Chipta Vidjeti (Reusable Widget) ---
class TicketCard extends StatelessWidget {
  final OfferModel offer;
  final OfferModel? returnOffer;
  final bool isRoundTrip;
  final void Function(OfferModel offer, OfferModel? returnOffer)? onTap;
  final bool prefetchTariffs;

  const TicketCard({
    super.key,
    required this.offer,
    this.returnOffer,
    this.isRoundTrip = false,
    this.prefetchTariffs = false,
    this.onTap,
  });

  // Кэширование вычислений для лучшей производительности
  @override
  Widget build(BuildContext context) {
    return _TicketCardContent(
      offer: offer,
      returnOffer: returnOffer,
      isRoundTrip: isRoundTrip,
      prefetchTariffs: prefetchTariffs,
      onTap: onTap,
    );
  }
}

// Отдельный виджет для оптимизации перестроек
class _TicketCardContent extends StatefulWidget {
  final OfferModel offer;
  final OfferModel? returnOffer;
  final bool isRoundTrip;
  final void Function(OfferModel offer, OfferModel? returnOffer)? onTap;
  final bool prefetchTariffs;

  const _TicketCardContent({
    required this.offer,
    this.returnOffer,
    this.isRoundTrip = false,
    this.prefetchTariffs = false,
    this.onTap,
  });

  @override
  State<_TicketCardContent> createState() => _TicketCardContentState();
}

class _TicketCardContentState extends State<_TicketCardContent> {
  bool _isExpanded = false;
  final Map<String, List<FareFamilyModel>> _fareFamiliesByOfferId = {};
  final Set<String> _fareFamiliesLoading = {};
  final Map<String, String> _fareFamiliesError = {};
  final Map<String, String> _selectedFareIdByOfferId = {};

  final Map<String, FareRulesModel> _fareRulesByOfferId = {};
  final Set<String> _fareRulesLoading = {};
  final Map<String, String> _fareRulesError = {};

  @override
  void initState() {
    super.initState();
    if (widget.prefetchTariffs) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final outboundId = _baseOfferId(widget.offer);
        if (outboundId != null && outboundId.isNotEmpty) {
          // ignore: unawaited_futures
          _ensureFareFamiliesLoaded(outboundId);
        }
        if (widget.isRoundTrip && widget.returnOffer != null) {
          final returnId = _baseOfferId(widget.returnOffer!);
          if (returnId != null && returnId.isNotEmpty) {
            // ignore: unawaited_futures
            _ensureFareFamiliesLoaded(returnId);
          }
        }
      });
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    // ignore: invalid_use_of_protected_member
    setState(fn);
  }

  String _apiOfferId(String? id) {
    final s = (id ?? '').trim();
    final m = RegExp(r'-(\d+)$').firstMatch(s);
    if (m == null) return s;
    final suffix = m.group(1);
    // We only add "-0", "-1" (direction split). Strip only those to avoid harming real ids.
    if ((suffix == '0' || suffix == '1') && s.length > 25) {
      return s.substring(0, m.start);
    }
    return s;
  }

  String? _baseOfferId(OfferModel offer) {
    final apiId = _apiOfferId(offer.id);
    return apiId.isEmpty ? null : apiId;
  }

  FareFamilyModel? _selectedFareForOfferId(String offerId) {
    final selectedId = _selectedFareIdByOfferId[offerId];
    if (selectedId == null) return null;
    final families = _fareFamiliesByOfferId[offerId];
    if (families == null) return null;
    for (final f in families) {
      if (f.id == selectedId) return f;
    }
    return null;
  }

  void _syncReturnFareSelection({
    required String outboundOfferId,
    required FareFamilyModel selectedFare,
    required String returnOfferId,
  }) {
    if (returnOfferId.trim().isEmpty) return;

    void pickAndSet() {
      final returnFamilies = _fareFamiliesByOfferId[returnOfferId];
      if (returnFamilies == null || returnFamilies.isEmpty) return;

      // 1) Try match by normalized name
      final targetName = (selectedFare.name ?? '').trim().toLowerCase();
      if (targetName.isNotEmpty) {
        for (final rf in returnFamilies) {
          final rn = (rf.name ?? '').trim().toLowerCase();
          if (rn.isNotEmpty && rn == targetName) {
            final rid = (rf.id ?? '').trim();
            if (rid.isNotEmpty) {
              _safeSetState(() {
                _selectedFareIdByOfferId[returnOfferId] = rid;
              });
              _ensureFareRulesLoaded(rid);
            }
            return;
          }
        }
      }

      // 2) Fallback: match by rank among families sorted by price
      final outboundFamilies =
          _fareFamiliesByOfferId[outboundOfferId] ?? const <FareFamilyModel>[];
      final rank = outboundFamilies.isNotEmpty
          ? _rankIndexByPrice(outboundFamilies, selectedFare)
          : 0;

      final entries = returnFamilies.map((f) {
        final p = _parsePriceValue(f.price) ?? double.infinity;
        return MapEntry(f, p);
      }).toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      if (entries.isEmpty) return;
      final idx = rank.clamp(0, entries.length - 1);
      final chosen = entries[idx].key;
      final rid = (chosen.id ?? '').trim();
      if (rid.isNotEmpty) {
        _safeSetState(() {
          _selectedFareIdByOfferId[returnOfferId] = rid;
        });
        _ensureFareRulesLoaded(rid);
      }
    }

    // If return families are not loaded yet, load them first then sync.
    if (!_fareFamiliesByOfferId.containsKey(returnOfferId) &&
        !_fareFamiliesLoading.contains(returnOfferId)) {
      // ignore: unawaited_futures
      _ensureFareFamiliesLoaded(returnOfferId).then((_) {
        if (!mounted) return;
        _safeSetState(pickAndSet);
      });
      return;
    }

    pickAndSet();
  }

  bool _looksLikeNoBaggage(Object? value) {
    if (value == null) return false;
    if (value is bool) return value == false;
    if (value is num) return value <= 0;
    if (value is List) return value.any(_looksLikeNoBaggage);
    if (value is Map) return value.values.any(_looksLikeNoBaggage);
    final s = value.toString().toLowerCase();
    // Explicit "no baggage" / "without baggage" patterns + "0kg" markers
    return s.contains('no baggage') ||
        s.contains('without baggage') ||
        s.contains('без багажа') ||
        s.contains('багаж: нет') ||
        s.contains('багаж нет') ||
        s.contains('багажсиз') ||
        s.contains('багаж йўқ') ||
        RegExp(r'\b0\s*(kg|кг)\b', caseSensitive: false).hasMatch(s);
  }

  Future<void> _ensureFareFamiliesLoaded(String offerId) async {
    if (!mounted) return;
    if (_fareFamiliesByOfferId.containsKey(offerId) ||
        _fareFamiliesLoading.contains(offerId)) {
      return;
    }
    _safeSetState(() {
      _fareFamiliesLoading.add(offerId);
      _fareFamiliesError.remove(offerId);
    });

    try {
      final repo = context.read<AviaBloc>().repository;
      final Either<dynamic, FareFamilyResponseModel> result =
          await repo.fareFamily(offerId);
      if (!mounted) return;
      result.fold(
        (failure) {
          _safeSetState(() {
            _fareFamiliesError[offerId] = failure.toString();
          });
        },
        (response) {
          _safeSetState(() {
            final families = response.families ?? [];
            _fareFamiliesByOfferId[offerId] = families;
            if (families.isNotEmpty &&
                !_selectedFareIdByOfferId.containsKey(offerId)) {
              _selectedFareIdByOfferId[offerId] = families.first.id ?? offerId;
            }
          });
          // Debug: log baggage info for ALL tariffs
          final families = response.families ?? [];
          AppLogger.debug(
            'Tariff baggage debug: offerId=$offerId, families count=${families.length}',
          );
          for (var i = 0; i < families.length; i++) {
            final f = families[i];
            AppLogger.debug(
              'Tariff[$i] (id=${f.id}, name=${f.name}): '
              'handBaggage=${f.handBaggage} (${f.handBaggage.runtimeType}), '
              'handLuggage=${f.handLuggage} (${f.handLuggage.runtimeType}), '
              'carryOn=${f.carryOn} (${f.carryOn.runtimeType}), '
              'baggage=${f.baggage} (${f.baggage.runtimeType}), '
              'checkedBaggage=${f.checkedBaggage} (${f.checkedBaggage.runtimeType}), '
              'description=${f.description?.toString().substring(0, f.description.toString().length > 100 ? 100 : f.description.toString().length)}',
            );
            // Try to extract kg from each tariff
            final handKg = _handKgFromFare(f);
            final bagKg = _bagKgFromFare(f);
            AppLogger.debug(
              'Tariff[$i] extracted kg: hand=$handKg, bag=$bagKg',
            );
          }
          // Preload rules for ALL tariffs to get kg info (since baggage=true is boolean, not Map)
          for (final fare in families) {
            if (fare.id != null && fare.id!.isNotEmpty) {
              // ignore: unawaited_futures
              _ensureFareRulesLoaded(fare.id!);
            }
          }
        },
      );
    } catch (e) {
      _safeSetState(() {
        _fareFamiliesError[offerId] = e.toString();
      });
    } finally {
      _safeSetState(() {
        _fareFamiliesLoading.remove(offerId);
      });
    }
  }

  Future<void> _ensureFareRulesLoaded(String offerId) async {
    if (!mounted) return;
    if (_fareRulesByOfferId.containsKey(offerId) ||
        _fareRulesLoading.contains(offerId)) {
      return;
    }
    _safeSetState(() {
      _fareRulesLoading.add(offerId);
      _fareRulesError.remove(offerId);
    });

    try {
      final repo = context.read<AviaBloc>().repository;
      final Either<dynamic, FareRulesModel> result =
          await repo.fareRules(offerId);
      if (!mounted) return;
      result.fold(
        (failure) {
          _safeSetState(() {
            _fareRulesError[offerId] = failure.toString();
          });
        },
        (rules) {
          _safeSetState(() {
            _fareRulesByOfferId[offerId] = rules;
          });
          // Debug: log rules structure to see what we're getting
          AppLogger.debug(
            'FareRules loaded for offerId=$offerId: '
            'rules count=${rules.rules?.length ?? 0}, '
            'title=${rules.title}, '
            'description=${rules.description}',
          );
          if (rules.rules != null && rules.rules!.isNotEmpty) {
            for (var i = 0; i < rules.rules!.length; i++) {
              final r = rules.rules![i];
              AppLogger.debug(
                'Rule[$i]: type=${r.type}, '
                'description=${r.description}, '
                'allowed=${r.allowed}',
              );
            }
          }
          // Debug: log full JSON structure
          try {
            AppLogger.debug('FareRules full JSON: ${rules.toJson()}');
          } catch (e) {
            AppLogger.debug('Error logging FareRules JSON: $e');
          }
        },
      );
    } catch (e) {
      _safeSetState(() {
        _fareRulesError[offerId] = e.toString();
      });
    } finally {
      _safeSetState(() {
        _fareRulesLoading.remove(offerId);
      });
    }
  }

  Future<void> _toggleTariffs(
      {required OfferModel offer, OfferModel? returnOffer}) async {
    if (!mounted) return;
    final nextExpanded = !_isExpanded;
    _safeSetState(() {
      _isExpanded = nextExpanded;
    });
    if (!nextExpanded) return;

    final outboundId = _baseOfferId(offer);
    if (outboundId != null && outboundId.isNotEmpty) {
      await _ensureFareFamiliesLoaded(outboundId);
    }
    if (widget.isRoundTrip && returnOffer != null) {
      final returnId = _baseOfferId(returnOffer);
      if (returnId != null && returnId.isNotEmpty) {
        await _ensureFareFamiliesLoaded(returnId);
      }
    }
  }

  OfferModel _offerWithSelectedFare(OfferModel offer) {
    final apiId = _apiOfferId(offer.id);
    var normalized = apiId.isNotEmpty && apiId != offer.id
        ? offer.copyWith(id: apiId)
        : offer;

    if (apiId.isEmpty) return normalized;
    final selected = _selectedFareForOfferId(apiId);
    if (selected == null) return normalized;

    return normalized.copyWith(
      id: selected.id ?? normalized.id,
      price: selected.price ?? normalized.price,
      currency: selected.currency ?? normalized.currency,
    );
  }

  int? _extractKgFromAny(Object? value) {
    if (value == null) return null;

    // Direct numeric
    if (value is num) {
      final v = value.toInt();
      return v > 0 ? v : null;
    }

    // Lists: try each element
    if (value is List) {
      for (final e in value) {
        final v = _extractKgFromAny(e);
        if (v != null) return v;
      }
      return null;
    }

    // Maps from API often look like: {piece: 1, weight: 20}
    if (value is Map) {
      Object? pick(Map m, List<String> keys) {
        for (final k in keys) {
          if (m.containsKey(k)) return m[k];
        }
        return null;
      }

      final m = value;

      // Prefer explicit weight fields first
      final weightCandidate = pick(m, const [
        'weight',
        'max_weight',
        'maxWeight',
        'kg',
        'kilograms',
        'kilogram',
      ]);
      final w = _extractKgFromAny(weightCandidate);
      if (w != null) return w;

      // Then human-readable fields like title/value
      final textCandidate = pick(m, const [
        'title',
        'value',
        'description',
        'text',
        'label',
      ]);
      final t = _extractKgFromAny(textCandidate);
      if (t != null) return t;

      // Fallback: scan all values and pick the max number (usually weight > piece count)
      final nums = <int>[];
      for (final e in m.values) {
        final v = _extractKgFromAny(e);
        if (v != null) nums.add(v);
      }
      if (nums.isEmpty) return null;
      nums.sort();
      return nums.last;
    }

    // Strings
    final text = value.toString().trim();
    if (text.isEmpty) return null;

    // Prefer patterns like "8 kg" / "8кг" (very common)
    final kgMatch =
        RegExp(r'(\d{1,3}(?:[.,]\d+)?)\s*(kg|кг)\b', caseSensitive: false)
            .allMatches(text)
            .toList();
    if (kgMatch.isNotEmpty) {
      final rawNum = kgMatch.first.group(1) ?? '';
      final normalized = rawNum.replaceAll(',', '.');
      final n = double.tryParse(normalized);
      if (n != null && n > 0) return n.round();
    }

    // If no explicit kg token, take the maximum number (handles "1 PC 8" or map-toString)
    final matches = RegExp(r'\d+').allMatches(text).toList();
    if (matches.isEmpty) return null;
    final nums = matches
        .map((m) => int.tryParse(m.group(0) ?? ''))
        .whereType<int>()
        .where((n) => n > 0)
        .toList();
    if (nums.isEmpty) return null;
    nums.sort();
    return nums.last;
  }

  int? _extractKgFromRules(String offerId, {required bool isHand}) {
    final rules = _fareRulesByOfferId[offerId];
    if (rules == null) {
      AppLogger.debug(
          '_extractKgFromRules: No rules found for offerId=$offerId');
      return null;
    }
    final items = rules.rules ?? [];
    AppLogger.debug(
      '_extractKgFromRules: offerId=$offerId, isHand=$isHand, rules count=${items.length}',
    );
    for (var i = 0; i < items.length; i++) {
      final r = items[i];
      final type = (r.type ?? '').toLowerCase();
      final desc = (r.description ?? '').toLowerCase();
      final isHandRule = type.contains('hand') ||
          type.contains('cabin') ||
          type.contains('carry');
      final isBaggageRule =
          type.contains('baggage') || type.contains('luggage');

      AppLogger.debug(
        '_extractKgFromRules: Rule[$i] type="$type", '
        'desc="${desc.substring(0, desc.length > 100 ? 100 : desc.length)}", '
        'isHandRule=$isHandRule, isBaggageRule=$isBaggageRule',
      );

      if (isHand && isHandRule) {
        final kg = _extractKgFromAny(r.description);
        AppLogger.debug('_extractKgFromRules: Found hand kg=$kg from rule[$i]');
        if (kg != null) return kg;
      }
      if (!isHand && isBaggageRule && !isHandRule) {
        final kg = _extractKgFromAny(r.description);
        AppLogger.debug(
            '_extractKgFromRules: Found baggage kg=$kg from rule[$i]');
        if (kg != null) return kg;
      }

      // Fallback by description if type is generic
      if (type.isEmpty) {
        if (isHand &&
            (desc.contains('қўл') ||
                desc.contains('ручн') ||
                desc.contains('hand') ||
                desc.contains('cabin'))) {
          final kg = _extractKgFromAny(r.description);
          AppLogger.debug(
              '_extractKgFromRules: Found hand kg=$kg from fallback rule[$i]');
          if (kg != null) return kg;
        }
        if (!isHand &&
            (desc.contains('багаж') ||
                desc.contains('baggage') ||
                desc.contains('luggage'))) {
          final kg = _extractKgFromAny(r.description);
          AppLogger.debug(
              '_extractKgFromRules: Found baggage kg=$kg from fallback rule[$i]');
          if (kg != null) return kg;
        }
      }
    }
    AppLogger.debug(
        '_extractKgFromRules: No kg found for offerId=$offerId, isHand=$isHand');
    return null;
  }

  int? _handKgFromFare(FareFamilyModel fare) {
    // If API explicitly says no hand baggage, do not fallback to segments/defaults.
    if (_looksLikeNoBaggage(fare.handBaggage) ||
        _looksLikeNoBaggage(fare.handLuggage) ||
        _looksLikeNoBaggage(fare.carryOn)) {
      return 0;
    }
    // Try all possible hand baggage fields in order of preference
    final candidates = [
      fare.handBaggage,
      fare.handLuggage,
      fare.carryOn,
      fare.description,
    ];

    // Debug: log all candidates
    AppLogger.debug(
      '_handKgFromFare: fareId=${fare.id}, '
      'handBaggage=${fare.handBaggage} (${fare.handBaggage.runtimeType}), '
      'handLuggage=${fare.handLuggage} (${fare.handLuggage.runtimeType}), '
      'carryOn=${fare.carryOn} (${fare.carryOn.runtimeType}), '
      'description=${fare.description?.toString().substring(0, fare.description.toString().length > 50 ? 50 : fare.description.toString().length)}',
    );

    for (final candidate in candidates) {
      if (candidate == null) continue;
      final kg = _extractKgFromAny(candidate);
      if (kg != null && kg >= 0) {
        AppLogger.debug(
            '_handKgFromFare: found $kg from ${candidate.runtimeType}, fareId=${fare.id}');
        return kg;
      }
    }
    AppLogger.debug('_handKgFromFare: No kg found, fareId=${fare.id}');
    return null;
  }

  int? _bagKgFromFare(FareFamilyModel fare) {
    // If API explicitly says no checked baggage, show 0kg (do not fallback to segment/default).
    if (_looksLikeNoBaggage(fare.baggage) ||
        _looksLikeNoBaggage(fare.checkedBaggage) ||
        _looksLikeNoBaggage(fare.description)) {
      return 0;
    }
    // Try all possible baggage fields in order of preference
    final candidates = [
      fare.baggage,
      fare.checkedBaggage,
      fare.description,
    ];

    // Debug: log all candidates
    AppLogger.debug(
      '_bagKgFromFare: fareId=${fare.id}, '
      'baggage=${fare.baggage} (${fare.baggage.runtimeType}), '
      'checkedBaggage=${fare.checkedBaggage} (${fare.checkedBaggage.runtimeType}), '
      'description=${fare.description?.toString().substring(0, fare.description.toString().length > 50 ? 50 : fare.description.toString().length)}',
    );

    for (final candidate in candidates) {
      if (candidate == null) continue;
      final kg = _extractKgFromAny(candidate);
      if (kg != null && kg >= 0) {
        AppLogger.debug(
            '_bagKgFromFare: found $kg from ${candidate.runtimeType}, fareId=${fare.id}');
        return kg;
      }
    }
    AppLogger.debug('_bagKgFromFare: No kg found, fareId=${fare.id}');
    return null;
  }

  String _textFromAny(Object? value) {
    final s = value?.toString().trim() ?? '';
    return s;
  }

  String _exchangeTextFromFare(FareFamilyModel fare) {
    final raw = [
      _textFromAny(fare.exchange),
      _textFromAny(fare.change),
      _textFromAny(fare.description),
    ].where((e) => e.isNotEmpty).join(' ');
    if (raw.toLowerCase().contains('free') ||
        raw.toLowerCase().contains('бесплат')) {
      return 'бепул';
    }
    if (raw.toLowerCase().contains('paid') ||
        raw.toLowerCase().contains('платн') ||
        raw.toLowerCase().contains('пуллик')) {
      return 'пуллик';
    }
    return 'пуллик';
  }

  String _refundTextFromFare(FareFamilyModel fare) {
    final raw = [
      _textFromAny(fare.refund),
      _textFromAny(fare.returnPolicy),
      _textFromAny(fare.description),
    ].where((e) => e.isNotEmpty).join(' ');
    if (raw.toLowerCase().contains('free') ||
        raw.toLowerCase().contains('бесплат')) {
      return 'бепул';
    }
    if (raw.toLowerCase().contains('paid') ||
        raw.toLowerCase().contains('платн') ||
        raw.toLowerCase().contains('пуллик')) {
      return 'пуллик';
    }
    if (raw.toLowerCase().contains('no') ||
        raw.toLowerCase().contains('нельзя') ||
        raw.toLowerCase().contains('эмас')) {
      return 'мумкин эмас';
    }
    return 'пуллик';
  }

  String _exchangeTextFromRules(String offerId) {
    final rules = _fareRulesByOfferId[offerId];
    if (rules == null) return 'пуллик';
    for (final r in rules.rules ?? []) {
      final type = (r.type ?? '').toLowerCase();
      final desc = (r.description ?? '').toLowerCase();
      if (type.contains('change') || type.contains('exchange')) {
        if (r.allowed == false) return 'мумкин эмас';
        if (desc.contains('бесплат') || desc.contains('free')) return 'бепул';
        if (desc.contains('платн') ||
            desc.contains('paid') ||
            desc.contains('пуллик')) {
          return 'пуллик';
        }
        return 'пуллик';
      }
    }
    return 'пуллик';
  }

  String _refundTextFromRules(String offerId) {
    final rules = _fareRulesByOfferId[offerId];
    if (rules == null) return 'мумкин эмас';
    for (final r in rules.rules ?? []) {
      final type = (r.type ?? '').toLowerCase();
      final desc = (r.description ?? '').toLowerCase();
      if (type.contains('refund') || type.contains('return')) {
        if (r.allowed == false) return 'мумкин эмас';
        if (desc.contains('бесплат') || desc.contains('free')) return 'бепул';
        if (desc.contains('платн') ||
            desc.contains('paid') ||
            desc.contains('пуллик')) {
          return 'пуллик';
        }
        return 'пуллик';
      }
    }
    return 'мумкин эмас';
  }

  int? _bestKgFromSegments(List<SegmentModel> segs, {required bool isHand}) {
    final values = <int>[];
    for (final s in segs) {
      final raw = isHand ? s.handBaggage : s.baggage;
      if (raw == null || raw.trim().isEmpty) continue;
      final v = _extractKgFromAny(raw);
      if (v != null && v > 0) values.add(v);
    }
    if (values.isEmpty) return null;
    values.sort();
    return values.first; // most restrictive
  }

  /// Round-trip uchun barcha segmentlarni olish (outbound + inbound)
  List<SegmentModel> _getAllSegments(
      OfferModel offer, OfferModel? returnOffer) {
    final allSegments = <SegmentModel>[];
    if (offer.segments != null) {
      allSegments.addAll(offer.segments!);
    }
    if (returnOffer?.segments != null) {
      allSegments.addAll(returnOffer!.segments!);
    }
    return allSegments;
  }

  Widget _buildFareIconsRow({
    required bool isDark,
    required Color subtitleColor,
    required int handKg,
    required int bagKg,
    required String exchangeText,
    required String refundText,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TapBubbleTooltip(
          message: "Қўл юки оғирлиги – $handKg кг.",
          child: _buildActionIcon(
            icon: Icons.lock_outline_rounded,
            label: '$handKg',
            isDark: isDark,
            textColor: subtitleColor,
            labelColor: AppColors.primaryBlue,
          ),
        ),
        SizedBox(width: 12.w),
        TapBubbleTooltip(
          message: "Багаж оғирлиги – $bagKg кг.",
          child: _buildActionIcon(
            icon: Icons.luggage_outlined,
            label: '$bagKg',
            isDark: isDark,
            textColor: subtitleColor,
            labelColor: AppColors.primaryBlue,
          ),
        ),
        SizedBox(width: 12.w),
        TapBubbleTooltip(
          message: "Билет алмаштириш: $exchangeText",
          child: _buildActionIcon(
            icon: Icons.swap_horiz_rounded,
            isDark: isDark,
            textColor: subtitleColor,
          ),
        ),
        SizedBox(width: 12.w),
        TapBubbleTooltip(
          message: "Билет қайтариш: $refundText",
          child: _buildActionIcon(
            icon: Icons.close_rounded,
            isDark: isDark,
            textColor: Colors.red,
          ),
        ),
      ],
    );
  }

  String? _formatAirportDetailLine({
    required String airportCode,
    String? airportName,
    String? terminal,
  }) {
    final code = airportCode.trim();
    final name = (airportName ?? '').trim();
    final terminalStr = (terminal ?? '').trim();

    final parts = <String>[];
    if (name.isNotEmpty && name.toUpperCase() != code.toUpperCase()) {
      parts.add(name);
    }
    if (code.isNotEmpty) {
      parts.add(code);
    }
    var result = parts.join(', ');
    if (terminalStr.isNotEmpty) {
      result = '$result (Терминал $terminalStr)';
    }
    return result.isEmpty ? null : result;
  }

  String _formatDateOnlyForCard(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    try {
      final dt = _parseDateTime(timeStr);
      if (dt == null) return '';

      final months = [
        'avia.months.short.jan'.tr(),
        'avia.months.short.feb'.tr(),
        'avia.months.short.mar'.tr(),
        'avia.months.short.apr'.tr(),
        'avia.months.short.may'.tr(),
        'avia.months.short.jun'.tr(),
        'avia.months.short.jul'.tr(),
        'avia.months.short.aug'.tr(),
        'avia.months.short.sep'.tr(),
        'avia.months.short.oct'.tr(),
        'avia.months.short.nov'.tr(),
        'avia.months.short.dec'.tr(),
      ];
      final weekdays = [
        'dush.',
        'sesh.',
        'chor.',
        'pay.',
        'jum.',
        'shan.',
        'yak.'
      ];
      final weekday = weekdays[(dt.weekday - 1).clamp(0, 6)];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $weekday';
    } catch (_) {
      return '';
    }
  }

  String _formatDurationReadable(String duration) {
    // Supports strings like: "2 h 35 m", "2h 35m", "2ч 35м"
    final nums = RegExp(r'\d+')
        .allMatches(duration)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    if (nums.isEmpty) return duration;
    final h = nums.isNotEmpty ? nums[0] : 0;
    final m = nums.length > 1 ? nums[1] : 0;
    if (h > 0 && m > 0) return '$h соат $m дақ';
    if (h > 0) return '$h соат';
    if (m > 0) return '$m дақ';
    return duration;
  }

  String _normalizeCabinClass(String? cabin) {
    final raw = (cabin ?? '').trim();
    if (raw.isEmpty) return '';
    final normalized = raw.toLowerCase();
    if (['economy', 'eco', 'y', 'e'].contains(normalized)) return 'Эконом';
    if (['business', 'biz', 'j', 'c'].contains(normalized)) return 'Бизнес';
    if (['first', 'f'].contains(normalized)) return 'First';
    return raw;
  }

  String _fallbackTariffNameByRank({required int rank, required int total}) {
    if (total <= 1) return 'Economy Flex';
    if (total == 2) return rank == 0 ? 'Economy Flex' : 'Economy Flex Plus';
    // total >= 3
    if (rank <= 0) return 'Economy Flex';
    if (rank >= total - 1) return 'Business Flex Plus';
    return 'Economy Flex Plus';
  }

  int _rankIndexByPrice(List<FareFamilyModel> families, FareFamilyModel fare) {
    final entries = families.map((f) {
      final p = _parsePriceValue(f.price) ?? double.infinity;
      return MapEntry(f, p);
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final idx = entries.indexWhere((e) => (e.key.id ?? '') == (fare.id ?? ''));
    return idx >= 0 ? idx : 0;
  }

  String _displayTariffName({
    required String offerId,
    required FareFamilyModel fare,
    required int fallbackIndex,
  }) {
    final n = (fare.name ?? '').trim();
    if (n.isNotEmpty) return n;

    final d = (fare.description ?? '').trim();
    if (d.isNotEmpty) {
      final firstLine = d.split('\n').first.trim();
      if (firstLine.isNotEmpty) return firstLine;
    }

    final fams = _fareFamiliesByOfferId[offerId] ?? const <FareFamilyModel>[];
    final rank =
        fams.isNotEmpty ? _rankIndexByPrice(fams, fare) : fallbackIndex;
    final total = fams.isNotEmpty ? fams.length : 0;
    return _fallbackTariffNameByRank(rank: rank, total: total);
  }

  String _selectedTariffNameForOffer(OfferModel offer) {
    final apiOfferId = _apiOfferId(offer.id);
    if (apiOfferId.isEmpty) return '';
    final selected = _selectedFareForOfferId(apiOfferId);
    final name = (selected?.name ?? '').trim();
    if (name.isNotEmpty) return name;
    if (selected != null) {
      // If API name is missing, infer by rank among families (cheapest/middle/best)
      final families = _fareFamiliesByOfferId[apiOfferId];
      if (families != null && families.isNotEmpty) {
        final rank = _rankIndexByPrice(families, selected);
        return _fallbackTariffNameByRank(rank: rank, total: families.length);
      }
    }
    return '';
  }

  void _showTariffDetailsSheet({
    required BuildContext context,
    required bool isDark,
    required Color subtitleColor,
    required String title,
    required String priceText,
    required String handText,
    required String bagText,
    required String exchangeText,
    required String refundText,
    required String details,
  }) {
    final theme = Theme.of(context);
    final textColor = isDark ? Colors.white : AppColors.charcoal;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              12.h,
              16.w,
              16.h + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: subtitleColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 10.h),
                _tariffLine(
                  icon: Icons.lock_outline_rounded,
                  text: handText,
                  color: subtitleColor,
                  maxLines: 3,
                ),
                SizedBox(height: 6.h),
                _tariffLine(
                  icon: Icons.luggage_outlined,
                  text: bagText,
                  color: subtitleColor,
                  maxLines: 3,
                ),
                SizedBox(height: 6.h),
                _tariffLine(
                  icon: Icons.swap_horiz_rounded,
                  text: exchangeText,
                  color: subtitleColor,
                  maxLines: 3,
                ),
                SizedBox(height: 6.h),
                _tariffLine(
                  icon: Icons.close_rounded,
                  text: refundText,
                  color: subtitleColor,
                  maxLines: 3,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Батафсил',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Text(
                      details.isEmpty ? 'Маълумот мавжуд эмас' : details,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.35,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls({
    required BuildContext context,
    required bool isDark,
    required Color subtitleColor,
    required OfferModel offer,
    OfferModel? returnOffer,
    required void Function(OfferModel offer, OfferModel? returnOffer)? onTap,
  }) {
    final apiOfferId = _apiOfferId(offer.id);
    final selectedFare =
        apiOfferId.isEmpty ? null : _selectedFareForOfferId(apiOfferId);
    final selectedOfferId = selectedFare?.id ?? apiOfferId;

    // Round-trip uchun ikkala offer uchun ham kg olish
    final segs = offer.segments ?? const <SegmentModel>[];
    final returnSegs = returnOffer?.segments ?? const <SegmentModel>[];
    final allSegs = [...segs, ...returnSegs];

    // Outbound offer uchun tanlangan tarif bo'yicha kg
    final rulesHand = selectedFare != null
        ? _extractKgFromRules(selectedOfferId, isHand: true)
        : null;
    final rulesBag = selectedFare != null
        ? _extractKgFromRules(selectedOfferId, isHand: false)
        : null;
    final fareHand =
        selectedFare != null ? _handKgFromFare(selectedFare) : null;
    final fareBag = selectedFare != null ? _bagKgFromFare(selectedFare) : null;
    final segmentHand = (rulesHand == null && fareHand == null)
        ? _bestKgFromSegments(allSegs.isNotEmpty ? allSegs : segs, isHand: true)
        : null;
    final segmentBag = (rulesBag == null && fareBag == null)
        ? _bestKgFromSegments(allSegs.isNotEmpty ? allSegs : segs,
            isHand: false)
        : null;

    final handKg = rulesHand ?? fareHand ?? segmentHand ?? 8;
    final bagKg = rulesBag ?? fareBag ?? segmentBag ?? 20;

    // Debug: asosiy cardda kg qayerdan olinganini log qilish
    AppLogger.debug(
      '_buildBottomControls kg: offerId=$apiOfferId, selectedFare=${selectedFare?.id}, '
      'hand=$handKg (rules=$rulesHand, fare=$fareHand, segment=$segmentHand), '
      'bag=$bagKg (rules=$rulesBag, fare=$fareBag, segment=$segmentBag)',
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap == null
                ? null
                : () => onTap(
                      _offerWithSelectedFare(offer),
                      returnOffer == null
                          ? null
                          : _offerWithSelectedFare(returnOffer),
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: Text(
              "Танлаш",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _toggleTariffs(offer: offer, returnOffer: returnOffer),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.grayLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Тарифлар',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(width: 6.w),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryBlue,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final segments = widget.offer.segments ?? [];

    // Agar borish-kelish bo'lsa va returnOffer mavjud bo'lsa
    if (widget.isRoundTrip && widget.returnOffer != null) {
      final inboundSegments = widget.returnOffer!.segments ?? [];

      AppLogger.debug(
        'TicketCard: Round trip - wrapping both flights in one card',
      );
      final cardColor = isDark ? const Color(0xFF1E1E1E) : theme.cardColor;

      return Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1)
              : Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          children: [
            // Borish parvoz karta
            _buildFlightCard(
              context: context,
              theme: theme,
              isDark: isDark,
              segments: segments,
              offer: widget.offer,
              isOutbound: true,
              onTap: widget.onTap,
              isWrapped: true,
              isFirst: true,
              renderExpandedDetails: false,
              renderBottomControls: false,
            ),
            // Ajratuvchi chiziq
            Divider(
              height: 1,
              thickness: 1,
              color:
                  (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.2),
            ),
            // Kelish parvoz karta
            _buildFlightCard(
              context: context,
              theme: theme,
              isDark: isDark,
              segments: inboundSegments,
              offer: widget.returnOffer!,
              isOutbound: false,
              onTap: widget.onTap,
              isWrapped: true,
              isFirst: false,
              renderExpandedDetails: false,
              renderBottomControls: false,
            ),
            // Expanded details should appear AFTER both mini-cards (and above bottom controls)
            if (_isExpanded)
              Padding(
                padding:
                    EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 0),
                child: Column(
                  children: [
                    _buildExpandedDetails(
                      context: context,
                      segments: segments,
                      offer: widget.offer,
                      isDark: isDark,
                      textColor: isDark ? Colors.white : AppColors.charcoal,
                      subtitleColor:
                          isDark ? Colors.white70 : AppColors.gray500,
                      showTariffPicker: false,
                      returnOffer: widget.returnOffer,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildExpandedDetails(
                      context: context,
                      segments: inboundSegments,
                      offer: widget.returnOffer!,
                      isDark: isDark,
                      textColor: isDark ? Colors.white : AppColors.charcoal,
                      subtitleColor:
                          isDark ? Colors.white70 : AppColors.gray500,
                      showTariffPicker: false,
                      returnOffer: widget.offer,
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Round-trip: show tariff picker only once for the whole card.
                    if (_apiOfferId(widget.offer.id).isNotEmpty)
                      _buildTariffPicker(
                        offerId: _apiOfferId(widget.offer.id),
                        isDark: isDark,
                        textColor: isDark ? Colors.white : AppColors.charcoal,
                        subtitleColor:
                            isDark ? Colors.white70 : AppColors.gray500,
                        segments:
                            _getAllSegments(widget.offer, widget.returnOffer),
                        returnOfferId: widget.returnOffer != null
                            ? _apiOfferId(widget.returnOffer!.id)
                            : null,
                      ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                _isExpanded ? AppSpacing.md : 0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: _buildBottomControls(
                context: context,
                isDark: isDark,
                subtitleColor: isDark ? Colors.white70 : AppColors.gray500,
                offer: widget.offer,
                returnOffer: widget.returnOffer,
                onTap: widget.onTap,
              ),
            ),
          ],
        ),
      );
    }

    // Bir tomonlama - oddiy ko'rsatish
    return _buildFlightCard(
      context: context,
      theme: theme,
      isDark: isDark,
      segments: segments,
      offer: widget.offer,
      isOutbound: true,
      onTap: widget.onTap,
      isWrapped: false,
      isFirst: true,
    );
  }

  // Har bir parvoz uchun alohida karta
  Widget _buildFlightCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required List<SegmentModel> segments,
    required OfferModel offer,
    required bool isOutbound,
    void Function(OfferModel offer, OfferModel? returnOffer)? onTap,
    bool isWrapped = false,
    bool isFirst = true,
    bool renderExpandedDetails = true,
    bool renderBottomControls = true,
  }) {
    final isDirect = _isDirect(segments);
    final stops = _getStopsText(segments);
    final departureTime = _formatTime(segments.first.departureTime);
    final arrivalTime = _formatTime(segments.last.arrivalTime);
    final departureDate = _getDateFromTime(segments.first.departureTime);
    final fromCode = _getAirportCode(segments, true);
    final toCode = _getAirportCode(segments, false);
    final duration = _getFlightDuration(segments);

    final cardColor = isDark ? const Color(0xFF1E1E1E) : theme.cardColor;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final subtitleColor = isDark ? Colors.white70 : AppColors.gray500;
    final apiOfferId = _apiOfferId(offer.id);
    final selectedFare =
        apiOfferId.isEmpty ? null : _selectedFareForOfferId(apiOfferId);
    final rawDisplayPrice = selectedFare?.price ?? offer.price;
    final rawParsedPrice = _FlightUtils.parsePriceValue(rawDisplayPrice) ?? 0;
    final parsedPrice = rawParsedPrice * 1.1; // Apply 10% commission
    final displayPrice = parsedPrice.toStringAsFixed(0);
    final displayCurrency = selectedFare?.currency ?? offer.currency;
    // Tarif nomini _selectedTariffNameForOffer funksiyasidan olish (fallback bilan)
    final selectedFareName = _selectedTariffNameForOffer(offer);
    final routeText = '$fromCode - $toCode';

    final metaParts = <String>[];
    final fn =
        (segments.isNotEmpty ? (segments.first.flightNumber ?? '') : '').trim();
    if (fn.isNotEmpty) metaParts.add('Рейс $fn');
    final aircraft =
        (segments.isNotEmpty ? (segments.first.aircraft ?? '') : '').trim();
    if (aircraft.isNotEmpty) metaParts.add(aircraft);
    final cabinFallback = segments.isNotEmpty
        ? _normalizeCabinClass(segments.first.cabinClass)
        : '';
    // Prefer cabin class from segments; selected fare name can be confusing/duplicated.
    final cabin = cabinFallback.isNotEmpty ? cabinFallback : selectedFareName;
    if (cabin.trim().isNotEmpty) metaParts.add(cabin.trim());
    final metaLine = metaParts.join(' • ');

    return Container(
      margin:
          isWrapped ? EdgeInsets.zero : EdgeInsets.only(bottom: AppSpacing.md),
      decoration: isWrapped
          ? null
          : BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: isDark
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.1), width: 1)
                  : Border.all(
                      color: Colors.grey.withValues(alpha: 0.1), width: 1),
            ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Aviakompaniya va Narx
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildAirlineNameOrLogo(
                              logoPath: _airlineLogoPath(segments),
                              fallback:
                                  offer.airline ?? 'avia.results.unknown_airline'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                                color: textColor,
                              ),
                            ),
                          ),
                          // For the second (return) mini-card there is no price column,
                          // so show route chip on the right of the airline row.
                          if (isWrapped && !isFirst) ...[
                            SizedBox(width: 8.w),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 110.w),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color:
                                        subtitleColor.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Text(
                                  routeText,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isWrapped || isFirst) ...[
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayPrice != null
                                ? _formatPriceHuman(displayPrice)
                                : 'avia.results.price'.tr(),
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              displayCurrency ?? 'so\'m',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 110.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: subtitleColor.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            routeText,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            // Sana
            Text(
              departureDate,
              style: TextStyle(
                fontSize: 13.sp,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (metaLine.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                metaLine,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 14.h),
            // Parvoz ma'lumotlari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ketish
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flight_takeoff_rounded,
                            size: 18.sp,
                            color: AppColors.primaryBlue,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                departureTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24.sp,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _getCityName(fromCode),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '($fromCode)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: subtitleColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // O'rtadagi chiziq
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.grayLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: subtitleColor.withValues(alpha: 0.25),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 26.w,
                                  height: 26.w,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBlue
                                          .withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 14.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                Container(
                                  width: 26.w,
                                  height: 26.w,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBlue
                                          .withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.flight_land_rounded,
                                    size: 14.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: subtitleColor.withValues(alpha: 0.22),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isDirect ? "Тўғридан тўғри" : (stops ?? ""),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Yetib borish
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                arrivalTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24.sp,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.flight_land_rounded,
                            size: 18.sp,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _getCityName(toCode),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '($toCode)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: subtitleColor.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Expanded details (above bottom controls)
            if (renderExpandedDetails && _isExpanded) ...[
              SizedBox(height: AppSpacing.md),
              _buildExpandedDetails(
                context: context,
                segments: segments,
                offer: offer,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ],
            // Give space between expanded details (incl. tariff cards) and the selected tariff row.
            if (renderExpandedDetails &&
                _isExpanded &&
                renderBottomControls &&
                (!isWrapped || isFirst))
              SizedBox(height: AppSpacing.md),
            if (renderBottomControls && (!isWrapped || isFirst))
              _buildBottomControls(
                context: context,
                isDark: isDark,
                subtitleColor: subtitleColor,
                offer: offer,
                onTap: onTap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    String? label,
    required bool isDark,
    Color? textColor,
    Color? labelColor,
  }) {
    final iconColor =
        textColor ?? (isDark ? Colors.white70 : AppColors.gray500);
    final badgeColor = labelColor ?? AppColors.primaryBlue;
    final labelStr = (label ?? '').trim();

    // Show number INSIDE the icon as a small badge, while keeping the icon clearly visible.
    return SizedBox(
      width: 28.w,
      height: 28.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22.sp,
          ),
          if (labelStr.isNotEmpty)
            Positioned(
              right: 1.w,
              bottom: 1.w,
              child: Container(
                constraints: BoxConstraints(minWidth: 14.w, minHeight: 14.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(3.r),
                  border: Border.all(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  labelStr,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails({
    required BuildContext context,
    required List<SegmentModel> segments,
    required OfferModel offer,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    bool showTariffPicker = true,
    OfferModel? returnOffer,
  }) {
    final theme = Theme.of(context);
    final offerId = _apiOfferId(offer.id);
    final selectedFare =
        offerId.isEmpty ? null : _selectedFareForOfferId(offerId);
    final selectedOfferId =
        selectedFare?.id ?? (offerId.isEmpty ? null : offerId);

    // Round-trip uchun ikkala yo'nalish uchun ham bir xil kg olish
    final returnSegs = returnOffer?.segments ?? const <SegmentModel>[];
    final allSegs = [...segments, ...returnSegs];

    // Tanlangan tarif bo'yicha kg olish (fallback bilan)
    final rulesHand = selectedFare != null
        ? _extractKgFromRules(selectedOfferId!, isHand: true)
        : null;
    final rulesBag = selectedFare != null
        ? _extractKgFromRules(selectedOfferId!, isHand: false)
        : null;
    final fareHand =
        selectedFare != null ? _handKgFromFare(selectedFare) : null;
    final fareBag = selectedFare != null ? _bagKgFromFare(selectedFare) : null;
    final segmentHand = (rulesHand == null && fareHand == null)
        ? _bestKgFromSegments(allSegs.isNotEmpty ? allSegs : segments,
            isHand: true)
        : null;
    final segmentBag = (rulesBag == null && fareBag == null)
        ? _bestKgFromSegments(allSegs.isNotEmpty ? allSegs : segments,
            isHand: false)
        : null;

    final handKg = rulesHand ?? fareHand ?? segmentHand ?? 8;
    final bagKg = rulesBag ?? fareBag ?? segmentBag ?? 20;

    final exchangeText = selectedFare != null
        ? _exchangeTextFromRules(selectedOfferId!)
        : 'пуллик';
    final refundText = selectedFare != null
        ? _refundTextFromRules(selectedOfferId!)
        : 'мумкин эмас';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAirlineNameOrLogo(
                  logoPath: _airlineLogoPath(segments),
                  fallback: offer.airline ?? 'avia.results.unknown_airline'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildFareIconsRow(
                  isDark: isDark,
                  subtitleColor: subtitleColor,
                  handKg: handKg,
                  bagKg: bagKg,
                  exchangeText: exchangeText,
                  refundText: refundText,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16.sp,
                      color: AppColors.orangeWarning,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Kutish vaqti: ${_getLayoverDuration(segments[i - 1], segments[i])}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: subtitleColor.withValues(alpha: 0.2)),
              SizedBox(height: 12.h),
            ],
            _buildSegmentDetail(
              segment: segments[i],
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              offer: offer,
            ),
          ],
          if (showTariffPicker && offerId.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            _buildTariffPicker(
              offerId: offerId,
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              segments: segments,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTariffPicker({
    required String offerId,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    List<SegmentModel>? segments,
    String? returnOfferId,
  }) {
    final theme = Theme.of(context);
    final isLoading = _fareFamiliesLoading.contains(offerId);
    final error = _fareFamiliesError[offerId];
    final families = _fareFamiliesByOfferId[offerId];
    final selectedId = _selectedFareIdByOfferId[offerId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тарифлар',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 10.h),
        if (isLoading && (families == null || families.isEmpty))
          SizedBox(
            height: 200.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, __) {
                return SizedBox(
                  width: 260.w,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: subtitleColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                              color: subtitleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            height: 22.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                              color: subtitleColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          for (var k = 0; k < 4; k++) ...[
                            Container(
                              height: 12.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: subtitleColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else if (error != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Тарифларни юклаб бўлмади',
                  style: TextStyle(fontSize: 12.sp, color: subtitleColor),
                ),
              ),
              TextButton(
                onPressed: () => _ensureFareFamiliesLoaded(offerId),
                child: Text(
                  'Қайта',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          )
        else if (families == null || families.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 200.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: families.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, idx) {
                final f = families[idx];
                final isSelected = (selectedId != null && f.id == selectedId);
                final fareOfferId = f.id ?? '';
                final name = _displayTariffName(
                  offerId: offerId,
                  fare: f,
                  fallbackIndex: idx,
                );

                // 1) Try /rules per-fare-id
                final rulesHand = fareOfferId.isNotEmpty
                    ? _extractKgFromRules(fareOfferId, isHand: true)
                    : null;
                final rulesBag = fareOfferId.isNotEmpty
                    ? _extractKgFromRules(fareOfferId, isHand: false)
                    : null;

                // 2) Then /fare-family fields
                final fareHand = _handKgFromFare(f);
                final fareBag = _bagKgFromFare(f);

                final int? hand = rulesHand ?? fareHand;
                final int? bag = rulesBag ?? fareBag;

                final ex = fareOfferId.isNotEmpty
                    ? _exchangeTextFromRules(fareOfferId)
                    : _exchangeTextFromFare(f);
                final rf = fareOfferId.isNotEmpty
                    ? _refundTextFromRules(fareOfferId)
                    : _refundTextFromFare(f);

                final rawPrice = (f.price ?? '0').toString();
                final pVal = _FlightUtils.parsePriceValue(rawPrice) ?? 0;
                final commissionPrice = pVal * 1.1;
                final price = commissionPrice.toStringAsFixed(0);
                final currency = (f.currency ?? '').toString().trim();

                final isRulesLoading = fareOfferId.isNotEmpty &&
                    _fareRulesLoading.contains(fareOfferId) &&
                    isSelected;

                return SizedBox(
                  width: 260.w,
                  child: InkWell(
                    onTap: () {
                      final fid = (f.id ?? '').trim();
                      if (fid.isEmpty) return;

                      _safeSetState(() {
                        _selectedFareIdByOfferId[offerId] = fid;
                      });
                      _ensureFareRulesLoaded(fid);

                      if (returnOfferId != null && returnOfferId.isNotEmpty) {
                        _syncReturnFareSelection(
                          outboundOfferId: offerId,
                          selectedFare: f,
                          returnOfferId: returnOfferId,
                        );
                      }
                    },
                    onLongPress: () {
                      final details = (f.description ?? '').trim();
                      _showTariffDetailsSheet(
                        context: context,
                        isDark: isDark,
                        subtitleColor: subtitleColor,
                        title: name,
                        priceText: price.trim().isEmpty
                            ? ''
                            : '${_formatPrice(price)} ${currency.isEmpty ? "сум" : currency}',
                        handText: hand == null
                            ? 'Қўл юки: — кг'
                            : 'Қўл юки: $hand кг',
                        bagText: bag == null ? 'Багаж: — кг' : 'Багаж: $bag кг',
                        exchangeText: 'Билет алмаштириш: $ex',
                        refundText: 'Билет қайтариш: $rf',
                        details: details,
                      );
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : subtitleColor.withValues(alpha: 0.25),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isRulesLoading)
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                else if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            if (price.trim().isNotEmpty)
                              Text(
                                '${_formatPrice(price)} ${currency.isEmpty ? "сум" : currency}',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBlue,
                                  height: 1.05,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            SizedBox(height: 8.h),
                            if (hand != null)
                              _tariffLine(
                                icon: Icons.lock_outline_rounded,
                                text: 'Қўл юки: $hand кг',
                                color: subtitleColor,
                                maxLines: 1,
                              ),
                            if (bag != null) ...[
                              SizedBox(height: 3.h),
                              _tariffLine(
                                icon: Icons.luggage_outlined,
                                text: 'Багаж: $bag кг',
                                color: subtitleColor,
                                maxLines: 1,
                              ),
                            ],
                            SizedBox(height: 3.h),
                            _tariffLine(
                              icon: Icons.swap_horiz_rounded,
                              text: 'Билет алмаштириш: $ex',
                              color: subtitleColor,
                              maxLines: 1,
                            ),
                            SizedBox(height: 3.h),
                            _tariffLine(
                              icon: Icons.close_rounded,
                              text: 'Билет қайтариш: $rf',
                              color: subtitleColor,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _tariffLine({
    required IconData icon,
    required String text,
    required Color color,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: color, height: 1.2),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getLayoverDuration(SegmentModel prev, SegmentModel next) {
    try {
      final arrival = _parseDateTime(prev.arrivalTime ?? '');
      final departure = _parseDateTime(next.departureTime ?? '');
      if (arrival != null && departure != null) {
        final duration = departure.difference(arrival);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        return "${hours}s ${minutes}d";
      }
    } catch (_) {}
    return "--";
  }

  Widget _buildSegmentDetail({
    required SegmentModel segment,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    OfferModel? offer,
  }) {
    final departureTime = _formatTime(segment.departureTime);
    final arrivalTime = _formatTime(segment.arrivalTime);
    final duration = _getSingleSegmentDuration(segment);

    final metaParts = <String>[];
    final fn = (segment.flightNumber ?? '').trim();
    if (fn.isNotEmpty) metaParts.add('Reys $fn');
    final aircraft = (segment.aircraft ?? '').trim();
    if (aircraft.isNotEmpty) metaParts.add(aircraft);

    // Tarif tanlanganda, tanlangan tarif nomini ko'rsatish, aks holda cabin class
    String? tariffName;
    if (offer != null) {
      tariffName = _selectedTariffNameForOffer(offer);
    }
    final cabin = tariffName?.isNotEmpty == true
        ? tariffName!
        : _normalizeCabinClass(segment.cabinClass);
    if (cabin.isNotEmpty) metaParts.add(cabin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_formatTime(segment.departureTime) != '--:--') ...[
          Text(
            "Учиш (маҳаллий вақт)\n${_formatTime(segment.departureTime)} • ${_formatDateOnlyForCard(segment.departureTime)}",
            style: TextStyle(
              fontSize: 12.sp,
              color: subtitleColor,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        // Airline logo/name is shown in the expanded header; avoid repeating it per-segment
        if (metaParts.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Text(
            [
              if ((segment.flightNumber ?? '').trim().isNotEmpty)
                'Рейс ${(segment.flightNumber ?? '').trim()}',
              if ((segment.aircraft ?? '').trim().isNotEmpty)
                (segment.aircraft ?? '').trim(),
              cabin,
            ].where((e) => e.trim().isNotEmpty).join(' • '),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
        ] else ...[
          SizedBox(height: 10.h),
        ],
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Text(
                    departureTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: textColor,
                    ),
                  ),
                  Expanded(child: Container()),
                  Text(
                    arrivalTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Column(
                children: [
                  Icon(
                    Icons.flight_takeoff_rounded,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  Icon(
                    Icons.flight_land_rounded,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCityName(segment.departureAirport ?? ''),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: textColor,
                          ),
                        ),
                        Builder(
                          builder: (_) {
                            final line = _formatAirportDetailLine(
                              airportCode: segment.departureAirport ?? '',
                              airportName: segment.departureAirportName,
                              terminal: segment.departureTerminal,
                            );
                            if (line == null) return const SizedBox.shrink();
                            return Text(
                              line,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: subtitleColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCityName(segment.arrivalAirport ?? ''),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: textColor,
                          ),
                        ),
                        Builder(
                          builder: (_) {
                            final line = _formatAirportDetailLine(
                              airportCode: segment.arrivalAirport ?? '',
                              airportName: segment.arrivalAirportName,
                              terminal: segment.arrivalTerminal,
                            );
                            if (line == null) return const SizedBox.shrink();
                            return Text(
                              line,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: subtitleColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Divider(height: 1, color: subtitleColor.withValues(alpha: 0.2)),
        SizedBox(height: 12.h),
        if (_formatTime(segment.arrivalTime) != '--:--')
          Text(
            "Етиб келиш (маҳаллий вақт)\n${_formatTime(segment.arrivalTime)} • ${_formatDateOnlyForCard(segment.arrivalTime)}\nЙўлда: ${_formatDurationReadable(duration)}",
            style: TextStyle(
              fontSize: 12.sp,
              color: subtitleColor,
              height: 1.35,
            ),
          ),
      ],
    );
  }

  String _getSingleSegmentDuration(SegmentModel segment) {
    if (segment.departureTime == null || segment.arrivalTime == null) {
      return "--";
    }
    try {
      final dep = _parseDateTime(segment.departureTime!);
      final arr = _parseDateTime(segment.arrivalTime!);
      if (dep == null || arr == null) return "--";
      final diff = arr.difference(dep);
      return "${diff.inHours} h ${diff.inMinutes.remainder(60)} m";
    } catch (e) {
      return "--";
    }
  }

  // Sana olish funksiyasi
  String _getDateFromTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      DateTime dateTime;

      // Turli formatlarni qo'llab-quvvatlash
      if (timeStr.contains('T')) {
        dateTime = DateTime.parse(timeStr);
      } else if (timeStr.contains(' ')) {
        // "2025-11-08 17:10:00" format
        dateTime = DateTime.parse(timeStr.replaceAll(' ', 'T'));
      } else {
        // Boshqa formatlar
        dateTime = DateTime.parse(timeStr);
      }

      final months = [
        'avia.months.short.jan'.tr(),
        'avia.months.short.feb'.tr(),
        'avia.months.short.mar'.tr(),
        'avia.months.short.apr'.tr(),
        'avia.months.short.may'.tr(),
        'avia.months.short.jun'.tr(),
        'avia.months.short.jul'.tr(),
        'avia.months.short.aug'.tr(),
        'avia.months.short.sep'.tr(),
        'avia.months.short.oct'.tr(),
        'avia.months.short.nov'.tr(),
        'avia.months.short.dec'.tr(),
      ];
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, $hour:$minute';
    } catch (e) {
      // Xatolik bo'lsa, bo'sh qaytarish o'rniga vaqtni qaytarishga harakat qilish
      AppLogger.warning('Error parsing date: $timeStr', e);
      return '';
    }
  }

  // Shahar nomini olish
  String _getCityName(String airportCode) {
    final cityMap = {
      'TAS': 'Ташкент',
      'DXB': 'Дубай',
      'IST': 'Стамбул',
      'DOH': 'Доха',
      'FRA': 'Франкфурт',
      'LHR': 'Лондон',
      'CDG': 'Париж',
      'SVO': 'Москва',
      'AUH': 'Абу-Даби',
    };
    return cityMap[airportCode] ?? airportCode;
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '--:--';
    try {
      final trimmed = timeStr.trim();

      // Full datetime formats: "2025-11-08T17:10:00" or "2025-11-08 17:10:00"
      final dt = _parseDateTime(trimmed);
      if (dt != null) {
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }

      // Time-only formats: "17:10:00" or "17:10"
      if (trimmed.contains(':')) {
        final parts = trimmed.split(':');
        if (parts.length >= 2) {
          final hour = parts[0].padLeft(2, '0');
          final minute = parts[1].padLeft(2, '0');
          return '$hour:$minute';
        }
      }

      return '--:--';
    } catch (e) {
      return '--:--';
    }
  }

  DateTime? _parseDateTime(String dateTime) {
    try {
      final trimmed = dateTime.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.contains('T')) {
        return DateTime.tryParse(trimmed);
      }
      if (trimmed.contains(' ')) {
        // "2025-11-08 17:10:00" -> "2025-11-08T17:10:00"
        return DateTime.tryParse(trimmed.replaceFirst(' ', 'T'));
      }
      return DateTime.tryParse(trimmed);
    } catch (e) {
      return null;
    }
  }

  bool _isDirect(List<SegmentModel>? segments) {
    return segments != null && segments.length <= 2;
  }

  String? _getStopsText(List<SegmentModel>? segments) {
    if (segments == null || segments.isEmpty) return null;
    if (segments.length <= 2) return null;
    final stopsCount = segments.length - 1;
    if (stopsCount == 1) return "1 transfer";
    return "$stopsCount transfer";
  }

  String _getFlightDuration(List<SegmentModel> segments) {
    if (segments.isEmpty) return '--:--';
    try {
      final first = segments.first;
      final last = segments.last;

      if (first.departureTime == null || last.arrivalTime == null) {
        return '--:--';
      }

      final departure = _parseDateTime(first.departureTime!);
      final arrival = _parseDateTime(last.arrivalTime!);

      if (departure == null || arrival == null) return '--:--';

      final duration = arrival.difference(departure);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else if (minutes > 0) {
        return '${minutes}m';
      }

      return '--:--';
    } catch (e) {
      return '--:--';
    }
  }

  String _getAirportCode(List<SegmentModel> segments, bool isDeparture) {
    if (segments.isEmpty) return isDeparture ? 'TAS' : 'DXB';
    if (isDeparture) {
      return segments.first.departureAirport ?? 'TAS';
    } else {
      return segments.last.arrivalAirport ?? 'DXB';
    }
  }

  String? _normalizeIataCode(String? raw) {
    final c = (raw ?? '').trim().toUpperCase();
    if (c.isEmpty) return null;

    final candidates = <String>{
      c,
      if (c.length >= 2) c.substring(0, 2),
      if (c.length > 2) c.substring(c.length - 2),
    };

    for (final cand in candidates) {
      if (cand.length == 2 && airlineLogoAssetCodes.contains(cand)) {
        return cand;
      }
    }
    return null;
  }

  String? _mapAirlineNameToIata(String? name) {
    final n = (name ?? '').trim().toUpperCase();
    if (n.isEmpty) return null;
    // Uzbekistan Airways (common variants)
    if (n.contains('UZBEK') ||
        n.contains('OZBEK') ||
        n.contains('O‘ZBEK') ||
        n.contains('OZBEKISTON') ||
        n.contains('UZBEKISTON') ||
        n.contains('УЗБЕК')) return 'HY';

    // flydubai (en/ru/uz variants)
    if (n.contains('FLYDUBAI') ||
        n.contains('FLY DUBAI') ||
        n.contains('ФЛАЙДУБАЙ') ||
        n.contains('ФЛАЙ ДУБАЙ')) return 'FZ';
    return null;
  }

  String? _resolveAirlineLogoCode(List<SegmentModel> segments) {
    // 1) Try flight number / airline code from segment
    final fromSegment = _normalizeIataCode(_extractIataFromSegments(segments));
    if (fromSegment != null) return fromSegment;

    // 2) Try mapping by airline name (common provider formats)
    if (segments.isNotEmpty) {
      final mapped = _mapAirlineNameToIata(segments.first.airline);
      final normalized = _normalizeIataCode(mapped);
      if (normalized != null) return normalized;
    }

    return null;
  }

  String? _airlineLogoPath(List<SegmentModel> segments) {
    final code = _resolveAirlineLogoCode(segments);
    return code == null ? null : 'assets/svgs/$code.svg';
  }

  // Airline logo (local asset) uchun: faqat segmentlardan IATA code olish.
  // API'dan rasm olmaydi, mapping ham qilmaydi.
  String? _extractIataFromSegments(List<SegmentModel> segments) {
    if (segments.isEmpty) return null;
    final first = segments.first;
    final fn = (first.flightNumber ?? '').trim();
    if (fn.isNotEmpty) {
      final m = RegExp(r'^([A-Za-z]{2,3})').firstMatch(fn);
      if (m != null) return m.group(1)!.toUpperCase();
    }
    final a = (first.airline ?? '').trim();
    if (a.length >= 2 && a.length <= 3) return a.toUpperCase();
    return null;
  }

  Widget _buildAirlineNameOrLogo({
    required String? logoPath,
    required String fallback,
    required TextStyle style,
  }) {
    if (logoPath != null) {
      final double fontSize = style.fontSize ?? 16;
      final double h = fontSize + 10;
      return SizedBox(
        height: h,
        child: SvgPicture.asset(
          logoPath,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
      );
    }
    return Text(
      fallback,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

    // Narxni formatlash funksiyasi (milyonlar uchun bo'shliq qo'shish) + 10% komissiya
  String _formatPrice(String price) {
    // Return formatted price with 10% markup
    final v = _FlightUtils.parsePriceValue(price);
    if (v == null) return _formatPriceHuman(price);
    // Add 10% commission
    final withCommission = v * 1.10;
    return _formatPriceHuman(withCommission.toString());
  }
}

class TapBubbleTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration autoDismiss;
  final double maxWidth;

  /// Dismiss currently visible tooltip (if any).
  static void dismissCurrent() {
    _TapBubbleTooltipState._dismissActive();
  }

  const TapBubbleTooltip({
    super.key,
    required this.child,
    required this.message,
    this.autoDismiss = const Duration(seconds: 3),
    this.maxWidth = 260,
  });

  @override
  State<TapBubbleTooltip> createState() => _TapBubbleTooltipState();
}

class _TapBubbleTooltipState extends State<TapBubbleTooltip> {
  static _TapBubbleTooltipState? _active;
  static void _dismissActive() {
    _active?._hide();
    _active = null;
  }

  final GlobalKey _targetKey = GlobalKey();
  OverlayEntry? _entry;
  Timer? _timer;
  bool _globalRouteAttached = false;
  Offset? _downPosition;

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  Rect? _targetRect() {
    final targetContext = _targetKey.currentContext;
    if (targetContext == null) return null;
    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  void _attachGlobalDismissRoute() {
    if (_globalRouteAttached) return;
    // Listen globally so we can dismiss without blocking scroll/taps underneath.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onGlobalPointerEvent);
    _globalRouteAttached = true;
  }

  void _detachGlobalDismissRoute() {
    if (!_globalRouteAttached) return;
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_onGlobalPointerEvent);
    _globalRouteAttached = false;
  }

  void _onGlobalPointerEvent(PointerEvent event) {
    if (_entry == null) return;

    // Mouse wheel / trackpad scroll should dismiss immediately.
    if (event is PointerScrollEvent) {
      _hide();
      return;
    }

    // On first touch outside the target, dismiss immediately.
    if (event is PointerDownEvent) {
      _downPosition = event.position;
      final rect = _targetRect();
      if (rect != null && rect.contains(event.position)) {
        // Allow second tap on the icon to toggle (hide via _toggle()).
        return;
      }
      _hide();
      return;
    }

    // If user starts dragging (scrolling) even from the target area, dismiss.
    if (event is PointerMoveEvent) {
      final start = _downPosition;
      if (start != null && (event.position - start).distance > 10) {
        _hide();
      }
    }
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _detachGlobalDismissRoute();
    if (identical(_active, this)) _active = null;
  }

  void _toggle() {
    if (_entry != null) {
      _hide();
      return;
    }
    _show();
  }

  void _show() {
    // Ensure only one tooltip is shown at a time.
    if (!identical(_active, this)) {
      _dismissActive();
      _active = this;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final targetContext = _targetKey.currentContext;
    if (overlay == null || targetContext == null) return;

    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final targetOffset = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;
    final topSafe = media.padding.top + 8;
    const margin = 8.0;

    const bubblePaddingH = 14.0;
    const bubblePaddingV = 10.0;
    const arrowH = 8.0;
    const arrowW = 14.0;

    final bg = AppColors.primaryBlue;
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );

    final bubbleMaxW = (widget.maxWidth).clamp(120.0, screenW - margin * 2);
    final painter = TextPainter(
      text: TextSpan(text: widget.message, style: textStyle),
      textDirection: Directionality.of(context),
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: bubbleMaxW - bubblePaddingH * 2);

    final bubbleW =
        (painter.width + bubblePaddingH * 2).clamp(120.0, bubbleMaxW);
    final bubbleH = painter.height + bubblePaddingV * 2;

    final targetCenterX = targetOffset.dx + targetSize.width / 2;
    var left = targetCenterX - bubbleW / 2;
    left = left.clamp(margin, screenW - bubbleW - margin);

    final aboveTop = targetOffset.dy - bubbleH - arrowH - 10;
    final showAbove = aboveTop >= topSafe;

    final top = showAbove
        ? (targetOffset.dy - bubbleH - arrowH - 10)
        : (targetOffset.dy + targetSize.height + 10);

    final arrowLeftRaw = targetCenterX - left - arrowW / 2;
    final arrowLeft = arrowLeftRaw.clamp(12.0, bubbleW - arrowW - 12.0);

    _entry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top.clamp(margin, screenH - bubbleH - arrowH - margin),
              child: Material(
                color: Colors.transparent,
                child: IgnorePointer(
                  // Tooltip is informational only; let touches/scroll pass through.
                  ignoring: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: showAbove
                        ? [
                            _BubbleBody(
                              width: bubbleW,
                              paddingH: bubblePaddingH,
                              paddingV: bubblePaddingV,
                              background: bg,
                              text: widget.message,
                              textStyle: textStyle,
                            ),
                            _BubbleArrow(
                              left: arrowLeft,
                              width: bubbleW,
                              arrowW: arrowW,
                              arrowH: arrowH,
                              background: bg,
                              directionDown: true,
                            ),
                          ]
                        : [
                            _BubbleArrow(
                              left: arrowLeft,
                              width: bubbleW,
                              arrowW: arrowW,
                              arrowH: arrowH,
                              background: bg,
                              directionDown: false,
                            ),
                            _BubbleBody(
                              width: bubbleW,
                              paddingH: bubblePaddingH,
                              paddingV: bubblePaddingV,
                              background: bg,
                              text: widget.message,
                              textStyle: textStyle,
                            ),
                          ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    _attachGlobalDismissRoute();
    _timer = Timer(widget.autoDismiss, _hide);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: KeyedSubtree(
        key: _targetKey,
        child: widget.child,
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final double width;
  final double paddingH;
  final double paddingV;
  final Color background;
  final String text;
  final TextStyle textStyle;

  const _BubbleBody({
    required this.width,
    required this.paddingH,
    required this.paddingV,
    required this.background,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}

class _BubbleArrow extends StatelessWidget {
  final double left;
  final double width;
  final double arrowW;
  final double arrowH;
  final Color background;
  final bool directionDown;

  const _BubbleArrow({
    required this.left,
    required this.width,
    required this.arrowW,
    required this.arrowH,
    required this.background,
    required this.directionDown,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: arrowH,
      child: CustomPaint(
        painter: _TrianglePainter(
          color: background,
          left: left,
          width: arrowW,
          height: arrowH,
          directionDown: directionDown,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final double left;
  final double width;
  final double height;
  final bool directionDown;

  _TrianglePainter({
    required this.color,
    required this.left,
    required this.width,
    required this.height,
    required this.directionDown,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (directionDown) {
      // Pointing down (bubble above target)
      path.moveTo(left, 0);
      path.lineTo(left + width / 2, height);
      path.lineTo(left + width, 0);
    } else {
      // Pointing up (bubble below target)
      path.moveTo(left, height);
      path.lineTo(left + width / 2, 0);
      path.lineTo(left + width, height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.left != left ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.directionDown != directionDown;
  }
}
