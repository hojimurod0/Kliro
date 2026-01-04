import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/reference_data.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/hotel_photos_gallery.dart';
import 'hotel_booking_page.dart';

class HotelDetailsPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsPage({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage>
    with SingleTickerProviderStateMixin {
  HotelOption? _selectedOption;
  bool _isDescriptionExpanded = false; // Состояние для раскрытия описания
  late TabController _tabController; // Контроллер для табов

  // State cache - oldingi state'larni saqlash
  List<HotelPhoto> _cachedPhotos = [];
  List<Facility> _cachedFacilities = [];
  List<ServiceInRoom> _cachedServices = [];
  List<RoomType> _cachedRoomTypes = [];

  bool _isLoadingPhotos = false;
  bool _isLoadingFacilities = false;
  bool _isLoadingServices = false;
  bool _isLoadingRoomTypes = false;

  @override
  void initState() {
    super.initState();
    // Инициализируем TabController для 4 табов
    _tabController = TabController(length: 4, vsync: this);

    // Select first option by default
    if (widget.hotel.options != null && widget.hotel.options!.isNotEmpty) {
      _selectedOption = widget.hotel.options!.first;
    }
    // Initialize cached photos from hotel object if available
    if (widget.hotel.photos != null) {
      _cachedPhotos = widget.hotel.photos!;
    }
    // Load all hotel data via Bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelId = widget.hotel.hotelId;
      context.read<HotelBloc>().add(GetHotelPhotosRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelFacilitiesRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelRoomTypesRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelServicesInRoomRequested(hotelId));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    return BlocListener<HotelBloc, HotelState>(
      listener: (context, state) {
        // Optimized: Batch state updates to prevent multiple rebuilds and hanging
        bool needsUpdate = false;

        if (state is HotelPhotosSuccess) {
          if (_cachedPhotos != state.photos || _isLoadingPhotos) {
            _cachedPhotos = state.photos;
            _isLoadingPhotos = false;
            needsUpdate = true;
          }
        } else if (state is HotelPhotosLoading) {
          if (!_isLoadingPhotos) {
            _isLoadingPhotos = true;
            needsUpdate = true;
          }
        } else if (state is HotelPhotosFailure) {
          if (_isLoadingPhotos) {
            _isLoadingPhotos = false;
            needsUpdate = true;
          }
        }

        if (state is HotelHotelFacilitiesSuccess) {
          if (_cachedFacilities != state.facilities || _isLoadingFacilities) {
            _cachedFacilities = state.facilities;
            _isLoadingFacilities = false;
            needsUpdate = true;
          }
        } else if (state is HotelHotelFacilitiesLoading) {
          if (!_isLoadingFacilities) {
            _isLoadingFacilities = true;
            needsUpdate = true;
          }
        } else if (state is HotelHotelFacilitiesFailure) {
          if (_isLoadingFacilities) {
            _isLoadingFacilities = false;
            needsUpdate = true;
          }
        }

        // Handle Services in Room
        if (state is HotelHotelServicesInRoomSuccess) {
          if (_cachedServices != state.services || _isLoadingServices) {
            _cachedServices = state.services;
            _isLoadingServices = false;
            needsUpdate = true;
          }
        } else if (state is HotelHotelServicesInRoomLoading) {
          if (!_isLoadingServices) {
            _isLoadingServices = true;
            needsUpdate = true;
          }
        } else if (state is HotelHotelServicesInRoomFailure) {
          if (_isLoadingServices) {
            _isLoadingServices = false;
            needsUpdate = true;
          }
        }

        if (state is HotelRoomTypesSuccess) {
          if (_cachedRoomTypes != state.roomTypes || _isLoadingRoomTypes) {
            _cachedRoomTypes = state.roomTypes;
            _isLoadingRoomTypes = false;
            needsUpdate = true;
          }
        } else if (state is HotelRoomTypesLoading) {
          if (!_isLoadingRoomTypes) {
            _isLoadingRoomTypes = true;
            needsUpdate = true;
          }
        } else if (state is HotelRoomTypesFailure) {
          if (_isLoadingRoomTypes) {
            _isLoadingRoomTypes = false;
            needsUpdate = true;
          }
        }

        // Single setState call to prevent multiple rebuilds and hanging
        if (needsUpdate && mounted) {
          setState(() {});
        }
      },
      child: BlocBuilder<HotelBloc, HotelState>(
        builder: (context, state) {
          // Use cached data
          final hotelPhotos = _cachedPhotos;
          final hotelFacilities = _cachedFacilities;
          final servicesInRoom = _cachedServices;
          final roomTypes = _cachedRoomTypes;

          final isLoadingPhotos = _isLoadingPhotos;
          final isLoadingFacilities = _isLoadingFacilities;
          final isLoadingServices = _isLoadingServices;
          final isLoadingRoomTypes = _isLoadingRoomTypes;

          // Agar hotel.imageUrl bo'sh bo'lsa va rasmlar yuklangan bo'lsa, default rasmni ishlatamiz
          final displayImageUrl = hotel.imageUrl?.isNotEmpty == true
              ? hotel.imageUrl!
              : (hotelPhotos.isNotEmpty
                  ? hotelPhotos.first.url
                  : 'https://placehold.co/400x300');

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight:
                        280.h, // Compacted header height
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded,
                            color: AppColors.primaryBlue),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24.r),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24.r),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: displayImageUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 1200,
                              memCacheHeight: 800,
                              placeholder: (context, url) => Container(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            // Gradient overlay for better text visibility if needed
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                            // Gallery button
                            Positioned(
                              bottom: 16.h,
                              right: 16.w,
                              child: GestureDetector(
                                onTap: () {
                                  final photos = hotelPhotos.isNotEmpty
                                      ? hotelPhotos.map((p) => p.url).toList()
                                      : [displayImageUrl];
                                  if (photos.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HotelPhotosGallery(
                                          photoUrls: photos,
                                          initialIndex: 0,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_library_rounded,
                                          color: Colors.white, size: 16.sp),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${hotelPhotos.length}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize:
                          Size.fromHeight(56.h), // Compact Title + TabBar
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24.r),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hotel Title and Location
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          hotel.name,
                                          style:
                                              AppTypography.headingL.copyWith(
                                            fontSize: 20.sp,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hotel.rating != null &&
                                          hotel.rating! > 0) ...[
                                        SizedBox(width: 8.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star_rounded,
                                                  color: Theme.of(context).colorScheme.onTertiary,
                                                  size: 14.sp),
                                              SizedBox(width: 4.w),
                                              Text(
                                                hotel.rating!
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onTertiary,
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    hotel.address,
                                    style: AppTypography.bodySecondary.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // TabBar
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelColor: Theme.of(context).colorScheme.primary,
                              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              indicatorColor: Theme.of(context).colorScheme.primary,
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: Theme.of(context).dividerColor,
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              tabs: [
                                Tab(text: 'hotel.details.tab_description'.tr()),
                                Tab(
                                    text:
                                        'hotel.details.tab_availability'.tr()),
                                Tab(text: 'hotel.details.tab_services'.tr()),
                                Tab(text: 'hotel.details.tab_conditions'.tr()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },

              body: TabBarView(
                controller: _tabController,
                children: [
                  // Таб 1: Описание (с картой)
                  _buildDescriptionTab(hotel, hotelPhotos, hotelFacilities,
                      isLoadingFacilities, servicesInRoom, isLoadingServices),
                  // Таб 2: Доступность (комнаты)
                  _buildAvailabilityTab(hotel, roomTypes, isLoadingRoomTypes),
                  // Таб 3: Услуги (фотографии)
                  _buildServicesTab(hotelPhotos, isLoadingPhotos,
                      hotelFacilities, isLoadingFacilities),
                  // Таб 4: Условия
                  _buildConditionsTab(hotel),
                ],
              ),
            ),

            // Bottom sheet для бронирования
            bottomNavigationBar: _selectedOption != null ||
                    (hotel.options != null && hotel.options!.isNotEmpty)
                ? Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).shadowColor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'hotel.booking_details.total_amount'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12.sp),
                                ),
                                Text(
                                  () {
                                    final code = (_selectedOption?.currency ?? 'UZS').toUpperCase();
                                    return NumberFormat.simpleCurrency(name: code).format(_selectedOption?.price ?? hotel.price ?? 0);
                                  }(),
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HotelBookingPage(
                                    hotel: hotel,
                                    selectedOption: _selectedOption,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'hotel.details.book_now'.tr(),
                              style: TextStyle(
                                  fontSize: 16.sp, color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  // Функции для табов
  Widget _buildDescriptionTab(
    Hotel hotel,
    List<HotelPhoto> hotelPhotos,
    List<Facility> hotelFacilities,
    bool isLoadingFacilities,
    List<ServiceInRoom> servicesInRoom,
    bool isLoadingServices,
  ) {
    // Fallback to hotel.amenities if structured facilities are missing
    var displayFacilities = hotelFacilities.cast<dynamic>();
    if (displayFacilities.isEmpty && hotel.amenities != null && hotel.amenities!.isNotEmpty) {
      displayFacilities = hotel.amenities!.cast<dynamic>();
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Описание
          _buildExpandableDescription(context, hotel.description),
          SizedBox(height: 24.h),

          // Карта (обновленная)
          _buildMapSection(hotel),
          SizedBox(height: 24.h),

          // Hotel Services (Mehmonxonadagi xizmatlar)
          if (servicesInRoom.isNotEmpty || isLoadingServices) ...[
            _buildServicesSection('Mehmonxonadagi xizmatlar',
                servicesInRoom.cast<dynamic>(), isLoadingServices),
            SizedBox(height: 24.h),
          ] else ...[
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hotel.details.no_services'.tr(),
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<HotelBloc>()
                            .add(GetHotelServicesInRoomRequested(widget.hotel.hotelId));
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('hotel.common.retry'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Hotel Facilities (Mehmonxona imkoniyatlari)
          if (displayFacilities.isNotEmpty || isLoadingFacilities) ...[
            _buildServicesSection('Mehmonxona imkoniyatlari',
                displayFacilities, isLoadingFacilities),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hotel.details.no_facilities'.tr(),
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<HotelBloc>()
                            .add(GetHotelFacilitiesRequested(widget.hotel.hotelId));
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('hotel.common.retry'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Универсальный виджет для секции услуг/удобств
  Widget _buildServicesSection(
      String title, List<dynamic> items, bool isLoading) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return SizedBox.shrink();

    // Limit to 6 items if there are too many, or maybe all
    final displayItems = items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingL.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.0, // Подобрано под высоту строки
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: displayItems.length > 8
                    ? 8
                    : displayItems.length, // Limit initial view
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  String name = '';
                  String? iconName;

                  if (item is Facility) {
                    name = item.getDisplayName(context.locale.toString());
                    iconName = item.icon;
                  } else if (item is ServiceInRoom) {
                    name = item.getDisplayName(context.locale.toString());
                    iconName = item.icon;
                  } else if (item is String) {
                    name = item;
                  }

                  // Fallback icon mapping
                  IconData icon = Icons.check_circle_outline;
                  final nameLower = name.toLowerCase();
                  if (nameLower.contains('wifi') ||
                      nameLower.contains('wi-fi') ||
                      nameLower.contains('internet')) {
                    icon = Icons.wifi;
                  } else if (nameLower.contains('pool') ||
                      nameLower.contains('basseyn') ||
                      nameLower.contains('swimming')) {
                    icon = Icons.pool;
                  } else if (nameLower.contains('gym') ||
                      nameLower.contains('fitness') ||
                      nameLower.contains('sport')) {
                    icon = Icons.fitness_center;
                  } else if (nameLower.contains('restaurant') ||
                      nameLower.contains('restoran') ||
                      nameLower.contains('dining') ||
                      nameLower.contains('cafe')) {
                    icon = Icons.restaurant;
                  } else if (nameLower.contains('parking') ||
                      nameLower.contains('turargoh') ||
                      nameLower.contains('parkovka')) {
                    icon = Icons.local_parking;
                  } else if (nameLower.contains('spa') ||
                      nameLower.contains('wellness') ||
                      nameLower.contains('sauna') ||
                      nameLower.contains('massage')) {
                    icon = Icons.spa;
                  } else if (nameLower.contains('breakfast') ||
                      nameLower.contains('nonushta')) {
                    icon = Icons.breakfast_dining;
                  } else if (nameLower.contains('bar') ||
                      nameLower.contains('drink') ||
                      nameLower.contains('coffee')) {
                    icon = Icons.local_bar;
                  } else if (nameLower.contains('air') ||
                      nameLower.contains('conditioning') ||
                      nameLower.contains('ac')) {
                    icon = Icons.ac_unit;
                  } else if (nameLower.contains('tv') ||
                      nameLower.contains('televizor') ||
                      nameLower.contains('satellite') ||
                      nameLower.contains('cable')) {
                    icon = Icons.tv;
                  } else if (nameLower.contains('consierge') ||
                      nameLower.contains('konsyerj') ||
                      nameLower.contains('reception') ||
                      nameLower.contains('desk')) {
                    icon = Icons.room_service;
                  } else if (nameLower.contains('meeting') ||
                      nameLower.contains('conference') ||
                      nameLower.contains('konferens') ||
                      nameLower.contains('business')) {
                    icon = Icons.meeting_room;
                  } else if (nameLower.contains('luggage') ||
                      nameLower.contains('baggage') ||
                      nameLower.contains('storage')) {
                    icon = Icons.luggage;
                  } else if (nameLower.contains('laundry') ||
                      nameLower.contains('ironing') ||
                      nameLower.contains('cleaning') ||
                      nameLower.contains('dry')) {
                    icon = Icons.local_laundry_service;
                  } else if (nameLower.contains('safe') ||
                      nameLower.contains('security') ||
                      nameLower.contains('locker')) {
                    icon = Icons.security;
                  } else if (nameLower.contains('family') ||
                      nameLower.contains('kids') ||
                      nameLower.contains('child')) {
                    icon = Icons.family_restroom;
                  } else if (nameLower.contains('terrace') ||
                      nameLower.contains('garden') ||
                      nameLower.contains('park')) {
                    icon = Icons.deck;
                  } else if (nameLower.contains('lift') ||
                      nameLower.contains('elevator')) {
                    icon = Icons.elevator;
                  } else if (nameLower.contains('kitchen') ||
                      nameLower.contains('fridge') ||
                      nameLower.contains('microwave')) {
                    icon = Icons.kitchen;
                  } else if (nameLower.contains('smoke') ||
                      nameLower.contains('smoking')) {
                    icon = Icons.smoke_free; // Or smoking_rooms depending on context, but usually it's non-smoking
                  } else if (nameLower.contains('pet') ||
                      nameLower.contains('dog') ||
                      nameLower.contains('cat')) {
                    icon = Icons.pets;
                  } else if (nameLower.contains('transfer') ||
                      nameLower.contains('shuttle') ||
                      nameLower.contains('airport')) {
                    icon = Icons.airport_shuttle;
                  } else if (nameLower.contains('card') ||
                      nameLower.contains('payment') ||
                      nameLower.contains('atm')) {
                    icon = Icons.credit_card;
                  } else if (nameLower.contains('view') ||
                      nameLower.contains('balcony')) {
                    icon = Icons.balcony;
                  } else if (nameLower.contains('shower') ||
                      nameLower.contains('bath') ||
                      nameLower.contains('toilet')) {
                    icon = Icons.bathtub;
                  }

                  return Row(
                    children: [
                      Icon(icon, size: 20.sp, color: Colors.grey[700]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (displayItems.length > 8) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                        ),
                        builder: (ctx) {
                          return SafeArea(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: AppTypography.headingL.copyWith(fontSize: 18.sp),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        icon: Icon(Icons.close),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: displayItems.length,
                                    separatorBuilder: (_, __) => Divider(),
                                    itemBuilder: (context, index) {
                                      final item = displayItems[index];
                                      String name = '';
                                      if (item is Facility) {
                                        name = item.getDisplayName(context.locale.toString());
                                      } else if (item is ServiceInRoom) {
                                        name = item.getDisplayName(context.locale.toString());
                                      } else if (item is String) {
                                        name = item;
                                      }

                                      IconData icon = Icons.check_circle_outline;
                                      final nameLower = name.toLowerCase();
                                      if (nameLower.contains('wifi') ||
                                          nameLower.contains('wi-fi') ||
                                          nameLower.contains('internet')) {
                                        icon = Icons.wifi;
                                      } else if (nameLower.contains('pool') ||
                                          nameLower.contains('basseyn') ||
                                          nameLower.contains('swimming')) {
                                        icon = Icons.pool;
                                      } else if (nameLower.contains('gym') ||
                                          nameLower.contains('fitness') ||
                                          nameLower.contains('sport')) {
                                        icon = Icons.fitness_center;
                                      } else if (nameLower.contains('restaurant') ||
                                          nameLower.contains('restoran') ||
                                          nameLower.contains('dining') ||
                                          nameLower.contains('cafe')) {
                                        icon = Icons.restaurant;
                                      } else if (nameLower.contains('parking') ||
                                          nameLower.contains('turargoh') ||
                                          nameLower.contains('parkovka')) {
                                        icon = Icons.local_parking;
                                      }

                                      return Row(
                                        children: [
                                          Icon(icon, size: 20.sp, color: Colors.grey[700]),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'hotel.details.read_more'.tr(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : AppColors.secondaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.getSubtitleColor(isDark).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.getBorderColor(isDark).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.getTextColor(isDark),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    HotelOption option,
    bool isSelected, {
    List<RoomType>? roomTypes,
    VoidCallback? onTap,
  }) {
    final price = option.price ?? 0.0;
    final currencyCode = (option.currency ?? 'UZS').toUpperCase();
    final mealOptions = option.includedMealOptions?.join(', ') ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find actual room name
    String roomName = 'Xona #${option.roomTypeId ?? ''}';
    if (roomTypes != null && option.roomTypeId != null) {
      try {
        final matching =
            roomTypes.firstWhere((rt) => rt.id == option.roomTypeId);
        roomName = matching.getDisplayName(context.locale.toString());
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.getCardBg(isDark),
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.getBorderColor(isDark),
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: AppColors.getSubtitleColor(isDark).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              roomName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: 8.w),
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.primaryBlue, size: 18.sp),
                          ],
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SizedBox.shrink(),
                      if (mealOptions.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.restaurant_menu_rounded,
                                size: 14.sp, color: AppColors.orangeWarning),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                mealOptions,
                                style: AppTypography.bodySecondary.copyWith(
                                  color: AppColors.getSubtitleColor(isDark),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.simpleCurrency(name: currencyCode).format(price),
                      style: AppTypography.headingL.copyWith(
                          fontSize: 18.sp, color: AppColors.primaryBlue),
                    ),
                    if (option.cancellationPolicy != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 12.sp, color: AppColors.accentGreen),
                            SizedBox(width: 2.w),
                            Text(
                              'Cancellable',
                              style: TextStyle(
                                  color: AppColors.accentGreen,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (option.priceBreakdown != null) ...[
              SizedBox(height: 12.h),
              Divider(color: AppColors.getBorderColor(isDark).withOpacity(0.5)),
              SizedBox(height: 8.h),
              Text(
                'Price Breakdown:',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.getTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...option.priceBreakdown!.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.toString(),
                        style: AppTypography.caption
                            .copyWith(color: AppColors.getSubtitleColor(isDark)),
                      ),
                      Text(
                        entry.value.toString(),
                        style: AppTypography.caption.copyWith(
                            color: AppColors.getTextColor(isDark),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(
      BuildContext context, String? description) {
    if (description == null || description.isEmpty) {
      return SizedBox.shrink();
    }

    // Get localized description (preserving HTML)
    final localizedText = _getLocalizedDescription(context, description);

    // Get stripped version for collapsed view
    final strippedText = _stripHtmlTags(localizedText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hotel.details.description'.tr(),
          style: AppTypography.headingL.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (this._isDescriptionExpanded)
                Html(
                  data: localizedText,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(14.sp),
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87),
                      lineHeight: LineHeight(1.6),
                    ),
                    "a": Style(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  },
                )
              else
                Text(
                  strippedText,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87),
                    height: 1.6,
                    fontSize: 14.sp,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () {
                  setState(() {
                    this._isDescriptionExpanded = !this._isDescriptionExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Text(
                    this._isDescriptionExpanded
                        ? 'hotel.details.read_less'
                            .tr() // Ensure this key exists or use fallback
                        : 'hotel.details.read_more'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Получает локализованное описание (сохраняя HTML)
  String _getLocalizedDescription(BuildContext context, String description) {
    if (description.isEmpty) return '';

    try {
      // Проверяем, является ли описание JSON строкой
      if (description.trim().startsWith('{') ||
          description.trim().startsWith('[')) {
        final parsed = json.decode(description);

        if (parsed is Map) {
          // Получаем текущую локаль
          final locale = context.locale.toString();

          final variants = <String>[];
          final localeLower = locale.toLowerCase();

          // Add exact match
          variants.add(locale);

          // Handle Cyrillic
          if (localeLower == 'uz_cyr' || localeLower == 'uz-cyr') {
            variants.addAll(['uz_CYR', 'uz-CYR', 'uz_cyr', 'uz-cyr']);
          }

          // Добавляем базовый код языка
          if (locale.contains('-') || locale.contains('_')) {
            final base = locale.split(RegExp(r'[-_]')).first.toLowerCase();
            if (base.isNotEmpty) variants.add(base);
          }

          // Пытаемся найти описание в предпочитаемой локали
          String? descText;
          for (final variant in variants) {
            if (parsed[variant] != null) {
              descText = parsed[variant].toString();
              if (descText.isNotEmpty) break;
            }
          }

          // Fallback к общим ключам с приоритетом
          descText ??= parsed['uz']?.toString() ??
              parsed['uz_CYR']?.toString() ??
              parsed['ru']?.toString() ??
              parsed['en']?.toString() ??
              parsed['value']?.toString() ??
              parsed['text']?.toString() ??
              (parsed.isNotEmpty ? parsed.values.first.toString() : null);

          if (descText != null && descText.isNotEmpty) {
            return descText;
          }
        } else if (parsed is List && parsed.isNotEmpty) {
          final firstItem = parsed[0];
          if (firstItem is Map) {
            return _getLocalizedDescription(context, jsonEncode(firstItem));
          } else if (firstItem is String) {
            return firstItem;
          }
        }
      }
    } catch (e) {
      // Error parsing description - silently continue with fallback
    }

    // Если не JSON, просто возвращаем как есть (HTML)
    return description;
  }

  /// Удаляет HTML теги из текста
  String _stripHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';

    // Простое удаление HTML тегов
    String text = htmlText
        .replaceAll(RegExp(r'<(br|p|div|li)[^>]*>', caseSensitive: false),
            '\n') // Заменяем блочные теги на перенос строки
        .replaceAll(RegExp(r'<[^>]*>'), '') // Удаляем остальные HTML теги
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

  Widget _buildAvailabilityTab(
      Hotel hotel, List<RoomType> roomTypes, bool isLoadingRoomTypes) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Комнаты из options
          if (hotel.options != null && hotel.options!.isNotEmpty) ...[
            Text(
              'hotel.details.rooms'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ...hotel.options!.asMap().entries.map((entry) {
              final option = entry.value;
              final isSelected =
                  _selectedOption?.optionRefId == option.optionRefId;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildOptionItem(
                  context,
                  option,
                  isSelected,
                  roomTypes: roomTypes, // Pass cached room types
                  onTap: () {
                    setState(() {
                      _selectedOption = option;
                    });
                  },
                ),
              );
            }).toList(),
          ],

          // Room Types из API
          if (roomTypes.isNotEmpty || isLoadingRoomTypes) ...[
            SizedBox(height: 24.h),
            Text(
              'hotel.details.room_types'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (isLoadingRoomTypes)
              const Center(child: CircularProgressIndicator())
            else
              ...roomTypes.map((roomType) {
                final locale = context.locale.toString();
                final displayName = roomType.getDisplayName(locale);
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      if (roomType.maxOccupancy != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'hotel.details.max_guests'.tr().replaceAll(
                              '{count}', roomType.maxOccupancy.toString()),
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color),
                        ),
                      ],
                      if (roomType.description != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          roomType.description!,
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesTab(List<HotelPhoto> hotelPhotos, bool isLoadingPhotos,
      List<Facility> hotelFacilities, bool isLoadingFacilities) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фотографии
          if (hotelPhotos.isNotEmpty || isLoadingPhotos) ...[
            Text(
              'hotel.details.photos'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (isLoadingPhotos)
              const Center(child: CircularProgressIndicator())
            else
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1.0,
                ),
                itemCount: hotelPhotos.length,
                itemBuilder: (context, index) {
                  final photo = hotelPhotos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HotelPhotosGallery(
                            photoUrls: hotelPhotos.map((p) => p.url).toList(),
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: photo.thumbnailUrl ?? photo.url,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 24.h),
          ],

          // Удобства (для таба Services оставим как есть или используем новый виджет)
          // Uses the new helper or old one? User asked for specifics in Description tab.
          // Let's keep this tab simple or reuse the new section style.
          if (hotelFacilities.isNotEmpty || isLoadingFacilities)
            _buildServicesSection('hotel.details.facilities'.tr(),
                hotelFacilities.cast<dynamic>(), isLoadingFacilities),
        ],
      ),
    );
  }

  Widget _buildConditionsTab(Hotel hotel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Важная информация
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hotel.details.important_notes'.tr(),
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                SizedBox(height: 12.h),
                _buildConditionItem('hotel.details.condition_arrival_time'.tr(),
                    icon: Icons.flight_land),
                _buildConditionItem('hotel.details.condition_visa'.tr(),
                    icon: Icons.assignment_late),
                _buildConditionItem('hotel.details.condition_marriage'.tr(),
                    icon: Icons.family_restroom),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Время заезда/выезда
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                    'hotel.details.check_in_time'.tr(), '14:00 - 23:59'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTimeCard(
                    'hotel.details.check_out_time'.tr(), '00:01 - 12:00'),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Политика возраста
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hotel.details.age_policy'.tr(),
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'hotel.details.age_policy_content'.tr(),
                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(Hotel hotel) {
    // Realistic Map View using a static image placeholder that looks like a real map
    // Ideally we would use a real static map API, but here we use a high quality placeholder
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFE5E3DF),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static Map Background with Custom Painting
                Container(
                  color: Color(0xFFE3E4E6), // Standard Google Maps background
                  child: Stack(
                    children: [
                      // Background blocks
                      Positioned.fill(
                          child: CustomPaint(
                        painter: MapPlaceholderPainter(),
                      )),
                    ],
                  ),
                ),

                // Interactive InkWell - MOVED TO BACKGROUND to avoid blocking buttons
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        try {
                          final query = Uri.encodeComponent(
                              '${hotel.name}, ${hotel.address}');
                          final url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$query');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        } catch (e) {}
                      },
                    ),
                  ),
                ),

                // Overlay Gradient at bottom for text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60.h,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1)
                      ],
                    )),
                  ),
                ),

                // Map Marker - Central and Realistic
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4))
                            ]),
                        child: Icon(Icons.location_on,
                            size: 32.sp, color: Colors.blue),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          children: [
                            Text(
                              hotel.name,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hotel.rating != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star,
                                      size: 10.sp, color: Colors.amber),
                                  Text('${hotel.rating}',
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.black54)),
                                ],
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // Zoom controls
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: Column(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 4)
                            ]),
                        child: Icon(Icons.add,
                            size: 22.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 4)
                            ]),
                        child: Icon(Icons.remove,
                            size: 22.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),

                // "Open Map" button (Floating)
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final query = Uri.encodeComponent(
                            '${hotel.name}, ${hotel.address}');
                        final url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$query');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'hotel.details.open_map_error'.tr())), // Add key if missing or use default
                            );
                          }
                        }
                      } catch (e) {
                        // ignore
                      }
                    },
                    icon: Icon(Icons.map_outlined,
                        size: 16.sp, color: Theme.of(context).colorScheme.onPrimary),
                    label: Text('hotel.details.open_map'.tr(),
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r)),
                      elevation: 4,
                    ),
                  ),
                ),

                // Removed overlapping InkWell to avoid blocking other controls
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionItem(String text, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.info_outline,
              size: 16.sp, color: Colors.orange[700]),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Colors.orange[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String title, String time) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Helper Painter for Map Placeholder - Moved to top level
class MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background: Light Grey
    paint.color = Color(0xFFE5E7EB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Green Areas (Parks)
    paint.color = Color(0xFFC8E6C9).withOpacity(0.5);
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.1, size.height * 0.1, size.width * 0.3, size.height * 0.4),
        paint);
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.6, size.height * 0.5, size.width * 0.25, size.height * 0.3),
        paint);

    // Water (River)
    paint.color = Color(0xFFBBDEFB);
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.9, size.width, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 1.0, 0, size.height * 0.9);
    canvas.drawPath(path, paint);

    // Roads (Lines)
    paint.color = Colors.white;
    paint.strokeWidth = 12.w;
    paint.style = PaintingStyle.stroke;

    // Main Avenue
    canvas.drawLine(Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4), paint);
    // Cross Street
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.4, size.height), paint);

    // Smaller Roads
    paint.strokeWidth = 6.w;
    canvas.drawLine(Offset(0, size.height * 0.2),
        Offset(size.width * 0.4, size.height * 0.2), paint);
    canvas.drawLine(Offset(size.width * 0.4, size.height * 0.7),
        Offset(size.width, size.height * 0.7), paint);

    // Buildings (Blocks)
    paint.style = PaintingStyle.fill;
    paint.color = Color(0xFFE0E0E0);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.45, 60.w, 40.h), paint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.1, 80.w, 50.h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
