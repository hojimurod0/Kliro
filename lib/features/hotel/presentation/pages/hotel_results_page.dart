import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_filter.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/hotel_filter_dialog.dart';
import 'hotel_details_page.dart';
import '../../../../core/widgets/safe_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

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
    final updatedFilter = await showDialog<HotelFilter>(
      context: context,
      builder: (context) => HotelFilterDialog(initialFilter: currentFilter),
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
          debugPrint(
              '🔍 HotelResultsPage: Updated from state, hotels count = ${currentResult.hotels.length}');
        }

        // Debug log qo'shamiz
        debugPrint(
            '🔍 HotelResultsPage build: hotels count = ${currentResult.hotels.length}');
        debugPrint(
            '🔍 HotelResultsPage: isEmpty = ${currentResult.hotels.isEmpty}');
        debugPrint(
            '🔍 HotelResultsPage: total = ${currentResult.total}, page = ${currentResult.page}');
        if (currentResult.hotels.isNotEmpty) {
          debugPrint(
              '🔍 First hotel: ${currentResult.hotels.first.name} (id: ${currentResult.hotels.first.hotelId})');
        } else {
          debugPrint('⚠️ HotelResultsPage: NO HOTELS - showing empty state');
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
              title: Text(
                'hotel.results.title'.tr(),
                style: AppTypography.headingL.copyWith(fontSize: 18.sp),
              ),
              centerTitle: true,
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
                  color: AppColors.getBorderColor(Theme.of(context).brightness == Brightness.dark).withOpacity(0.5),
                ),
              ),
            ),
            body: Column(
              children: [
                // Filter Summary Bar (Optional, simpler version)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.city ?? 'hotel.common.anywhere'.tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14.sp),
                            ),
                            Text(
                              '${widget.guests ?? 1} ${"hotel.search.person".tr()} • ${widget.checkInDate != null ? DateFormat('dd MMM').format(widget.checkInDate!) : ''} - ${widget.checkOutDate != null ? DateFormat('dd MMM').format(widget.checkOutDate!) : ''}',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showFilterDialog(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.filter_list, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
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

    // Check for breakfast and meal options
    bool hasBreakfast = false;
    List<String> mealOptions = [];

    // Check amenities for breakfast
    if (hotel.amenities != null) {
      hasBreakfast = hotel.amenities!.any((a) =>
          a.toLowerCase().contains('breakfast') ||
          a.toLowerCase().contains('nonushta') ||
          a.toLowerCase().contains('завтрак'));
    }

    // Check options for meal information
    if (hotel.options != null && hotel.options!.isNotEmpty) {
      final firstOption = hotel.options!.first;
      if (firstOption.includedMealOptions != null &&
          firstOption.includedMealOptions!.isNotEmpty) {
        mealOptions = firstOption.includedMealOptions!;
        if (!hasBreakfast) {
          hasBreakfast = mealOptions.any((m) =>
              m.toLowerCase().contains('breakfast') ||
              m.toLowerCase().contains('nonushta') ||
              m.toLowerCase().contains('завтрак'));
        }
      }
    }

    // Get top amenities for display
    final topAmenities = _getTopAmenities(hotel.amenities);

    // Calculate discount info
    final hasDiscount = hotel.discount != null && hotel.discount! > 0;
    final originalPrice =
        _shouldShowOriginalPrice(hotel) ? _formatOriginalPrice(hotel) : null;

    // Get cancellation policy info
    String? cancellationInfo;
    if (hotel.options != null && hotel.options!.isNotEmpty) {
      final firstOption = hotel.options!.first;
      if (firstOption.cancellationPolicy != null) {
        final policy = firstOption.cancellationPolicy!;
        // Try to extract cancellation info
        if (policy['type'] != null) {
          cancellationInfo = policy['type'].toString();
        } else if (policy['description'] != null) {
          final desc = policy['description'].toString();
          cancellationInfo =
              desc.length > 50 ? desc.substring(0, 50) + '...' : desc;
        }
      }
    }

    // Get description (short version) - locale-aware
    String? shortDescription =
        _getLocalizedDescription(hotel.description, context);
    if (shortDescription != null) {
      // Удаляем HTML теги из описания
      shortDescription = _stripHtmlTags(shortDescription);
      if (shortDescription.length > 100) {
        shortDescription = shortDescription.substring(0, 100) + '...';
      }
    }

    // Получаем локализованное название отеля
    String hotelName = _getLocalizedName(hotel.name, context);

    return GestureDetector(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.2),
                             blurRadius: 4,
                             offset: const Offset(0, 2),
                           )
                        ]
                      ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            hotel.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
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
                  // Title and Stars Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hotelName,
                          style: AppTypography.headingL.copyWith(
                            color: AppColors.getTextColor(isDark),
                            height: 1.2,
                            fontSize: 18.sp
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Stars
                      if (hotel.stars != null && hotel.stars! > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            if (index < hotel.stars!) {
                              return Icon(Icons.star,
                                  color: Colors.amber, size: 18.sp);
                            } else {
                              return Icon(Icons.star_border,
                                  color: Colors.grey[300], size: 18.sp);
                            }
                          }),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // City and Address with location icon
                  if (hotel.city.isNotEmpty || hotel.address.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hotel.city.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_city_rounded,
                                  size: 16.sp, color: AppColors.primaryBlue),
                              SizedBox(width: 6.w),
                              Text(
                                hotel.city,
                                style: AppTypography.bodySecondary.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (hotel.city.isNotEmpty && hotel.address.isNotEmpty)
                          SizedBox(height: 4.h),
                        if (hotel.address.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16.sp, color: AppColors.getSubtitleColor(isDark)),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  hotel.address,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.getSubtitleColor(isDark),
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.dotted,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                  // Description
                  if (shortDescription != null &&
                      shortDescription.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkScaffoldBg : AppColors.grayBackground,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.getBorderColor(isDark).withOpacity(0.5)),
                      ),
                      child: Text(
                        shortDescription,
                        style: AppTypography.bodySecondary.copyWith(
                          color: AppColors.getSubtitleColor(isDark),
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // Amenities row
                  if (topAmenities.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: topAmenities.map((amenity) {
                        return _buildAmenityChip(context, amenity);
                      }).toList(),
                    ),

                  // Meal options badges
                  if (hasBreakfast || mealOptions.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (hasBreakfast)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.greenBg,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.greenIcon.withOpacity(0.5), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.breakfast_dining_rounded,
                                    size: 16.sp, color: AppColors.greenIcon),
                                SizedBox(width: 6.w),
                                Text(
                                  'hotel.results.breakfast'.tr(),
                                  style: TextStyle(
                                    color: AppColors.greenIcon,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Other meal options
                        ...mealOptions
                            .where((m) =>
                                !m.toLowerCase().contains('breakfast') &&
                                !m.toLowerCase().contains('nonushta'))
                            .take(2)
                            .map((meal) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.orangeWarning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                        color: AppColors.orangeWarning.withOpacity(0.5), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.restaurant_rounded,
                                          size: 16.sp, color: AppColors.orangeWarning),
                                      SizedBox(width: 6.w),
                                      Flexible(
                                        child: Text(
                                          meal.length > 20
                                              ? meal.substring(0, 20) + '...'
                                              : meal,
                                          style: TextStyle(
                                            color: AppColors.orangeWarning,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ],

                  // Cancellation policy info
                  if (cancellationInfo != null &&
                      cancellationInfo.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 14.sp, color: AppColors.greenIcon),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              cancellationInfo,
                              style: TextStyle(
                                color: AppColors.greenIcon,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // Guest and room info
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 16.sp, color: AppColors.gray500),
                      SizedBox(width: 4.w),
                      Text(
                        '${widget.guests ?? 1} ${'hotel.search.person'.tr()}',
                        style: AppTypography.caption,
                      ),
                      if (hotel.options != null &&
                          hotel.options!.isNotEmpty) ...[
                        SizedBox(width: 12.w),
                        Icon(Icons.bed_rounded, size: 16.sp, color: AppColors.gray500),
                        SizedBox(width: 4.w),
                        Text(
                          "${hotel.options!.length} ${'hotel.search.room'.tr()}",
                          style: AppTypography.caption,
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 16.h),
                  Divider(height: 1, color: Colors.grey[300]),
                  SizedBox(height: 16.h),

                  // Price Section with discount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(widget.checkOutDate != null && widget.checkInDate != null) ? widget.checkOutDate!.difference(widget.checkInDate!).inDays : 1} ${'hotel.results.nights'.tr()} ${'hotel.results.for_price'.tr()}',
                              style: AppTypography.caption,
                            ),
                            SizedBox(height: 4.h),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (originalPrice != null) ...[
                                  Text(
                                    originalPrice,
                                    style: TextStyle(
                                      color: AppColors.gray500,
                                      fontSize: 14.sp,
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  _formatPrice(hotel),
                                  style: TextStyle(
                                      color: hasDiscount
                                          ? AppColors.dangerRed
                                          : AppColors.primaryBlue,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Detail button
                      ElevatedButton(
                        onPressed: () {
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        ),
                        child: Text(
                          'hotel.results.details'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

    return SafeNetworkImage(
      imageUrl: finalImageUrl,
      height: 200.h,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  List<String> _getTopAmenities(List<String>? amenities) {
    if (amenities == null || amenities.isEmpty) return [];

    // Priority amenities to show
    final priorityAmenities = [
      'wifi',
      'wi-fi',
      'internet',
      'pool',
      'basseyn',
      'bassein',
      'parking',
      'turargoh',
      'gym',
      'fitness',
      'sport',
      'restaurant',
      'restoran',
      'spa',
      'bar',
      'ac',
      'air',
      'conditioning',
    ];

    // Get top 3 amenities that match priority
    final matched = amenities
        .where((a) {
          final lower = a.toLowerCase();
          return priorityAmenities.any((p) => lower.contains(p));
        })
        .take(3)
        .toList();

    return matched.isNotEmpty ? matched : amenities.take(3).toList();
  }

  Widget _buildAmenityChip(BuildContext context, String amenity) {
    IconData icon = Icons.check_circle_outline_rounded;
    final lower = amenity.toLowerCase();

    if (lower.contains('wifi') ||
        lower.contains('wi-fi') ||
        lower.contains('internet')) {
      icon = Icons.wifi;
    } else if (lower.contains('pool') ||
        lower.contains('basseyn') ||
        lower.contains('bassein')) {
      icon = Icons.pool_rounded;
    } else if (lower.contains('parking') || lower.contains('turargoh')) {
      icon = Icons.local_parking_rounded;
    } else if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('sport')) {
      icon = Icons.fitness_center_rounded;
    } else if (lower.contains('restaurant') || lower.contains('restoran')) {
      icon = Icons.restaurant_rounded;
    } else if (lower.contains('spa')) {
      icon = Icons.spa_rounded;
    } else if (lower.contains('bar')) {
      icon = Icons.local_bar_rounded;
    } else if (lower.contains('ac') ||
        lower.contains('air') ||
        lower.contains('conditioning')) {
      icon = Icons.ac_unit_rounded;
    } else if (lower.contains('tv') || lower.contains('televizor')) {
      icon = Icons.tv_rounded;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue, // Consistent chip color
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.primaryBlue),
          SizedBox(width: 4.w),
          Text(
            amenity,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  /// Get localized description from hotel description
  /// Handles both String and Map formats, selects based on current locale
  String? _getLocalizedDescription(String? description, BuildContext context) {
    if (description == null || description.isEmpty) return null;

    // If description is a JSON string, try to parse it
    try {
      // Check if it's a JSON string
      if (description.trim().startsWith('{') ||
          description.trim().startsWith('[')) {
        final parsed = json.decode(description);
        if (parsed is Map) {
          final locale = context.locale.toString();
          final localeLower = locale.toLowerCase();

          // Get locale variants
          final variants = <String>[];
          variants.add(locale);
          variants.add(localeLower);

          // Handle Cyrillic Uzbek
          if (localeLower == 'uz_cyr' || localeLower == 'uz-cyr') {
            variants.addAll(['uz_CYR', 'uz-CYR', 'uz_cyr', 'uz-cyr']);
          }

          // Add base language code
          if (locale.contains('-') || locale.contains('_')) {
            final base = locale.split(RegExp(r'[-_]')).first.toLowerCase();
            if (base.isNotEmpty) variants.add(base);
          }

          // Try to find description in preferred locale
          for (final variant in variants) {
            if (parsed[variant] != null) {
              final desc = parsed[variant].toString();
              if (desc.isNotEmpty) return desc;
            }
          }

          // Fallback to common keys
          final desc = parsed['uz']?.toString() ??
              parsed['ru']?.toString() ??
              parsed['en']?.toString() ??
              parsed['value']?.toString() ??
              parsed['text']?.toString() ??
              (parsed.isNotEmpty ? parsed.values.first.toString() : null);

          // Удаляем HTML теги из описания
          if (desc != null) {
            return _stripHtmlTags(desc);
          }
        }
      }
    } catch (e) {
      // If parsing fails, return as is (it's probably a plain string)
      debugPrint('⚠️ HotelResultsPage: Error parsing description JSON: $e');
    }

    // Return as plain string (удаляем HTML теги если есть)
    return _stripHtmlTags(description);
  }

  /// Получает локализованное название отеля
  String _getLocalizedName(String name, BuildContext context) {
    if (name.isEmpty) return name;

    // Если название уже является строкой, возвращаем как есть
    // (парсинг многоязычных названий уже выполнен в HotelModel)
    return name;
  }

  /// Удаляет HTML теги из текста
  String _stripHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';

    // Простое удаление HTML тегов
    String text = htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '') // Удаляем все HTML теги
        .replaceAll('&nbsp;', ' ') // Заменяем &nbsp; на пробел
        .replaceAll('&amp;', '&') // Заменяем &amp; на &
        .replaceAll('&lt;', '<') // Заменяем &lt; на <
        .replaceAll('&gt;', '>') // Заменяем &gt; на >
        .replaceAll('&quot;', '"') // Заменяем &quot; на "
        .replaceAll('&#39;', "'") // Заменяем &#39; на '
        .replaceAll(
            RegExp(r'\s+'), ' ') // Заменяем множественные пробелы на один
        .trim();

    return text;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 24.h),
          Text(
            'hotel.results.empty_title'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'hotel.results.empty_subtitle'.tr(),
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Форматирует цену отеля с учетом валюты
  String _formatPrice(Hotel hotel) {
    try {
      double? price;
      String currency = 'so\'m';

      // Сначала пытаемся получить цену из первого варианта
      if (hotel.options != null && hotel.options!.isNotEmpty) {
        final firstOption = hotel.options!.first;
        price = firstOption.price;
        if (firstOption.currency != null) {
          currency = firstOption.currency == 'uzs'
              ? 'so\'m'
              : firstOption.currency!.toUpperCase();
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
      debugPrint('❌ Error formatting price: $e');
      return '0 so\'m';
    }
  }

  /// Проверяет, нужно ли показывать оригинальную цену (со скидкой)
  bool _shouldShowOriginalPrice(Hotel hotel) {
    if (hotel.discount == null || hotel.discount! <= 0) {
      return false;
    }

    // Проверяем, есть ли цена для расчета оригинальной
    double? currentPrice;
    if (hotel.options != null && hotel.options!.isNotEmpty) {
      currentPrice = hotel.options!.first.price;
    }
    if (currentPrice == null || currentPrice <= 0) {
      currentPrice = hotel.price;
    }

    return currentPrice != null && currentPrice > 0;
  }

  /// Форматирует оригинальную цену (до скидки)
  String _formatOriginalPrice(Hotel hotel) {
    try {
      double? currentPrice;
      String currency = 'so\'m';

      // Получаем текущую цену и валюту
      if (hotel.options != null && hotel.options!.isNotEmpty) {
        final firstOption = hotel.options!.first;
        currentPrice = firstOption.price;
        if (firstOption.currency != null) {
          currency = firstOption.currency == 'uzs'
              ? 'so\'m'
              : firstOption.currency!.toUpperCase();
        }
      }

      if (currentPrice == null || currentPrice <= 0) {
        currentPrice = hotel.price;
      }

      if (currentPrice == null || currentPrice <= 0 || hotel.discount == null) {
        return '';
      }

      // Рассчитываем оригинальную цену: currentPrice = originalPrice * (1 - discount/100)
      // originalPrice = currentPrice / (1 - discount/100)
      final discountPercent = hotel.discount! / 100.0;
      if (discountPercent >= 1.0) {
        return ''; // Избегаем деления на ноль или отрицательных значений
      }

      final originalPrice = currentPrice / (1 - discountPercent);

      return NumberFormat.currency(
        locale: 'uz_UZ',
        symbol: currency,
        decimalDigits: 0,
      ).format(originalPrice.round());
    } catch (e) {
      debugPrint('❌ Error formatting original price: $e');
      return '';
    }
  }
}
