import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baseqat/core/database/hive_service.dart';

class LocationService {
  static const String _lastPositionKey = 'last_position';
  static const String _lastPositionTimestampKey = 'last_position_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 1);

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

  static Position? getCachedPosition() {
    try {
      final box = Hive.box(HiveService.locationCacheBox);
      final cachedData = box.get(_lastPositionKey);
      final timestamp = box.get(_lastPositionTimestampKey);

      if (cachedData != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        // Check if cache is still valid
        if (now.difference(cacheTime) < _cacheValidDuration) {
          return Position(
            latitude: cachedData['latitude'],
            longitude: cachedData['longitude'],
            timestamp: cacheTime,
            accuracy: cachedData['accuracy'] ?? 0.0,
            altitude: cachedData['altitude'] ?? 0.0,
            heading: cachedData['heading'] ?? 0.0,
            speed: cachedData['speed'] ?? 0.0,
            speedAccuracy: cachedData['speedAccuracy'] ?? 0.0,
            altitudeAccuracy: cachedData['altitudeAccuracy'] ?? 0.0,
            headingAccuracy: cachedData['headingAccuracy'] ?? 0.0,
          );
        }
      }
    } catch (e) {
      print('[LocationService] Error reading cached position: $e');
    }
    return null;
  }

  static Future<void> _cachePosition(Position position) async {
    try {
      final box = Hive.box(HiveService.locationCacheBox);
      await box.put(_lastPositionKey, {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
        'altitudeAccuracy': position.altitudeAccuracy,
        'headingAccuracy': position.headingAccuracy,
      });
      await box.put(_lastPositionTimestampKey, position.timestamp.millisecondsSinceEpoch);
      print('[LocationService] Position cached successfully');
    } catch (e) {
      print('[LocationService] Error caching position: $e');
    }
  }

  static Future<Position?> getCurrentPosition() async {
    final cachedPosition = getCachedPosition();

    // 1) Services enabled?
    final enabled = await _servicesEnabledWebAware();
    if (!enabled) {
      print('[LocationService] Location services disabled, returning cached position');
      return cachedPosition;
    }

    // 2) Permission flow
    final perm = await _ensurePermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      print('[LocationService] Location permission denied, returning cached position');
      return cachedPosition;
    }

    // 3) Get position (browser may still prompt the user here)
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // On web, a moderate timeout prevents hanging when users ignore the prompt
        timeLimit: const Duration(seconds: 12),
      );

      await _cachePosition(position);

      return position;
    } catch (e) {
      print('[LocationService] Error getting current position: $e, returning cached position');
      return cachedPosition;
    }
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
