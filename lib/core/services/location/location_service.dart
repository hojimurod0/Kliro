import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Location service for handling location permissions and getting user location
class LocationService {
  LocationService._();
  
  static final LocationService instance = LocationService._();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Request location permission from user
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        // Location services are disabled, ask user to enable them
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          // Permission denied
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, user needs to enable in settings
        return false;
      }

      // Permission granted
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current user location
  /// Returns Position if successful, null otherwise
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if permission is granted
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      // Handle timeout or other errors
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings so user can enable location permission
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }
}

