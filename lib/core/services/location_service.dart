import 'package:geolocator/geolocator.dart';
import '../config/app_config.dart';

class LocationService {
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    // Save permission status
    await AppConfig.setLocationPermissionGranted(true);
    return true;
  }
  
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if permission is already granted
      if (!AppConfig.isLocationPermissionGranted()) {
        final hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          return null;
        }
      }
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      // If getting current location fails, try last known position
      try {
        final position = await Geolocator.getLastKnownPosition();
        return position;
      } catch (e) {
        return null;
      }
    }
  }
  
  Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
  
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
  
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}