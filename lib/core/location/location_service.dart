import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> _servicesEnabledWebAware() async {
    // On web, this usually reflects browser-level availability.
    // On mobile, it's OS location services.
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> _ensurePermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      // Request must be triggered by a user gesture on web for best UX.
      perm = await Geolocator.requestPermission();
    }
    return perm;
  }

  static Future<Position?> getCurrentPosition() async {
    // 1) Services enabled?
    final enabled = await _servicesEnabledWebAware();
    if (!enabled) return null;

    // 2) Permission flow
    final perm = await _ensurePermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }

    // 3) Get position (browser may still prompt the user here)
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // On web, a moderate timeout prevents hanging when users ignore the prompt
      timeLimit: const Duration(seconds: 12),
    );
  }

  static double distanceKm({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    final meters = Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    );
    return meters / 1000.0;
  }
}
