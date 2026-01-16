import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/navigation/app_router.dart';
import 'package:auto_route/auto_route.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/reference_data.dart';
import '../bloc/hotel_bloc.dart';
import '../widgets/hotel_photos_gallery.dart';
import '../widgets/hotel_map_widget.dart';
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
  // Map to store selected room count for each option (optionRefId -> room count)
  final Map<String, int> _selectedRoomCounts = {};

  // State cache - oldingi state'larni saqlash
  List<HotelPhoto> _cachedPhotos = [];
  List<Facility> _cachedFacilities = [];
  List<ServiceInRoom> _cachedServices = [];
  List<RoomType> _cachedRoomTypes = [];
  List<NearbyPlace> _cachedNearbyPlaces = [];
  List<HotelPhoto> _cachedRoomPhotos = [];
  List<Equipment> _cachedEquipment = []; // Hotel'ning barcha room type'laridagi equipment'lar

  bool _isLoadingPhotos = false;
  bool _isLoadingFacilities = false;
  bool _isLoadingServices = false;
  bool _isLoadingRoomTypes = false;
  bool _isLoadingNearbyPlaces = false;
  bool _isLoadingRoomPhotos = false;
  bool _isLoadingEquipment = false;

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
      context.read<HotelBloc>().add(GetHotelNearbyPlacesRequested(hotelId));
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
            // Log success for debugging
            if (kDebugMode) {
              debugPrint('✅ Hotel Services In Room Success: Found ${state.services.length} services');
            }
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
          // Log error for debugging
          if (kDebugMode) {
            debugPrint('❌ Hotel Services In Room Error: ${state.message}');
          }
        }

        if (state is HotelRoomTypesSuccess) {
          if (_cachedRoomTypes != state.roomTypes || _isLoadingRoomTypes) {
            _cachedRoomTypes = state.roomTypes;
            _isLoadingRoomTypes = false;
            needsUpdate = true;
            // Load room photos and equipment for all room types
            if (state.roomTypes.isNotEmpty) {
              final hotelId = widget.hotel.hotelId;
              for (final roomType in state.roomTypes) {
                context.read<HotelBloc>().add(
                  GetHotelRoomPhotosRequested(
                    hotelId: hotelId,
                    roomTypeId: roomType.id,
                  ),
                );
                // Load equipment for each room type
                context.read<HotelBloc>().add(
                  GetRoomTypeEquipmentRequested(roomType.id),
                );
              }
            }
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
          // Show error message to user
          if (mounted) {
            SnackbarHelper.showError(context, state.message);
          }
        }

        // Handle Room Type Equipment
        if (state is HotelRoomTypeEquipmentSuccess) {
          // Aggregate equipment from all room types (unique by id)
          final existingIds = _cachedEquipment.map((e) => e.id).toSet();
          final newEquipment = state.equipment
              .where((e) => !existingIds.contains(e.id))
              .toList();
          if (newEquipment.isNotEmpty || _isLoadingEquipment) {
            _cachedEquipment = [..._cachedEquipment, ...newEquipment];
            _isLoadingEquipment = false;
            needsUpdate = true;
          }
        } else if (state is HotelRoomTypeEquipmentLoading) {
          if (!_isLoadingEquipment) {
            _isLoadingEquipment = true;
            needsUpdate = true;
          }
        } else if (state is HotelRoomTypeEquipmentFailure) {
          if (_isLoadingEquipment) {
            _isLoadingEquipment = false;
            needsUpdate = true;
          }
        }

        // Handle Nearby Places
        if (state is HotelNearbyPlacesSuccess) {
          if (_cachedNearbyPlaces != state.places || _isLoadingNearbyPlaces) {
            _cachedNearbyPlaces = state.places;
            _isLoadingNearbyPlaces = false;
            needsUpdate = true;
          }
        } else if (state is HotelNearbyPlacesLoading) {
          if (!_isLoadingNearbyPlaces) {
            _isLoadingNearbyPlaces = true;
            needsUpdate = true;
          }
        } else if (state is HotelNearbyPlacesFailure) {
          if (_isLoadingNearbyPlaces) {
            _isLoadingNearbyPlaces = false;
            needsUpdate = true;
          }
        }

        // Handle Room Photos
        if (state is HotelRoomPhotosSuccess) {
          if (_cachedRoomPhotos != state.photos || _isLoadingRoomPhotos) {
            _cachedRoomPhotos = state.photos;
            _isLoadingRoomPhotos = false;
            needsUpdate = true;
          }
        } else if (state is HotelRoomPhotosLoading) {
          if (!_isLoadingRoomPhotos) {
            _isLoadingRoomPhotos = true;
            needsUpdate = true;
          }
        } else if (state is HotelRoomPhotosFailure) {
          if (_isLoadingRoomPhotos) {
            _isLoadingRoomPhotos = false;
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
          final nearbyPlaces = _cachedNearbyPlaces;
          final roomPhotos = _cachedRoomPhotos;
          final hotelEquipment = _cachedEquipment;

          final isLoadingPhotos = _isLoadingPhotos;
          final isLoadingFacilities = _isLoadingFacilities;
          final isLoadingServices = _isLoadingServices;
          final isLoadingRoomTypes = _isLoadingRoomTypes;
          final isLoadingNearbyPlaces = _isLoadingNearbyPlaces;
          final isLoadingRoomPhotos = _isLoadingRoomPhotos;
          final isLoadingEquipment = _isLoadingEquipment;

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
                        360.h, // Taller header so image is fully visible
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
                        bottom: Radius.circular(32.r),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32.r),
                          ),
                          border: Border.all(
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32.r),
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
                                  color: Theme.of(context).cardColor,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).cardColor,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
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
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(0.7)
                                          : Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.3)),
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
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32.r),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hotel Title and Location
                            Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
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
                                              AppTypography.headingL(context).copyWith(
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star_rounded,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onTertiary,
                                                  size: 14.sp),
                                              SizedBox(width: 4.w),
                                              Text(
                                                hotel.rating!
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onTertiary,
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
                                    style: AppTypography.bodySecondary(context).copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // TabBar
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .cardColor
                                    .withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: false,
                                  labelColor:
                                      Theme.of(context).colorScheme.primary,
                                  unselectedLabelColor: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6),
                                  indicatorColor: Colors.transparent,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.sp,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: 11.sp,
                                  ),
                                  tabs: [
                                    Tab(
                                        text: 'hotel.details.tab_description'
                                            .tr()),
                                    Tab(
                                        text: 'hotel.details.tab_availability'
                                            .tr()),
                                    Tab(
                                        text:
                                            'hotel.details.tab_services'.tr()),
                                    Tab(
                                        text: 'hotel.details.tab_conditions'
                                            .tr()),
                                  ],
                                ),
                              ),
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
                      isLoadingFacilities, servicesInRoom, isLoadingServices,
                      nearbyPlaces, isLoadingNearbyPlaces, hotelEquipment, isLoadingEquipment),
                  // Таб 2: Доступность (комнаты)
                  _buildAvailabilityTab(hotel, roomTypes, isLoadingRoomTypes,
                      roomPhotos, isLoadingRoomPhotos),
                  // Таб 3: Услуги (фотографии)
                  _buildServicesTab(hotelPhotos, isLoadingPhotos,
                      hotelFacilities, isLoadingFacilities, hotelEquipment, isLoadingEquipment),
                  // Таб 4: Условия
                  _buildConditionsTab(hotel),
                ],
              ),
            ),

            // Bottom bar для бронирования с total amount
            bottomNavigationBar: _buildBottomBar(hotel, roomTypes),
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
    List<NearbyPlace> nearbyPlaces,
    bool isLoadingNearbyPlaces,
    List<Equipment> hotelEquipment,
    bool isLoadingEquipment,
  ) {
    // Fallback to hotel.amenities if structured facilities are missing
    var displayFacilities = hotelFacilities.cast<dynamic>();
    if (displayFacilities.isEmpty &&
        hotel.amenities != null &&
        hotel.amenities!.isNotEmpty) {
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
            _buildServicesSection('hotel.details.services_in_room'.tr(),
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
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).dividerColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hotel.details.no_services'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<HotelBloc>().add(
                            GetHotelServicesInRoomRequested(
                                widget.hotel.hotelId));
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('hotel.common.retry'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Hotel Facilities (Mehmonxona imkoniyatlari - Xizmatlar)
          if (displayFacilities.isNotEmpty || isLoadingFacilities) ...[
            _buildServicesSection('hotel.details.hotel_facilities'.tr(), displayFacilities,
                isLoadingFacilities),
            SizedBox(height: 24.h),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).dividerColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hotel.details.no_facilities'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<HotelBloc>().add(
                            GetHotelFacilitiesRequested(widget.hotel.hotelId));
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('hotel.common.retry'.tr()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }

  // Универсальный виджет для секции услуг/удобств
  Widget _buildServicesSection(
      String title, List<dynamic> items, bool isLoading) {
    if (isLoading) return _buildSectionSkeleton(title);
    if (items.isEmpty) return SizedBox.shrink();

    // Limit to 8 items on the card; modal shows all
    final displayItems = items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${items.length})',
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).dividerColor
                  : Colors.grey.shade300,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final itemWidth =
                  (maxWidth - 12.w) / 2; // two items per row with spacing
              final itemsToShow = displayItems.length > 8
                  ? displayItems.take(8).toList()
                  : displayItems;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: itemsToShow.map((item) {
                      String name = '';
                      String? iconName;

                      if (item is Facility) {
                        final locale = _normalizeLocale(context.locale);
                        name = item.getDisplayName(locale);
                        // Fallback if name is empty
                        if (name.isEmpty) {
                          name = item.name.isNotEmpty 
                              ? item.name 
                              : 'Facility ${item.id}';
                        }
                        iconName = item.icon;
                      } else if (item is Equipment) {
                        final locale = _normalizeLocale(context.locale);
                        name = item.getDisplayName(locale);
                        // Fallback if name is empty
                        if (name.isEmpty) {
                          name = item.name.isNotEmpty 
                              ? item.name 
                              : 'Equipment ${item.id}';
                        }
                        iconName = item.icon;
                      } else if (item is ServiceInRoom) {
                        final locale = _normalizeLocale(context.locale);
                        name = item.getDisplayName(locale);
                        // Fallback if name is empty
                        if (name.isEmpty) {
                          name = item.name.isNotEmpty 
                              ? item.name 
                              : 'Service ${item.id}';
                        }
                        iconName = item.icon;
                      } else if (item is String) {
                        name = item.isNotEmpty ? item : 'Unknown';
                      } else if (item is Map) {
                        // Handle Map items (from API response)
                        name = item['name']?.toString() ?? 
                               item['name_uz']?.toString() ?? 
                               item['name_ru']?.toString() ?? 
                               item['name_en']?.toString() ?? 
                               item['title']?.toString() ?? 
                               item['label']?.toString() ?? 
                               'Unknown';
                        iconName = item['icon']?.toString();
                      } else {
                        name = item.toString();
                      }

                      final nameLower = name.toLowerCase();
                      final icon = _mapAmenityIcon(iconName, nameLower);

                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: itemWidth),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              icon,
                              size: 20.sp,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color ??
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (displayItems.length > 8) ...[
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r)),
                            ),
                            builder: (ctx) {
                              return SafeArea(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: AppTypography.headingL(context)
                                                    .copyWith(
                                                  fontSize: 18.sp,
                                                  color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.color ??
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              icon: Icon(Icons.close),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Flexible(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              // Calculate number of columns based on screen width
                                              // For mobile: 2 columns, for tablet: 3-5 columns
                                              final screenWidth = constraints.maxWidth;
                                              int crossAxisCount = 2;
                                              if (screenWidth > 600) {
                                                crossAxisCount = 3;
                                              }
                                              if (screenWidth > 900) {
                                                crossAxisCount = 4;
                                              }
                                              if (screenWidth > 1200) {
                                                crossAxisCount = 5;
                                              }
                                              
                                              return GridView.builder(
                                                shrinkWrap: true,
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: crossAxisCount,
                                                  crossAxisSpacing: 12.w,
                                                  mainAxisSpacing: 12.h,
                                                  childAspectRatio: 4.0, // Adjust based on content
                                                ),
                                                itemCount: displayItems.length,
                                          itemBuilder: (context, index) {
                                            final item = displayItems[index];
                                            String name = '';
                                            String? iconName;
                                            if (item is Facility) {
                                              final locale = _normalizeLocale(context.locale);
                                              name = item.getDisplayName(locale);
                                              // Fallback if name is empty
                                              if (name.isEmpty) {
                                                name = item.name.isNotEmpty 
                                                    ? item.name 
                                                    : 'Facility ${item.id}';
                                              }
                                              iconName = item.icon;
                                            } else if (item is Equipment) {
                                              final locale = _normalizeLocale(context.locale);
                                              name = item.getDisplayName(locale);
                                              // Fallback if name is empty
                                              if (name.isEmpty) {
                                                name = item.name.isNotEmpty 
                                                    ? item.name 
                                                    : 'Equipment ${item.id}';
                                              }
                                              iconName = item.icon;
                                            } else if (item is ServiceInRoom) {
                                              final locale = _normalizeLocale(context.locale);
                                              name = item.getDisplayName(locale);
                                              // Fallback if name is empty
                                              if (name.isEmpty) {
                                                name = item.name.isNotEmpty 
                                                    ? item.name 
                                                    : 'Service ${item.id}';
                                              }
                                              iconName = item.icon;
                                            } else if (item is String) {
                                              name = item.isNotEmpty ? item : 'Unknown';
                                            } else if (item is Map) {
                                              // Handle Map items (from API response)
                                              name = item['name']?.toString() ?? 
                                                     item['name_uz']?.toString() ?? 
                                                     item['name_ru']?.toString() ?? 
                                                     item['name_en']?.toString() ?? 
                                                     item['title']?.toString() ?? 
                                                     item['label']?.toString() ?? 
                                                     'Unknown';
                                              iconName = item['icon']?.toString();
                                            } else {
                                              name = item.toString();
                                            }

                                            final nameLower = name.toLowerCase();
                                            final icon = _mapAmenityIcon(
                                                iconName, nameLower);

                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  icon,
                                                  size: 20.sp,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context).textTheme.bodyMedium?.color ??
                                                          Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                                SizedBox(width: 8.w),
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color ??
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          'hotel.details.read_more'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                  ]
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSkeleton(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
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
            children: [
              _buildSkeletonRow(),
              SizedBox(height: 12.h),
              _buildSkeletonRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonRow() {
    return Row(
      children: [
        Container(
          width: 24.sp,
          height: 24.sp,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).dividerColor.withOpacity(0.6)
                : Colors.grey.shade300.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonLine(0.75),
              SizedBox(height: 6.h),
              _buildSkeletonLine(0.5),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSkeletonLine(double widthFactor) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }

  IconData _mapAmenityIcon(String? iconName, String nameLower) {
    final normalizedIcon =
        iconName?.toLowerCase().replaceAll('_', '').replaceAll('-', '');

    // Use icon name if API sends one
    switch (normalizedIcon) {
      case 'wifi':
      case 'wi-fi':
      case 'internet':
        return Icons.wifi;
      case 'pool':
      case 'swimmingpool':
      case 'swimming':
        return Icons.pool;
      case 'gym':
      case 'fitness':
      case 'sport':
        return Icons.fitness_center;
      case 'restaurant':
      case 'dining':
      case 'cafe':
        return Icons.restaurant;
      case 'parking':
      case 'carpark':
        return Icons.local_parking;
      case 'spa':
      case 'sauna':
      case 'wellness':
        return Icons.spa;
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'bar':
      case 'coffee':
        return Icons.local_bar;
      case 'airconditioner':
      case 'ac':
      case 'airconditioning':
        return Icons.ac_unit;
      case 'tv':
      case 'television':
      case 'satellite':
        return Icons.tv;
      case 'elevator':
      case 'lift':
        return Icons.elevator;
      case 'laundry':
      case 'ironing':
        return Icons.local_laundry_service;
      case 'security':
      case 'safe':
      case 'locker':
        return Icons.security;
      case 'pet':
      case 'pets':
        return Icons.pets;
      case 'shuttle':
      case 'transfer':
      case 'airport':
        return Icons.airport_shuttle;
      case 'kitchen':
      case 'fridge':
      case 'refrigerator':
      case 'microwave':
        return Icons.kitchen;
      case 'bathtub':
      case 'bath':
      case 'shower':
      case 'toilet':
        return Icons.bathtub;
      case 'balcony':
      case 'terrace':
      case 'view':
        return Icons.balcony;
      case 'bed':
      case 'bedroom':
        return Icons.bed;
      case 'wardrobe':
      case 'closet':
        return Icons.checkroom;
      case 'minibar':
        return Icons.local_bar;
      case 'phone':
        return Icons.phone;
      case 'desk':
      case 'workdesk':
        return Icons.desktop_mac;
      case 'hairdryer':
      case 'hair dryer':
        return Icons.content_cut;
      case 'towels':
        return Icons.dry_cleaning;
      case 'linen':
        return Icons.hotel;
      case 'roomservice':
      case 'room service':
      case 'concierge':
        return Icons.room_service;
      case 'business':
      case 'meeting':
      case 'conference':
        return Icons.meeting_room;
      case 'luggage':
      case 'baggage':
        return Icons.luggage;
      case 'garden':
      case 'park':
        return Icons.park;
      case 'family':
      case 'kids':
      case 'children':
        return Icons.family_restroom;
      case 'smoking':
      case 'smoke':
        return Icons.smoking_rooms;
      case 'nonsmoking':
      case 'no smoking':
        return Icons.smoke_free;
      case 'payment':
      case 'card':
      case 'atm':
        return Icons.credit_card;
    }

    // Fallback based on name - kengaytirilgan mapping
    if (nameLower.contains('wifi') ||
        nameLower.contains('wi-fi') ||
        nameLower.contains('internet') ||
        nameLower.contains('интернет')) {
      return Icons.wifi;
    } else if (nameLower.contains('pool') ||
        nameLower.contains('basseyn') ||
        nameLower.contains('бассейн') ||
        nameLower.contains('swimming')) {
      return Icons.pool;
    } else if (nameLower.contains('gym') ||
        nameLower.contains('fitness') ||
        nameLower.contains('sport') ||
        nameLower.contains('спорт')) {
      return Icons.fitness_center;
    } else if (nameLower.contains('restaurant') ||
        nameLower.contains('restoran') ||
        nameLower.contains('ресторан') ||
        nameLower.contains('dining') ||
        nameLower.contains('cafe') ||
        nameLower.contains('кафе')) {
      return Icons.restaurant;
    } else if (nameLower.contains('parking') ||
        nameLower.contains('turargoh') ||
        nameLower.contains('парковка') ||
        nameLower.contains('parkovka')) {
      return Icons.local_parking;
    } else if (nameLower.contains('spa') ||
        nameLower.contains('wellness') ||
        nameLower.contains('sauna') ||
        nameLower.contains('сауна') ||
        nameLower.contains('massage') ||
        nameLower.contains('массаж')) {
      return Icons.spa;
    } else if (nameLower.contains('breakfast') ||
        nameLower.contains('nonushta') ||
        nameLower.contains('завтрак')) {
      return Icons.breakfast_dining;
    } else if (nameLower.contains('bar') ||
        nameLower.contains('drink') ||
        nameLower.contains('coffee') ||
        nameLower.contains('кофе')) {
      return Icons.local_bar;
    } else if (nameLower.contains('air') ||
        nameLower.contains('conditioning') ||
        nameLower.contains('кондиционер') ||
        nameLower.contains('ac')) {
      return Icons.ac_unit;
    } else if (nameLower.contains('tv') ||
        nameLower.contains('televizor') ||
        nameLower.contains('телевизор') ||
        nameLower.contains('satellite') ||
        nameLower.contains('cable')) {
      return Icons.tv;
    } else if (nameLower.contains('concierge') ||
        nameLower.contains('konsyerj') ||
        nameLower.contains('консьерж') ||
        nameLower.contains('reception') ||
        nameLower.contains('reception') ||
        nameLower.contains('стол') ||
        nameLower.contains('desk')) {
      return Icons.room_service;
    } else if (nameLower.contains('meeting') ||
        nameLower.contains('conference') ||
        nameLower.contains('конференц') ||
        nameLower.contains('konferens') ||
        nameLower.contains('business') ||
        nameLower.contains('бизнес')) {
      return Icons.meeting_room;
    } else if (nameLower.contains('luggage') ||
        nameLower.contains('baggage') ||
        nameLower.contains('багаж') ||
        nameLower.contains('storage')) {
      return Icons.luggage;
    } else if (nameLower.contains('laundry') ||
        nameLower.contains('ironing') ||
        nameLower.contains('прачечная') ||
        nameLower.contains('cleaning') ||
        nameLower.contains('dry')) {
      return Icons.local_laundry_service;
    } else if (nameLower.contains('safe') ||
        nameLower.contains('security') ||
        nameLower.contains('сейф') ||
        nameLower.contains('locker')) {
      return Icons.security;
    } else if (nameLower.contains('family') ||
        nameLower.contains('kids') ||
        nameLower.contains('дети') ||
        nameLower.contains('child')) {
      return Icons.family_restroom;
    } else if (nameLower.contains('terrace') ||
        nameLower.contains('garden') ||
        nameLower.contains('сад') ||
        nameLower.contains('park')) {
      return Icons.park;
    } else if (nameLower.contains('lift') ||
        nameLower.contains('elevator') ||
        nameLower.contains('лифт')) {
      return Icons.elevator;
    } else if (nameLower.contains('kitchen') ||
        nameLower.contains('кухня') ||
        nameLower.contains('fridge') ||
        nameLower.contains('холодильник') ||
        nameLower.contains('microwave') ||
        nameLower.contains('микроволновка')) {
      return Icons.kitchen;
    } else if (nameLower.contains('smoke') ||
        nameLower.contains('smoking') ||
        nameLower.contains('курение')) {
      return Icons.smoking_rooms;
    } else if (nameLower.contains('no smoke') ||
        nameLower.contains('non-smoking') ||
        nameLower.contains('не курить')) {
      return Icons.smoke_free;
    } else if (nameLower.contains('pet') ||
        nameLower.contains('dog') ||
        nameLower.contains('cat') ||
        nameLower.contains('животные')) {
      return Icons.pets;
    } else if (nameLower.contains('transfer') ||
        nameLower.contains('shuttle') ||
        nameLower.contains('трансфер') ||
        nameLower.contains('airport')) {
      return Icons.airport_shuttle;
    } else if (nameLower.contains('card') ||
        nameLower.contains('payment') ||
        nameLower.contains('оплата') ||
        nameLower.contains('atm')) {
      return Icons.credit_card;
    } else if (nameLower.contains('view') ||
        nameLower.contains('balcony') ||
        nameLower.contains('балкон')) {
      return Icons.balcony;
    } else if (nameLower.contains('shower') ||
        nameLower.contains('bath') ||
        nameLower.contains('ванна') ||
        nameLower.contains('душ') ||
        nameLower.contains('toilet') ||
        nameLower.contains('туалет')) {
      return Icons.bathtub;
    } else if (nameLower.contains('bed') ||
        nameLower.contains('кровать') ||
        nameLower.contains('спальня')) {
      return Icons.bed;
    } else if (nameLower.contains('wardrobe') ||
        nameLower.contains('closet') ||
        nameLower.contains('шкаф')) {
      return Icons.checkroom;
    } else if (nameLower.contains('phone') ||
        nameLower.contains('телефон')) {
      return Icons.phone;
    } else if (nameLower.contains('desk') ||
        nameLower.contains('workdesk') ||
        nameLower.contains('стол')) {
      return Icons.desktop_mac;
    } else if (nameLower.contains('hairdryer') ||
        nameLower.contains('hair dryer') ||
        nameLower.contains('фен')) {
      return Icons.content_cut;
    } else if (nameLower.contains('towels') ||
        nameLower.contains('полотенца')) {
      return Icons.dry_cleaning;
    } else if (nameLower.contains('minibar') ||
        nameLower.contains('минибар')) {
      return Icons.local_bar;
    }

    // Default icon
    return Icons.check_circle_outline;
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
        final locale = _normalizeLocale(context.locale);
        roomName = matching.getDisplayName(locale);
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
                          Expanded(
                            child: Container(
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
                                style: AppTypography.bodySecondary(context).copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
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
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          NumberFormat.simpleCurrency(name: currencyCode)
                              .format(price),
                          style: AppTypography.headingL(context).copyWith(
                            fontSize: 18.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      if (option.cancellationPolicy != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 12.sp, color: AppColors.accentGreen),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  'hotel.details.cancellable'.tr(),
                                  style: TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (option.priceBreakdown != null) ...[
              SizedBox(height: 12.h),
              Divider(color: AppColors.getBorderColor(isDark).withOpacity(0.5)),
              SizedBox(height: 8.h),
              Text(
                'hotel.details.price_breakdown'.tr(),
                style: AppTypography.labelSmall(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
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
                        style: AppTypography.caption(context).copyWith(
                            color: AppColors.getSubtitleColor(isDark)),
                      ),
                      Text(
                        entry.value.toString(),
                        style: AppTypography.caption(context).copyWith(
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
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).dividerColor
                  : Colors.grey.shade300,
            ),
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
                          Theme.of(context).colorScheme.onSurface,
                      lineHeight: LineHeight(1.6),
                    ),
                    "p": Style(
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).colorScheme.onSurface,
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "div": Style(
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
                    "span": Style(
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Theme.of(context).colorScheme.onSurface,
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
                        Theme.of(context).colorScheme.onSurface,
                    height: 1.6,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
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
          // Получаем текущую локаль и нормализуем её
          final normalizedLocale = _normalizeLocale(context.locale);
          final locale = context.locale.toString();

          final variants = <String>[];
          final localeLower = locale.toLowerCase();

          // Add normalized locale first (most important)
          variants.add(normalizedLocale);
          
          // Add exact match
          variants.add(locale);

          // Handle Cyrillic
          if (localeLower == 'uz_cyr' || localeLower == 'uz-cyr') {
            variants.addAll(['uz_CYR', 'uz-CYR', 'uz_cyr', 'uz-cyr']);
          }

          // Добавляем базовый код языка
          if (locale.contains('-') || locale.contains('_')) {
            final base = locale.split(RegExp(r'[-_]')).first.toLowerCase();
            if (base.isNotEmpty && base != normalizedLocale) variants.add(base);
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
          // Handle lists like: [{locale: 'ru', value: '...'}, {locale: 'en', value: '...'}]
          try {
            // Build a map of locale -> value
            final Map<String, String> locMap = {};
            for (final item in parsed) {
              if (item is Map) {
                // Accept multiple possible keys
                final loc = (item['locale'] ?? item['lang'] ?? item['language'] ?? item['loc'])?.toString();
                final val = (item['value'] ?? item['text'] ?? item['description'] ?? item['name'])?.toString();
                if (loc != null && val != null && val.isNotEmpty) {
                  locMap[loc] = val;
                }
              } else if (item is String && item.isNotEmpty) {
                // If it's a list of strings, pick the first non-empty
                return item;
              }
            }

            if (locMap.isNotEmpty) {
              final normalizedLocale = _normalizeLocale(context.locale);
              final rawLocale = context.locale.toString();
              final variants = <String>[];
              final lowerRaw = rawLocale.toLowerCase();

              variants.add(normalizedLocale);
              variants.add(rawLocale);
              if (lowerRaw == 'uz_cyr' || lowerRaw == 'uz-cyr') {
                variants.addAll(['uz_CYR', 'uz-CYR', 'uz_cyr', 'uz-cyr']);
              }
              if (rawLocale.contains('-') || rawLocale.contains('_')) {
                final base = rawLocale.split(RegExp(r'[-_]')).first;
                if (base.isNotEmpty && base != normalizedLocale) variants.add(base);
              }

              for (final v in variants) {
                if (locMap.containsKey(v)) {
                  return locMap[v]!;
                }
              }

              // Fallback preference order among four languages
              return locMap['uz'] ??
                     locMap['uz_CYR'] ??
                     locMap['en'] ??
                     locMap['ru'] ??
                     locMap.values.first;
            }
          } catch (_) {
            // ignore and fall through
          }
          // If not recognized, fallback to first stringifiable item
          final firstItem = parsed.first;
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

    // Если не JSON, попробуем разобрать псевдо-список вида:
    // [{locale: ru, value: ...}, {locale: en, value: ...}]
    final pseudo = _extractFromPseudoLocaleList(context, description);
    if (pseudo != null && pseudo.isNotEmpty) {
      return pseudo;
    }

    // Если не распознали формат, просто возвращаем как есть (HTML)
    return description;
  }

  /// Пытается извлечь локализованный текст из неполноценного JSON формата
  /// Например: [{locale: ru, value: '...'}, {locale: en, value: '...'}]
  /// Возвращает подходящий по локали текст или null, если формат не распознан
  String? _extractFromPseudoLocaleList(BuildContext context, String text) {
    try {
      // Быстрый фильтр, чтобы избежать лишней работы
      if (!text.contains('locale:') || !text.contains('value:')) return null;

      // Находим пары { locale: XX, value: <...> } (включая lang/language/loc и text/description/name)
      final regex = RegExp(r"\{\s*(?:locale|lang|language|loc)\s*:\s*([^,\s\}]+)\s*,\s*(?:value|text|description|name)\s*:\s*(.*?)\}\s*",
          dotAll: true, multiLine: true);

      final matches = regex.allMatches(text).toList();
      if (matches.isEmpty) return null;

      final Map<String, String> locMap = {};
      for (final m in matches) {
        final loc = m.group(1)?.trim();
        var val = m.group(2)?.trim();
        if (loc == null || val == null) continue;

        // Удаляем окружающие кавычки, если есть
        if ((val.startsWith('"') && val.endsWith('"')) ||
            (val.startsWith('\'') && val.endsWith('\''))) {
          val = val.substring(1, val.length - 1);
        }

        // Убираем завершающие запятые и скобки
        val = val.replaceAll(RegExp(r"^[\s,\[]+|[\s,\]]+$"), '').trim();

        if (val.isNotEmpty) {
          locMap[loc] = val;
        }
      }

      if (locMap.isEmpty) return null;

      // Выбираем по приоритетам локали
      final normalized = _normalizeLocale(context.locale);
      final raw = context.locale.toString();
      final variants = <String>[];
      variants.add(normalized);
      variants.add(raw);
      final rawLower = raw.toLowerCase();
      if (rawLower == 'uz_cyr' || rawLower == 'uz-cyr') {
        variants.addAll(['uz_CYR', 'uz-CYR', 'uz_cyr', 'uz-cyr']);
      }
      if (raw.contains('-') || raw.contains('_')) {
        final base = raw.split(RegExp(r'[-_]')).first;
        if (base.isNotEmpty && base != normalized) variants.add(base);
      }

      for (final v in variants) {
        if (locMap.containsKey(v)) return locMap[v];
      }

      // Жесткий fallback среди 4 языков
      return locMap['uz'] ?? locMap['uz_CYR'] ?? locMap['en'] ?? locMap['ru'] ??
          locMap.values.first;
    } catch (_) {
      return null;
    }
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
  
  /// Normalizes locale for API lookup
  /// Converts en_US -> en, ru_RU -> ru, uz -> uz, uz_CYR -> uz_CYR
  String _normalizeLocale(Locale locale) {
    // Handle Cyrillic Uzbek specially
    if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
      return 'uz_CYR'; // API format
    }
    
    // For other locales, use just the language code
    // en_US -> en, ru_RU -> ru, uz -> uz
    return locale.languageCode;
  }

  /// Calculate total amount based on selected room counts
  /// Returns a map with 'amount' and 'currencyCode'
  /// Returns 0.0 if no rooms are selected
  Map<String, dynamic> _calculateTotalAmount(Hotel hotel) {
    double totalAmount = 0.0;
    String? currencyCode;
    int totalNights = hotel.checkOutDate.difference(hotel.checkInDate).inDays;
    if (totalNights <= 0) totalNights = 1; // At least 1 night
    
    bool hasSelectedRooms = false;
    
    if (hotel.options != null) {
      for (final option in hotel.options!) {
        final roomCount = _selectedRoomCounts[option.optionRefId] ?? 0;
        if (roomCount > 0 && option.price != null) {
          hasSelectedRooms = true;
          totalAmount += (option.price! * roomCount * totalNights);
          if (currencyCode == null) {
            currencyCode = (option.currency ?? 'UZS').toUpperCase();
          }
        }
      }
    }
    
    // If no rooms selected, return 0
    if (!hasSelectedRooms) {
      return {
        'amount': 0.0,
        'currencyCode': 'UZS',
        'hasSelectedRooms': false,
      };
    }
    
    return {
      'amount': totalAmount,
      'currencyCode': currencyCode ?? 'UZS',
      'hasSelectedRooms': true,
    };
  }

  Widget _buildAvailabilityTab(
      Hotel hotel, List<RoomType> roomTypes, bool isLoadingRoomTypes,
      List<HotelPhoto> roomPhotos, bool isLoadingRoomPhotos) {
    // Calculate total amount based on selected room counts
    final totalData = _calculateTotalAmount(hotel);
    final totalAmount = totalData['amount'] as double;
    final currencyCode = totalData['currencyCode'] as String;
    int totalNights = hotel.checkOutDate.difference(hotel.checkInDate).inDays;
    if (totalNights <= 0) totalNights = 1; // At least 1 night
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Комнаты из options - Responsive layout
          if (hotel.options != null && hotel.options!.isNotEmpty) ...[
            Text(
              'hotel.details.available_rooms'.tr(),
              style: AppTypography.headingL(context).copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            // Responsive layout: mobile = card, desktop = table
            LayoutBuilder(
              builder: (context, constraints) {
                // Sort options by price (cheapest first)
                final sortedOptions = List.from(hotel.options!);
                sortedOptions.sort((a, b) {
                  final priceA = a.price ?? double.infinity;
                  final priceB = b.price ?? double.infinity;
                  return priceA.compareTo(priceB);
                });
                
                final isMobile = constraints.maxWidth < 600;
                if (isMobile) {
                  // Mobile: Card-based layout
                  return Column(
                    children: sortedOptions.map((option) {
                      return _buildRoomCard(
                        option,
                        hotel,
                        roomTypes,
                      );
                    }).toList(),
                  );
                } else {
                  // Desktop: Table layout
                  return Column(
                    children: [
                      _buildTableHeader(),
                      SizedBox(height: 12.h),
                      ...sortedOptions.map((option) {
                        return _buildRoomRow(
                          option,
                          hotel,
                          roomTypes,
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
            // Total Amount Section - always show, even if 0
            ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'hotel.details.total_amount'.tr(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color ??
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          NumberFormat.simpleCurrency(name: currencyCode).format(totalAmount),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Breakdown
                    if (hotel.options != null) ...[
                      ...hotel.options!.where((option) {
                        final roomCount = _selectedRoomCounts[option.optionRefId] ?? 0;
                        return roomCount > 0 && option.price != null;
                      }).map((option) {
                        final roomCount = _selectedRoomCounts[option.optionRefId] ?? 0;
                        final optionTotal = (option.price! * roomCount * totalNights);
                        final optionCurrency = (option.currency ?? 'UZS').toUpperCase();
                        
                        // Find room name
                        String roomName = 'Xona #${option.roomTypeId ?? ''}';
                        if (roomTypes.isNotEmpty && option.roomTypeId != null) {
                          try {
                            final matching = roomTypes.firstWhere((rt) => rt.id == option.roomTypeId);
                            final locale = _normalizeLocale(context.locale);
                            roomName = matching.getDisplayName(locale);
                          } catch (_) {}
                        }
                        
                        return Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$roomName × $roomCount ${'hotel.details.room'.tr()} × $totalNights ${'hotel.details.nights'.tr()}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                NumberFormat.simpleCurrency(name: optionCurrency).format(optionTotal),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ],

          // Room Types из API
          if (roomTypes.isNotEmpty || isLoadingRoomTypes) ...[
            SizedBox(height: 24.h),
            Text(
              'hotel.details.room_types'.tr(),
              style: AppTypography.headingL(context).copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            if (isLoadingRoomTypes)
              const Center(child: CircularProgressIndicator())
            else
              ...roomTypes.map((roomType) {
                final locale = _normalizeLocale(context.locale);
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
                        style: AppTypography.headingL(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).textTheme.titleMedium?.color ??
                                  Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (roomType.maxOccupancy != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'hotel.details.max_guests'.tr().replaceAll(
                              '{count}', roomType.maxOccupancy.toString()),
                          style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                        ),
                      ],
                      if (roomType.description != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          _stripHtmlTags(
                            _getLocalizedDescription(
                              context,
                              roomType.description!,
                            ),
                          ),
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

          // Room Photos
          if (roomPhotos.isNotEmpty || isLoadingRoomPhotos) ...[
            SizedBox(height: 24.h),
            _buildRoomPhotosSection(roomPhotos, isLoadingRoomPhotos),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomPhotosSection(
      List<HotelPhoto> photos, bool isLoading) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'hotel.details.room_photos'.tr(),
            style: AppTypography.headingL(context).copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ??
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (photos.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hotel.details.room_photos'.tr() + ' (${photos.length})',
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 1.0,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HotelPhotosGallery(
                      photoUrls: photos.map((p) => p.url).toList(),
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesTab(List<HotelPhoto> hotelPhotos, bool isLoadingPhotos,
      List<Facility> hotelFacilities, bool isLoadingFacilities,
      List<Equipment> hotelEquipment, bool isLoadingEquipment) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фотографии
          if (hotelPhotos.isNotEmpty || isLoadingPhotos) ...[
            Text(
              'hotel.details.photos'.tr(),
              style: AppTypography.headingL(context).copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Theme.of(context).colorScheme.onSurface,
              ),
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
                          color: Theme.of(context).cardColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).cardColor,
                          child: Icon(
                            Icons.image,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 24.h),
          ],

          // Hotel Equipment (Mehmonxona jihozlari - Imkoniyatlar)
          if (hotelEquipment.isNotEmpty || isLoadingEquipment) ...[
            _buildServicesSection('hotel.details.hotel_equipment'.tr(), hotelEquipment.cast<dynamic>(),
                isLoadingEquipment),
          ],
        ],
      ),
    );
  }

  /// Build bottom bar with total amount and Book Now button
  Widget? _buildBottomBar(Hotel hotel, List<RoomType> roomTypes) {
    // Calculate total amount based on selected room counts
    final totalData = _calculateTotalAmount(hotel);
    final totalAmount = totalData['amount'] as double;
    final currencyCode = totalData['currencyCode'] as String;
    final hasSelectedRooms = totalData['hasSelectedRooms'] as bool;
    
    // Always show bottom bar, even if amount is 0
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hotel.details.total_amount'.tr(),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    NumberFormat.simpleCurrency(name: currencyCode).format(totalAmount),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: hasSelectedRooms && totalAmount > 0
                  ? () async {
                      // Get selected options
                      List<HotelOption> selectedOptions = [];
                      if (hotel.options != null) {
                        for (final option in hotel.options!) {
                          final roomCount = _selectedRoomCounts[option.optionRefId] ?? 0;
                          if (roomCount > 0) {
                            selectedOptions.add(option);
                          }
                        }
                      }
                      
                      final hotelBloc = context.read<HotelBloc>();
                      // Tanlangan xona sonini topish
                      int totalRoomCount = 0;
                      if (selectedOptions.isNotEmpty) {
                        final selectedOption = selectedOptions.first;
                        totalRoomCount = _selectedRoomCounts[selectedOption.optionRefId] ?? 1;
                      } else if (_selectedOption != null) {
                        totalRoomCount = _selectedRoomCounts[_selectedOption!.optionRefId] ?? 1;
                      }
                      
                      // Login check qilish
                      final authService = AuthService.instance;
                      final user = await authService.fetchActiveUser();
                      if (!context.mounted) return;
                      
                      if (user == null) {
                        // Login qilmagan bo'lsa, dialog ko'rsatish
                        final shouldLogin = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text('avia.login_required.title'.tr()),
                            content: Text('avia.login_required.message'.tr()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                child: Text('avia.login_required.cancel'.tr()),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(dialogContext).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                ),
                                child: Text(
                                  'avia.login_required.login'.tr(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (!context.mounted) return;
                        
                        if (shouldLogin == true) {
                          // Login sahifasiga o'tish
                          await context.router.push(const LoginRoute());
                          if (!context.mounted) return;
                          
                          // Login qilingandan keyin tekshirish
                          final userAfterLogin = await authService.fetchActiveUser();
                          if (!context.mounted) return;
                          
                          if (userAfterLogin != null) {
                            // Login qilingan bo'lsa, hotel booking page'ga o'tish
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: hotelBloc,
                                  child: HotelBookingPage(
                                    hotel: hotel,
                                    selectedOption: selectedOptions.isNotEmpty 
                                        ? selectedOptions.first 
                                        : _selectedOption,
                                    roomCount: totalRoomCount > 0 ? totalRoomCount : 1,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        // Login qilingan bo'lsa, to'g'ridan-to'g'ri hotel booking page'ga o'tish
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: hotelBloc,
                              child: HotelBookingPage(
                                hotel: hotel,
                                selectedOption: selectedOptions.isNotEmpty 
                                    ? selectedOptions.first 
                                    : _selectedOption,
                                roomCount: totalRoomCount > 0 ? totalRoomCount : 1,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'hotel.details.book_now'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPlacesSection(
      List<NearbyPlace> places, bool isLoading) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).dividerColor
                : Colors.grey.shade300,
          ),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (places.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hotel.details.nearby_places'.tr() + ' (${places.length})',
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).dividerColor
                  : Colors.grey.shade300,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: places.length,
            separatorBuilder: (context, index) => Divider(height: 16.h),
            itemBuilder: (context, index) {
              final place = places[index];
              final locale = _normalizeLocale(context.locale);
              final displayName = place.getDisplayName(locale);
              final distance = place.distance;
              
              return Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (distance != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '${distance.toStringAsFixed(0)} m',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).dividerColor
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hotel.details.important_notes'.tr(),
                  style: AppTypography.headingL(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color ??
                        Theme.of(context).colorScheme.onSurface,
                  ),
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
                  style: AppTypography.headingL(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color ??
                        Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'hotel.details.age_policy_content'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(Hotel hotel) {
    // Default coordinates for Tashkent, Uzbekistan
    final defaultLatitude = 41.2995; // Tashkent latitude
    final defaultLongitude = 69.2401; // Tashkent longitude

    // Get coordinates from hotel model if available
    double hotelLatitude = hotel.latitude ?? defaultLatitude;
    double hotelLongitude = hotel.longitude ?? defaultLongitude;
    
    // If coordinates are not available, use default (Tashkent)
    if (hotel.latitude == null || hotel.longitude == null) {
      debugPrint('⚠️ HotelDetailsPage: Using default coordinates for hotel ${hotel.name}');
    } else {
      debugPrint('✅ HotelDetailsPage: Using coordinates from API: lat=${hotel.latitude}, lng=${hotel.longitude}');
    }

    Future<void> openMap() async {
      try {
        final query = '${hotel.name}, ${hotel.address}';
        final encodedQuery = Uri.encodeComponent(query);
        final url = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$encodedQuery');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          SnackbarHelper.showError(
              context, 'hotel.details.open_map_error'.tr());
        }
      } catch (_) {
        SnackbarHelper.showError(context, 'hotel.details.open_map_error'.tr());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hotel.details.location'.tr(),
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        // Google Map Widget with user location - tappable to open in external map
        Container(
          height: 300.h, // Increased height for better visibility
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              fit: StackFit.expand, // Ensure stack fills container
              children: [
                // Map widget - to'g'ridan-to'g'ri ko'rinadi va interaktiv
                HotelMapWidget(
                  hotelLatitude: hotelLatitude,
                  hotelLongitude: hotelLongitude,
                  hotelName: hotel.name,
                  hotelAddress: hotel.address,
                ),
                // Tap indicator badge va button - map'ga bosilish mumkinligini ko'rsatadi
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: openMap,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'hotel.details.open_map'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
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
      ],
    );
  }

  Widget _buildConditionItem(String text, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: 16.sp,
            color: isDark
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.getCardBg(
            Theme.of(context).brightness == Brightness.dark),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.getBorderColor(
                  Theme.of(context).brightness == Brightness.dark)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'hotel.details.room_type'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'hotel.details.guests'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'hotel.details.price'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'hotel.details.cancellation_policy'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'hotel.details.room'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomRow(
    HotelOption option,
    Hotel hotel,
    List<RoomType> roomTypes,
  ) {
    final price = option.price ?? 0.0;
    final currencyCode = (option.currency ?? 'UZS').toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find actual room name
    String roomName = 'Xona #${option.roomTypeId ?? ''}';
    String? mealPlan;
    int? maxGuests;
    
    if (roomTypes.isNotEmpty && option.roomTypeId != null) {
      try {
        final matching =
            roomTypes.firstWhere((rt) => rt.id == option.roomTypeId);
        // Normalize locale: en_US -> en, ru_RU -> ru, uz -> uz, uz_CYR -> uz_CYR
        final locale = _normalizeLocale(context.locale);
        roomName = matching.getDisplayName(locale);
        maxGuests = matching.maxOccupancy;
        
        // Debug: log room type info
        debugPrint('🔍 RoomType: id=${matching.id}, name=${matching.name}, names=${matching.names}, locale=$locale, displayName=$roomName');
      } catch (e) {
        debugPrint('⚠️ RoomType not found for roomTypeId=${option.roomTypeId}, error=$e');
        debugPrint('🔍 Available roomTypes: ${roomTypes.map((rt) => 'id=${rt.id}, name=${rt.name}').join(', ')}');
      }
    } else {
      debugPrint('⚠️ RoomTypes empty or roomTypeId is null: roomTypes.length=${roomTypes.length}, roomTypeId=${option.roomTypeId}');
    }
    
    // Get meal plan
    if (option.includedMealOptions != null && option.includedMealOptions!.isNotEmpty) {
      mealPlan = option.includedMealOptions!.join(', ');
    }
    
    // Get guests count from hotel or room type
    final guestsCount = maxGuests ?? (hotel.guests > 0 ? hotel.guests : 1);
    
    // Get cancellation policy text
    String cancellationText = '';
    if (option.cancellationPolicy != null) {
      final policy = option.cancellationPolicy!;
      // Try to get localized cancellation policy
      final locale = _normalizeLocale(context.locale);
      
      // cancellationPolicy is Map<String, dynamic>?
      // Handle Map format: {uz: '...', ru: '...', en: '...'}
      try {
        // Try normalized locale first, then fallback to common locales
        cancellationText = policy[locale]?.toString() ?? 
            policy['uz']?.toString() ?? 
            policy['ru']?.toString() ?? 
            policy['en']?.toString() ?? 
            '';
        cancellationText = _stripHtmlTags(cancellationText);
      } catch (_) {
        cancellationText = _stripHtmlTags(policy.toString());
      }
      
      if (cancellationText.isEmpty) {
        cancellationText = 'hotel.details.free_cancellation_2_days'.tr();
      }
    } else {
      cancellationText = 'hotel.details.free_cancellation_2_days'.tr();
    }
    
    final selectedRoomCount = _selectedRoomCounts[option.optionRefId] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.getCardBg(isDark),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.getBorderColor(isDark).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Type
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roomName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (mealPlan != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    mealPlan,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Guests
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 14.sp, color: Colors.blue),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    '$guestsCount ${'hotel.results.person'.tr()}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Price - shows total price based on selected room count
          Expanded(
            flex: 1,
            child: Builder(
              builder: (context) {
                int totalNights = hotel.checkOutDate.difference(hotel.checkInDate).inDays;
                if (totalNights <= 0) totalNights = 1;
                
                // Calculate price based on selected room count
                final totalPrice = selectedRoomCount > 0 
                    ? (price * selectedRoomCount * totalNights)
                    : price; // Show single room price if no selection
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        NumberFormat.simpleCurrency(name: currencyCode).format(totalPrice),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      selectedRoomCount > 0
                          ? 'hotel.details.total_amount'.tr()
                          : 'hotel.results.price_for_night'.tr(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
          // Cancellation Policy
          Expanded(
            flex: 2,
            child: Text(
              cancellationText,
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Room Count Dropdown
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.getBorderColor(isDark).withOpacity(0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedRoomCount,
                  isExpanded: true,
                  isDense: true,
                  items: List.generate(8, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        '$index ${'hotel.details.room'.tr()}',
                        style: TextStyle(fontSize: 10.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRoomCounts[option.optionRefId] = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Mobile card-based layout for room selection
  Widget _buildRoomCard(
    HotelOption option,
    Hotel hotel,
    List<RoomType> roomTypes,
  ) {
    final price = option.price ?? 0.0;
    final currencyCode = (option.currency ?? 'UZS').toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find actual room name
    String roomName = 'Xona #${option.roomTypeId ?? ''}';
    String? mealPlan;
    int? maxGuests;
    
    if (roomTypes.isNotEmpty && option.roomTypeId != null) {
      try {
        final matching =
            roomTypes.firstWhere((rt) => rt.id == option.roomTypeId);
        final locale = _normalizeLocale(context.locale);
        roomName = matching.getDisplayName(locale);
        maxGuests = matching.maxOccupancy;
      } catch (e) {
        debugPrint('⚠️ RoomType not found: $e');
      }
    }
    
    // Get meal plan
    if (option.includedMealOptions != null && option.includedMealOptions!.isNotEmpty) {
      mealPlan = option.includedMealOptions!.join(', ');
    }
    
    // Get guests count
    final guestsCount = maxGuests ?? (hotel.guests > 0 ? hotel.guests : 1);
    
    // Get cancellation policy text
    String cancellationText = '';
    if (option.cancellationPolicy != null) {
      final policy = option.cancellationPolicy!;
      final locale = _normalizeLocale(context.locale);
      try {
        cancellationText = policy[locale]?.toString() ?? 
            policy['uz']?.toString() ?? 
            policy['ru']?.toString() ?? 
            policy['en']?.toString() ?? 
            '';
        cancellationText = _stripHtmlTags(cancellationText);
      } catch (_) {
        cancellationText = _stripHtmlTags(policy.toString());
      }
      
      if (cancellationText.isEmpty) {
        cancellationText = 'hotel.details.free_cancellation_2_days'.tr();
      }
    } else {
      cancellationText = 'hotel.details.free_cancellation_2_days'.tr();
    }
    
    final selectedRoomCount = _selectedRoomCounts[option.optionRefId] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.getCardBg(isDark),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.getBorderColor(isDark).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Type
          Text(
            roomName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (mealPlan != null) ...[
            SizedBox(height: 4.h),
            Text(
              mealPlan,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          // Guests and Price Row
          Row(
            children: [
              // Guests
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 4.w),
                  Text(
                    '$guestsCount ${'hotel.results.person'.tr()}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Price - shows total price based on selected room count
              Builder(
                builder: (context) {
                  int totalNights = hotel.checkOutDate.difference(hotel.checkInDate).inDays;
                  if (totalNights <= 0) totalNights = 1;
                  
                  // Calculate price based on selected room count
                  final totalPrice = selectedRoomCount > 0 
                      ? (price * selectedRoomCount * totalNights)
                      : price; // Show single room price if no selection
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.simpleCurrency(name: currencyCode).format(totalPrice),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        selectedRoomCount > 0
                            ? 'hotel.details.total_amount'.tr()
                            : 'hotel.results.price_for_night'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Cancellation Policy
          Row(
            children: [
              Icon(Icons.info_outline, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  cancellationText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Room Count and Select Button Row
          Row(
            children: [
              // Room Count Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.getBorderColor(isDark).withOpacity(0.5),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedRoomCount,
                      isExpanded: true,
                      items: List.generate(8, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            '$index ${'hotel.details.room'.tr()}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRoomCounts[option.optionRefId] = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
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
        Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.3,
            size.height * 0.4),
        paint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.5, size.width * 0.25,
            size.height * 0.3),
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
        Rect.fromLTWH(size.width * 0.05, size.height * 0.45, 60.w, 40.h),
        paint);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.1, 80.w, 50.h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
