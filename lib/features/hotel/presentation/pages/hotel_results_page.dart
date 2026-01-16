import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_filter.dart';
import '../bloc/hotel_bloc.dart';
import 'hotel_filter_page.dart';
import '../../../../core/widgets/safe_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import 'hotel_details_page.dart';

class HotelResultsPage extends StatefulWidget {
  final HotelSearchResult result;
  final String? city;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? guests;
  final HotelFilter? filter;

  const HotelResultsPage({
    Key? key,
    required this.result,
    this.city,
    this.checkInDate,
    this.checkOutDate,
    this.guests,
    this.filter,
  }) : super(key: key);

  @override
  State<HotelResultsPage> createState() => _HotelResultsPageState();
}

class _HotelResultsPageState extends State<HotelResultsPage> {
  // Track which hotels we've already requested photos for to avoid duplicate requests
  final Set<int> _requestedPhotoIds = {};

  void _showFilterDialog(BuildContext context) async {
    final currentFilter = widget.filter ?? HotelFilter.empty;
    final hotelBloc = context.read<HotelBloc>();
    
    // Get current hotels list from state
    HotelSearchResult currentResult = widget.result;
    final state = hotelBloc.state;
    if (state is HotelSearchSuccess) {
      currentResult = state.result;
    }
    
    final updatedFilter = await Navigator.of(context).push<HotelFilter>(
      MaterialPageRoute(
        builder: (pageContext) => BlocProvider<HotelBloc>.value(
          value: hotelBloc,
          child: HotelFilterPage(
            initialFilter: currentFilter,
            hotels: currentResult.hotels,
          ),
        ),
      ),
    );

    if (updatedFilter != null && context.mounted) {
      context.read<HotelBloc>().add(SearchHotelsRequested(updatedFilter));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        // Get the latest result from state if available, otherwise use widget.result
        HotelSearchResult currentResult = widget.result;
        if (state is HotelSearchSuccess) {
          currentResult = state.result;
        }

        return BlocListener<HotelBloc, HotelState>(
          listener: (context, state) {
            // Update photos when they are loaded
            if (state is HotelPhotosSuccess) {
              // Photos are loaded but we need to update the hotel in the result
              // This will be handled by the bloc updating the search result
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.getCardBg(
                          Theme.of(context).brightness == Brightness.dark)
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 20.sp),
                  onPressed: () {
                    // HotelSearchPage'ga qaytish - faqat bitta sahifani yopish
                    Navigator.of(context).pop();
                  },
                  tooltip: 'hotel.common.back'.tr(),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'hotel.results.find_comfortable_hotel'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSubtitleColor(
                          Theme.of(context).brightness == Brightness.dark),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${'hotel.results.recommended_hotels'.tr()}: ${currentResult.hotels.length}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () => _showFilterDialog(context),
                  child: Container(
                    margin: EdgeInsets.only(right: 16.w),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.getBorderColor(
                              Theme.of(context).brightness == Brightness.dark)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.filter_list, size: 20.sp),
                  ),
                ),
              ],
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16.r),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1.h),
                child: Container(
                  height: 1.h,
                  color: AppColors.getBorderColor(
                          Theme.of(context).brightness == Brightness.dark)
                      .withOpacity(0.5),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: currentResult.hotels.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          key: ValueKey(
                              'refresh_${currentResult.hotels.length}'), // Force rebuild on change
                          onRefresh: () async {
                            if (widget.filter != null) {
                              context
                                  .read<HotelBloc>()
                                  .add(SearchHotelsRequested(widget.filter!));
                            }
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                          },
                          child: ListView.separated(
                            padding: EdgeInsets.all(16.w),
                            itemCount: currentResult.hotels.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final hotel = currentResult.hotels[index];
                              return _buildHotelCard(context, hotel);
                            },
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

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Lazy fetch photos if missing
    final bool hasPhotos = hotel.photos?.isNotEmpty == true;
    final bool hasImage = hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty;

    if (!hasPhotos &&
        !hasImage &&
        !_requestedPhotoIds.contains(hotel.hotelId)) {
      _requestedPhotoIds.add(hotel.hotelId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<HotelBloc>().add(GetHotelPhotosRequested(hotel.hotelId));
        }
      });
    }

    // Calculate discount info
    final hasDiscount = hotel.discount != null && hotel.discount! > 0;

    // Получаем локализованное название отеля
    String hotelName = hotel.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final hotelBloc = context.read<HotelBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider<HotelBloc>.value(
                value: hotelBloc,
                child: HotelDetailsPage(hotel: hotel),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBg(isDark),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.getSubtitleColor(isDark).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.getBorderColor(isDark).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with discount badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: _buildHotelImage(hotel),
                  ),
                  // Discount badge
                  if (hasDiscount)
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                            color: AppColors.dangerRed,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]),
                        child: Text(
                          '-${hotel.discount}%',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Rating badge
                  if (hotel.rating != null && hotel.rating! > 0)
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: AppColors.white.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text(
                              hotel.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Name
                    Text(
                      hotelName,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDark),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // Stars - always visible (like website)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final starValue = hotel.stars ?? 0;
                        final isFilled = index < starValue;
                        return Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: isFilled
                              ? Colors.amber
                              : AppColors.getBorderColor(isDark)
                                  .withOpacity(0.4),
                          size: 18.sp,
                        );
                      }),
                    ),

                    SizedBox(height: 8.h),

                    // Address (joylashuv) - always visible (like website)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            hotel.address.isNotEmpty
                                ? hotel.address
                                : 'hotel.results.address_not_available'.tr(),
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 14.sp,
                              decoration: hotel.address.isNotEmpty
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Guest and room info
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 16.sp,
                            color: AppColors.getSubtitleColor(isDark)),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.guests ?? 1} ${'hotel.search.person'.tr()}',
                          style: TextStyle(
                            color: AppColors.getSubtitleColor(isDark),
                            fontSize: 14.sp,
                          ),
                        ),
                        if (hotel.options != null &&
                            hotel.options!.isNotEmpty) ...[
                          SizedBox(width: 12.w),
                          Icon(Icons.bed_rounded,
                              size: 16.sp,
                              color: AppColors.getSubtitleColor(isDark)),
                          SizedBox(width: 4.w),
                          Text(
                            "${hotel.options!.length} ${'hotel.search.room'.tr()}",
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(isDark),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 16.h),
                    Divider(
                        height: 1,
                        color:
                            AppColors.getBorderColor(isDark).withOpacity(0.6)),
                    SizedBox(height: 16.h),

                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.results.price_for_night'.tr(),
                          style: TextStyle(
                            color: AppColors.getSubtitleColor(isDark),
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatPrice(hotel),
                          style: TextStyle(
                            color: AppColors.getTextColor(isDark),
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Detail button - full width
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final hotelBloc = context.read<HotelBloc>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlocProvider<HotelBloc>.value(
                                value: hotelBloc,
                                child: HotelDetailsPage(hotel: hotel),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 16.h),
                        ),
                        child: Text(
                          'hotel.results.details'.tr(),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelImage(Hotel hotel) {
    // Try to get image from photos first, then imageUrl
    String? imageUrl;

    if (hotel.photos != null && hotel.photos!.isNotEmpty) {
      // Try to find default photo first
      final defaultPhoto = hotel.photos!.firstWhere(
        (p) => p.isDefault && p.url.isNotEmpty,
        orElse: () => hotel.photos!.firstWhere(
          (p) => p.url.isNotEmpty,
          orElse: () => hotel.photos!.first,
        ),
      );
      imageUrl = defaultPhoto.url;
    }

    // Fallback to imageUrl
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = hotel.imageUrl;
    }

    // Final fallback
    final finalImageUrl = imageUrl?.isNotEmpty == true
        ? imageUrl!
        : 'https://placehold.co/400x250?text=Mehmonxona+rasmi';

    return Container(
      width: double.infinity,
      height: 280.h,
      child: SafeNetworkImage(
        imageUrl: finalImageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardBg.withOpacity(0.5)
                    : AppColors.lightCardBg.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64.sp,
                color: AppColors.getBorderColor(isDark).withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'hotel.results.empty_title'.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'hotel.results.empty_subtitle'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.getSubtitleColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back, size: 18.sp),
              label: Text('hotel.common.back'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Форматирует цену отеля с учетом валюты
  String _formatPrice(Hotel hotel) {
    try {
      double? price;
      String currency = 'so\'m';

      // Eng arzon xonaning narxini topish
      if (hotel.options != null && hotel.options!.isNotEmpty) {
        // Xonalarni narx bo'yicha saralash (eng arzon birinchi)
        final sortedOptions = List.from(hotel.options!);
        sortedOptions.sort((a, b) {
          final priceA = a.price ?? double.infinity;
          final priceB = b.price ?? double.infinity;
          return priceA.compareTo(priceB);
        });
        
        // Eng arzon xonani olish
        final cheapestOption = sortedOptions.first;
        price = cheapestOption.price;
        if (cheapestOption.currency != null) {
          currency = cheapestOption.currency == 'uzs'
              ? 'so\'m'
              : cheapestOption.currency!.toUpperCase();
        }
      }

      // Если цены нет в вариантах, используем цену отеля
      if (price == null || price <= 0) {
        price = hotel.price;
      }

      // Если цена все еще null или 0, показываем 0
      if (price == null || price <= 0) {
        price = 0;
      }

      return NumberFormat.currency(
        locale: 'uz_UZ',
        symbol: currency,
        decimalDigits: 0,
      ).format(price);
    } catch (e) {
      return '0 so\'m';
    }
  }

}
