import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_search_result.dart';
import '../../domain/entities/hotel_filter.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/hotel_filter_dialog.dart';
import 'hotel_details_page.dart';

class HotelResultsPage extends StatelessWidget {
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

  void _showFilterDialog(BuildContext context) async {
    final currentFilter = filter ?? HotelFilter.empty;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hotel.results.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Summary Bar (Optional, simpler version)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city ?? 'hotel.common.anywhere'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      Text(
                        '${guests ?? 1} ${"hotel.search.person".tr()} • ${checkInDate != null ? DateFormat('dd MMM').format(checkInDate!) : ''} - ${checkOutDate != null ? DateFormat('dd MMM').format(checkOutDate!) : ''}',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
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
            child: result.hotels.isEmpty
                ? _buildEmptyState(context)
                : RefreshIndicator(
                    onRefresh: () async {
                      if (filter != null) {
                        context.read<HotelBloc>().add(SearchHotelsRequested(filter!));
                      }
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: result.hotels.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final hotel = result.hotels[index];
                        return _buildHotelCard(context, hotel);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HotelDetailsPage(hotel: hotel),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: Image.network(
                    hotel.imageUrl ?? 'https://via.placeholder.com/300x200',
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${hotel.stars ?? hotel.rating?.toInt() ?? 4}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold),
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
                  Text(
                    hotel.name,
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          hotel.city, // Address or city
                          style: TextStyle(
                              color: Colors.grey, fontSize: 13.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Amenities row (icons)
                  if (hotel.amenities != null && hotel.amenities!.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: hotel.amenities!.take(3).map((amenity) {
                        IconData icon = Icons.check_circle;
                        if (amenity.toLowerCase().contains('wifi') ||
                            amenity.toLowerCase().contains('wi-fi')) {
                          icon = Icons.wifi;
                        } else if (amenity.toLowerCase().contains('pool')) {
                          icon = Icons.pool;
                        } else if (amenity.toLowerCase().contains('gym') ||
                            amenity.toLowerCase().contains('fitness')) {
                          icon = Icons.fitness_center;
                        }
                        return _buildAmenityBadge(icon, amenity);
                      }).toList(),
                    )
                  else
                    Row(
                      children: [
                        _buildAmenityBadge(Icons.wifi, "Wi-Fi"),
                        SizedBox(width: 8.w),
                        _buildAmenityBadge(Icons.pool, "Pool"),
                        SizedBox(width: 8.w),
                        _buildAmenityBadge(Icons.fitness_center, "Gym"),
                      ],
                    ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'hotel.from'.tr(),
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12.sp),
                          ),
                          Text(
                            // Show price from first option or hotel price
                            '${NumberFormat.currency(locale: 'uz_UZ', symbol: hotel.options?.isNotEmpty == true ? (hotel.options!.first.currency == 'uzs' ? 'so\'m' : hotel.options!.first.currency?.toUpperCase() ?? 'so\'m') : 'so\'m', decimalDigits: 0).format(hotel.options?.isNotEmpty == true ? (hotel.options!.first.price ?? hotel.price ?? 0) : (hotel.price ?? 0))}',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          if (hotel.options != null && hotel.options!.length > 1)
                            Text(
                              '${hotel.options!.length} ${"hotel.results.options_available".tr()}',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 11.sp),
                            ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'hotel.common.select'.tr(),
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
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
              color: Colors.grey[700],
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

  Widget _buildAmenityBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, size: 16.sp, color: Colors.grey[700]),
    );
  }
}
