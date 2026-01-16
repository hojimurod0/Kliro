import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/hotel.dart';
import '../../../../core/constants/app_colors.dart';

class HotelMapPage extends StatefulWidget {
  final List<Hotel> hotels;

  const HotelMapPage({Key? key, required this.hotels}) : super(key: key);

  @override
  State<HotelMapPage> createState() => _HotelMapPageState();
}

class _HotelMapPageState extends State<HotelMapPage> {
  final MapController _mapController = MapController();
  Hotel? _selected;

  LatLng _getInitialCenter() {
    final withCoords = widget.hotels.where((h) => h.latitude != null && h.longitude != null).toList();
    if (withCoords.isNotEmpty) {
      return LatLng(withCoords.first.latitude!, withCoords.first.longitude!);
    }
    // Default to Tashkent if no coords
    return const LatLng(41.2995, 69.2401);
  }

  List<Marker> _buildMarkers() {
    return widget.hotels
        .where((h) => h.latitude != null && h.longitude != null)
        .map<Marker>((h) => Marker(
              width: 32,
              height: 32,
              point: LatLng(h.latitude!, h.longitude!),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selected = h);
                },
                child: const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final center = _getInitialCenter();
    final markers = _buildMarkers();

    return Scaffold(
      appBar: AppBar(
        title: Text('hotel.filter.view_on_map'.tr()),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom | InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uz.kliro.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          if (_selected != null)
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 16.h,
              child: _SelectedHotelCard(hotel: _selected!),
            ),
        ],
      ),
    );
  }
}

class _SelectedHotelCard extends StatelessWidget {
  final Hotel hotel;
  const _SelectedHotelCard({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12.r),
      color: AppColors.getCardBg(Theme.of(context).brightness == Brightness.dark),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hotel.name,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              hotel.address,
              style: TextStyle(fontSize: 12.sp, color: Theme.of(context).textTheme.bodySmall?.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            if (hotel.latitude != null && hotel.longitude != null)
              Text(
                'lat: ${hotel.latitude?.toStringAsFixed(6)}, lng: ${hotel.longitude?.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 11.sp, color: AppColors.grayText),
              ),
          ],
        ),
      ),
    );
  }
}
