import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<String> getCurrentLocationString() async {
    try {
      // Return fallback quickly on Web if geolocator is blocked/unsupported
      if (kIsWeb) {
        return 'User Location (Web Browser GPS)';
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location services disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permission permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 4));

      return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)} (GPS Live)';
    } catch (e) {
      return 'User Location (GPS Unavailable)';
    }
  }
}