import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  HotelOption? _selectedOption;
  
  // State cache - oldingi state'larni saqlash
  List<HotelPhoto> _cachedPhotos = [];
  List<Facility> _cachedFacilities = [];
  List<NearbyPlace> _cachedNearbyPlaces = [];
  List<RoomType> _cachedRoomTypes = [];
  List<ServiceInRoom> _cachedServicesInRoom = [];
  
  bool _isLoadingPhotos = false;
  bool _isLoadingFacilities = false;
  bool _isLoadingNearbyPlaces = false;
  bool _isLoadingRoomTypes = false;
  bool _isLoadingServices = false;

  @override
  void initState() {
    super.initState();
    // Select first option by default
    if (widget.hotel.options != null && widget.hotel.options!.isNotEmpty) {
      _selectedOption = widget.hotel.options!.first;
    }
    // Load all hotel data via Bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelId = widget.hotel.hotelId;
      context.read<HotelBloc>().add(GetHotelPhotosRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelFacilitiesRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelNearbyPlacesRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelRoomTypesRequested(hotelId));
      context.read<HotelBloc>().add(GetHotelServicesInRoomRequested(hotelId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    return BlocListener<HotelBloc, HotelState>(
      listener: (context, state) {
        // Update cache when new state arrives
        if (state is HotelPhotosSuccess) {
          setState(() {
            _cachedPhotos = state.photos;
            _isLoadingPhotos = false;
          });
        } else if (state is HotelPhotosLoading) {
          setState(() {
            _isLoadingPhotos = true;
          });
        } else if (state is HotelPhotosFailure) {
          setState(() {
            _isLoadingPhotos = false;
          });
        }

        if (state is HotelHotelFacilitiesSuccess) {
          setState(() {
            _cachedFacilities = state.facilities;
            _isLoadingFacilities = false;
          });
        } else if (state is HotelHotelFacilitiesLoading) {
          setState(() {
            _isLoadingFacilities = true;
          });
        } else if (state is HotelHotelFacilitiesFailure) {
          setState(() {
            _isLoadingFacilities = false;
          });
        }

        if (state is HotelNearbyPlacesSuccess) {
          setState(() {
            _cachedNearbyPlaces = state.places;
            _isLoadingNearbyPlaces = false;
          });
        } else if (state is HotelNearbyPlacesLoading) {
          setState(() {
            _isLoadingNearbyPlaces = true;
          });
        } else if (state is HotelNearbyPlacesFailure) {
          setState(() {
            _isLoadingNearbyPlaces = false;
          });
        }

        if (state is HotelRoomTypesSuccess) {
          setState(() {
            _cachedRoomTypes = state.roomTypes;
            _isLoadingRoomTypes = false;
          });
        } else if (state is HotelRoomTypesLoading) {
          setState(() {
            _isLoadingRoomTypes = true;
          });
        } else if (state is HotelRoomTypesFailure) {
          setState(() {
            _isLoadingRoomTypes = false;
          });
        }

        if (state is HotelHotelServicesInRoomSuccess) {
          setState(() {
            _cachedServicesInRoom = state.services;
            _isLoadingServices = false;
          });
        } else if (state is HotelHotelServicesInRoomLoading) {
          setState(() {
            _isLoadingServices = true;
          });
        } else if (state is HotelHotelServicesInRoomFailure) {
          setState(() {
            _isLoadingServices = false;
          });
        }
      },
      child: BlocBuilder<HotelBloc, HotelState>(
        builder: (context, state) {
          // Use cached data
          final hotelPhotos = _cachedPhotos;
          final hotelFacilities = _cachedFacilities;
          final nearbyPlaces = _cachedNearbyPlaces;
          final roomTypes = _cachedRoomTypes;
          final servicesInRoom = _cachedServicesInRoom;

          final isLoadingPhotos = _isLoadingPhotos;
          final isLoadingFacilities = _isLoadingFacilities;
          final isLoadingNearbyPlaces = _isLoadingNearbyPlaces;
          final isLoadingRoomTypes = _isLoadingRoomTypes;
          final isLoadingServices = _isLoadingServices;

        return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Show photo gallery
                      final photos = hotelPhotos.isNotEmpty
                          ? hotelPhotos.map((p) => p.url).toList()
                          : [hotel.imageUrl ?? 'https://via.placeholder.com/400x300'];
                      if (photos.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HotelPhotosGallery(
                              photoUrls: photos,
                              initialIndex: 0,
                            ),
                          ),
                        );
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: hotel.imageUrl ?? 'https://via.placeholder.com/400x300',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26, // Top status bar area
                          Colors.transparent,
                          Colors.black54, // Bottom text readability
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            automaticallyImplyLeading: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: TextStyle(
                              fontSize: 24.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16.sp),
                            SizedBox(width: 4.w),
                            Text(
                              '${hotel.rating ?? 4.5}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.blue, size: 20),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          hotel.address,
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Description
                  Text(
                    'hotel.details.description'.tr(),
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    hotel.description ??
                        'Bu zamonaviy mehmonxona Toshkent shahrining markazida joylashgan bo\'lib, barcha qulayliklarga ega. Mehmonlar uchun bepul Wi-Fi, basseyn va fitness markazi mavjud.',
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                  SizedBox(height: 24.h),

                  // Facilities (from API)
                  if (hotelFacilities.isNotEmpty || isLoadingFacilities)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.details.facilities'.tr(),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        if (isLoadingFacilities)
                          const Center(child: CircularProgressIndicator())
                        else
                          Wrap(
                            spacing: 16.w,
                            runSpacing: 16.h,
                            children: hotelFacilities.map((facility) {
                              IconData icon = Icons.check_circle;
                              final name = facility.name.toLowerCase();
                              if (name.contains('wifi') || name.contains('wi-fi')) {
                                icon = Icons.wifi;
                              } else if (name.contains('pool') || name.contains('basseyn')) {
                                icon = Icons.pool;
                              } else if (name.contains('gym') || name.contains('fitness') || name.contains('sport')) {
                                icon = Icons.fitness_center;
                              } else if (name.contains('restaurant') || name.contains('restoran')) {
                                icon = Icons.restaurant;
                              } else if (name.contains('parking') || name.contains('turargoh')) {
                                icon = Icons.local_parking;
                              } else if (name.contains('spa')) {
                                icon = Icons.spa;
                              } else if (name.contains('breakfast') || name.contains('nonushta')) {
                                icon = Icons.breakfast_dining;
                              } else if (name.contains('bar')) {
                                icon = Icons.local_bar;
                              } else if (name.contains('air') || name.contains('conditioning')) {
                                icon = Icons.ac_unit;
                              } else if (name.contains('tv') || name.contains('televizor')) {
                                icon = Icons.tv;
                              }
                              return _buildAmenityItem(icon, facility.name);
                            }).toList(),
                          ),
                        SizedBox(height: 24.h),
                      ],
                    ),

                  // Legacy Amenities (fallback)
                  if (hotelFacilities.isEmpty && !isLoadingFacilities && hotel.amenities != null && hotel.amenities!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.details.amenities'.tr(),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        Wrap(
                          spacing: 16.w,
                          runSpacing: 16.h,
                          children: hotel.amenities!.map((amenity) {
                            IconData icon = Icons.check_circle;
                            if (amenity.toLowerCase().contains('wifi') ||
                                amenity.toLowerCase().contains('wi-fi')) {
                              icon = Icons.wifi;
                            } else if (amenity.toLowerCase().contains('pool') ||
                                amenity.toLowerCase().contains('basseyn')) {
                              icon = Icons.pool;
                            } else if (amenity.toLowerCase().contains('gym') ||
                                amenity.toLowerCase().contains('fitness') ||
                                amenity.toLowerCase().contains('sport')) {
                              icon = Icons.fitness_center;
                            } else if (amenity.toLowerCase().contains('restaurant') ||
                                amenity.toLowerCase().contains('restoran')) {
                              icon = Icons.restaurant;
                            } else if (amenity.toLowerCase().contains('parking') ||
                                amenity.toLowerCase().contains('turargoh')) {
                              icon = Icons.local_parking;
                            } else if (amenity.toLowerCase().contains('spa')) {
                              icon = Icons.spa;
                            } else if (amenity.toLowerCase().contains('breakfast') ||
                                amenity.toLowerCase().contains('nonushta')) {
                              icon = Icons.breakfast_dining;
                            } else if (amenity.toLowerCase().contains('bar')) {
                              icon = Icons.local_bar;
                            } else if (amenity.toLowerCase().contains('air') ||
                                amenity.toLowerCase().contains('conditioning')) {
                              icon = Icons.ac_unit;
                            } else if (amenity.toLowerCase().contains('tv') ||
                                amenity.toLowerCase().contains('televizor')) {
                              icon = Icons.tv;
                            }
                            return _buildAmenityItem(icon, amenity);
                          }).toList(),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  SizedBox(height: 24.h),

                  // Photos Gallery (if available)
                  if (hotelPhotos.isNotEmpty || isLoadingPhotos)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.details.photos'.tr(),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        if (isLoadingPhotos)
                          const Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            height: 120.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: hotelPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = hotelPhotos[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => HotelPhotosGallery(
                                          photoUrls: hotelPhotos
                                              .map((p) => p.url)
                                              .toList(),
                                          initialIndex: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 120.w,
                                    margin: EdgeInsets.only(right: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: CachedNetworkImage(
                                        imageUrl: photo.thumbnailUrl ?? photo.url,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: 24.h),
                      ],
                    ),

                  // Nearby Places
                  if (nearbyPlaces.isNotEmpty || isLoadingNearbyPlaces)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.details.nearby_places'.tr(),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        if (isLoadingNearbyPlaces)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...nearbyPlaces.map((place) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.blue, size: 20.sp),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.name,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        if (place.distance != null)
                                          Text(
                                            '${(place.distance! / 1000).toStringAsFixed(1)} km',
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        SizedBox(height: 24.h),
                      ],
                    ),

                  // Services In Room
                  if (servicesInRoom.isNotEmpty || isLoadingServices)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.details.services_in_room'.tr(),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        if (isLoadingServices)
                          const Center(child: CircularProgressIndicator())
                        else
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: servicesInRoom.map((service) {
                              return Chip(
                                avatar: Icon(Icons.check, size: 16.sp),
                                label: Text(service.name, style: TextStyle(fontSize: 12.sp)),
                              );
                            }).toList(),
                          ),
                        SizedBox(height: 24.h),
                      ],
                    ),

                  // Room Types (from API)
                  if (roomTypes.isNotEmpty || isLoadingRoomTypes)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hotel.details.room_types'.tr(),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.h),
                        if (isLoadingRoomTypes)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...roomTypes.map((roomType) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
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
                                    roomType.name,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (roomType.maxOccupancy != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Max ${roomType.maxOccupancy} guests',
                                      style: TextStyle(
                                          fontSize: 12.sp, color: Colors.grey),
                                    ),
                                  ],
                                  if (roomType.description != null) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      roomType.description!,
                                      style: TextStyle(
                                          fontSize: 12.sp, color: Colors.grey[600]),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        SizedBox(height: 24.h),
                      ],
                    ),

                  // Rooms/Options
                  Text(
                    'hotel.details.rooms'.tr(),
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  // Show options if available
                  if (hotel.options != null && hotel.options!.isNotEmpty)
                    ...hotel.options!.asMap().entries.map((entry) {
                      final option = entry.value;
                      final isSelected = _selectedOption?.optionRefId == option.optionRefId;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildOptionItem(
                          context,
                          option,
                          isSelected,
                          onTap: () {
                            setState(() {
                              _selectedOption = option;
                            });
                          },
                        ),
                      );
                    }).toList()
                  else
                    // Fallback to default rooms if no options
                    Column(
                      children: [
                        _buildRoomItem(
                            context, 'Deluxe Room', 1200000, '25m²', true),
                        SizedBox(height: 12.h),
                        _buildRoomItem(
                            context, 'Executive Suite', 2400000, '45m²', false),
                      ],
                    ),
                  SizedBox(height: 100.h), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jami summa:',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                  Text(
                    '${NumberFormat.currency(locale: 'uz_UZ', symbol: _selectedOption?.currency == 'uzs' ? 'so\'m' : _selectedOption?.currency?.toUpperCase() ?? 'so\'m', decimalDigits: 0).format(_selectedOption?.price ?? hotel.price ?? 0)}',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
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
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'hotel.details.book_now'.tr(),
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
        },
      ),
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 24.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    HotelOption option,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    final price = option.price ?? 0.0;
    final currency = option.currency ?? 'uzs';
    final mealOptions = option.includedMealOptions?.join(', ') ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
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
                      Text(
                        'Room Type #${option.roomTypeId ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      if (mealOptions.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Meal: $mealOptions',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12.sp),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat.currency(locale: 'uz_UZ', symbol: currency == 'uzs' ? 'so\'m' : currency.toUpperCase(), decimalDigits: 0).format(price)}',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    if (option.cancellationPolicy != null)
                      Text(
                        'Cancellable',
                        style: TextStyle(
                            color: Colors.green, fontSize: 11.sp),
                      ),
                  ],
                ),
              ],
            ),
            if (option.priceBreakdown != null) ...[
              SizedBox(height: 8.h),
              Divider(),
              SizedBox(height: 8.h),
              Text(
                'Price Breakdown:',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
              ),
              SizedBox(height: 4.h),
              ...option.priceBreakdown!.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.toString(),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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

  Widget _buildRoomItem(BuildContext context, String title, double price,
      String size, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                size,
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
            ],
          ),
          Text(
            '${NumberFormat.currency(locale: 'uz_UZ', symbol: 'so\'m', decimalDigits: 0).format(price)}',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
