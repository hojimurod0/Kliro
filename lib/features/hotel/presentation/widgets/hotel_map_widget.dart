import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Location service import olib tashlandi - hotel funksiyasi hozir ishlamayapti
import '../../../../core/constants/app_colors.dart';

/// Google Map widget that shows hotel location and user location
class HotelMapWidget extends StatefulWidget {
  /// Hotel latitude
  final double hotelLatitude;
  
  /// Hotel longitude
  final double hotelLongitude;
  
  /// Hotel name (for marker info)
  final String hotelName;
  
  /// Hotel address (for marker info)
  final String hotelAddress;

  const HotelMapWidget({
    Key? key,
    required this.hotelLatitude,
    required this.hotelLongitude,
    required this.hotelName,
    required this.hotelAddress,
  }) : super(key: key);

  @override
  State<HotelMapWidget> createState() => _HotelMapWidgetState();
}

class _HotelMapWidgetState extends State<HotelMapWidget> {
  // _hasLocationPermission field olib tashlandi - hotel funksiyasi hozir ishlamayapti

  @override
  void initState() {
    super.initState();
    // Always use fallback UI to avoid crash
    // Google Maps requires API key which is not configured
    // We'll show fallback UI with hotel info and "Open in Maps" button
    _initializeMap();
  }

  /// Initialize map and request location permission
  Future<void> _initializeMap() async {
    // Comment qilingan - location permission hozir kerak emas
    // Hotel funksiyasi hozir ishlamayapti
    /*
    // Note: Google Maps is disabled to avoid crash (API key not configured)
    // We only initialize location permission for potential future use
    _hasLocationPermission = await LocationService.instance.hasLocationPermission();
    
    // If no permission, request it (for future use)
    if (!_hasLocationPermission) {
      _hasLocationPermission = await LocationService.instance.requestLocationPermission();
    }
    */
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand, // Ensure stack fills parent
        children: [
          // Background color while map loads
          Container(
            color: Colors.grey[200], // Light grey background
            child: Center(
              child: Icon(
                Icons.map,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
          ),
          // Always show fallback UI to avoid crash
          // Google Maps requires API key which is not configured in AndroidManifest.xml
          // When API key is added, this can be changed to show GoogleMap widget
          Positioned.fill(
            child: _buildFallbackMap(context),
          ),

        ],
      ),
    );
  }

  /// Build fallback UI with static map image
  /// Uses Google Maps Static API to show map image (no API key required for basic usage)
  Widget _buildFallbackMap(BuildContext context) {
    // Generate Google Maps Static API URL
    // Note: This works without API key for basic usage (with watermark)
    final staticMapUrl = 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=${widget.hotelLatitude},${widget.hotelLongitude}'
        '&zoom=15'
        '&size=600x300'
        '&markers=color:red%7C${widget.hotelLatitude},${widget.hotelLongitude}'
        '&maptype=roadmap'
        '&scale=2';

    return GestureDetector(
      onTap: () async {
        // Open in external map app when tapped
        try {
          final query = '${widget.hotelName}, ${widget.hotelAddress}';
          final encodedQuery = Uri.encodeComponent(query);
          final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$encodedQuery');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error opening map: $e');
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static map image as background
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: staticMapUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800, // Optimize memory usage
              memCacheHeight: 600,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              errorWidget: (context, url, error) {
                // If static map fails, show simple fallback UI
                return _buildSimpleFallback(context);
              },
            ),
          ),
          // Overlay with hotel info and button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotelName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.hotelAddress.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      widget.hotelAddress,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final query = '${widget.hotelName}, ${widget.hotelAddress}';
                        final encodedQuery = Uri.encodeComponent(query);
                        final url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$encodedQuery');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        debugPrint('Error opening map: $e');
                      }
                    },
                    icon: Icon(Icons.open_in_new, size: 16.sp),
                    label: Text('Open in Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple fallback UI if static map image fails to load
  Widget _buildSimpleFallback(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            widget.hotelName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          if (widget.hotelAddress.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                widget.hotelAddress,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final query = '${widget.hotelName}, ${widget.hotelAddress}';
                final encodedQuery = Uri.encodeComponent(query);
                final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$encodedQuery');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              } catch (e) {
                debugPrint('Error opening map: $e');
              }
            },
            icon: Icon(Icons.open_in_new, size: 18.sp),
            label: Text('Open in Maps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

