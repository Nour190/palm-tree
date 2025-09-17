import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationTab extends StatefulWidget {
  const LocationTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distanceLabel,
    required this.destinationLabel,
    this.addressLine,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.mapImage, // deprecated (kept for API compatibility)
    this.onStartNavigation,
  });

  final String title;
  final String subtitle;
  final String distanceLabel;
  final String destinationLabel;

  final String? addressLine;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  /// Deprecated: replaced by live OSM map
  final String? mapImage;

  final VoidCallback? onStartNavigation;

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  GeoPoint? _dest;
  bool _mapReady = false;

  // Enhanced live tracking
  StreamSubscription<Position>? _posSub;
  bool _tracking = false;
  GeoPoint? _lastMyPoint;
  GeoPoint? _currentPosition;
  double _currentSpeed = 0.0;
  double _distanceToDestination = 0.0;
  String _estimatedTime = '--';
  bool _isNavigating = false;

  // Tracking settings
  Timer? _trackingTimer;
  int _trackingDuration = 0;
  final List<GeoPoint> _trackingPath = [];

  // Animation controllers for smooth UI updates
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _dest = (widget.latitude != null && widget.longitude != null)
        ? GeoPoint(latitude: widget.latitude!, longitude: widget.longitude!)
        : null;

    _mapController = MapController(
      initPosition:
          _dest ?? GeoPoint(latitude: 24.7136, longitude: 46.6753), // fallback
      areaLimit: const BoundingBox.world(),
    );

    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Calculate initial distance if destination is available
    if (_dest != null) {
      _calculateInitialDistance();
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _trackingTimer?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---- Enhanced Location & Distance Calculations -------------------------

  Future<void> _calculateInitialDistance() async {
    if (_dest == null) return;
    try {
      final ok = await _ensureLocationPermissions();
      if (!ok) return;

      final position = await Geolocator.getCurrentPosition();
      final currentPoint = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final distance = Geolocator.distanceBetween(
        currentPoint.latitude,
        currentPoint.longitude,
        _dest!.latitude,
        _dest!.longitude,
      );

      setState(() {
        _distanceToDestination = distance;
        _currentPosition = currentPoint;
      });
    } catch (_) {
      // ignore
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  String _calculateETA(double distanceInMeters, double speedInMps) {
    if (speedInMps <= 0 || distanceInMeters <= 0) return '--';

    final timeInSeconds = distanceInMeters / speedInMps;
    final minutes = (timeInSeconds / 60).round();

    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  // ---- Permissions & helpers -------------------------------------------------

  Future<bool> _ensureLocationPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return false;
    }
    return true;
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
          'Please enable location services to use navigation features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is required for navigation features. Please grant permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _centerOnMe({double? zoom}) async {
    try {
      final ok = await _ensureLocationPermissions();
      if (!ok) return;
      await _mapController.currentLocation();
      if (zoom != null) {
        await _mapController.setZoom(zoomLevel: zoom);
      }
      // cache last point (best-effort)
      try {
        final me = await _mapController.myLocation();
        _lastMyPoint = me;
        _currentPosition = me;
      } catch (_) {
        /* ignore */
      }
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> _addDestinationMarker() async {
    if (_dest == null) return;
    await _mapController.addMarker(
      _dest!,
      markerIcon: const MarkerIcon(
        icon: Icon(Icons.location_pin, color: Colors.red, size: 64),
      ),
    );
  }

  Future<void> _drawRoadFromMe() async {
    if (_dest == null) return;
    try {
      final ok = await _ensureLocationPermissions();
      if (!ok) throw Exception('perm');

      final me = await _mapController.myLocation();
      _lastMyPoint = me;
      _currentPosition = me;

      await _mapController.drawRoad(
        me,
        _dest!,
        roadType: RoadType.car,
        roadOption: const RoadOption(
          roadWidth: 10,
          roadColor: Colors.blueAccent,
          zoomInto: true,
        ),
      );

      // Calculate distance after drawing route
      final distance = Geolocator.distanceBetween(
        me.latitude,
        me.longitude,
        _dest!.latitude,
        _dest!.longitude,
      );
      setState(() {
        _distanceToDestination = distance;
      });
    } catch (_) {
      // If we can't get "me", at least zoom to destination
      await _mapController.goToLocation(_dest!);
      await _mapController.setZoom(zoomLevel: 15);
    }
  }

  // ---- Enhanced Live tracking -----------------------------------------------

  Future<void> _startEnhancedTracking() async {
    if (_tracking) return;
    final ok = await _ensureLocationPermissions();
    if (!ok) return;

    setState(() {
      _tracking = true;
      _isNavigating = true;
      _trackingDuration = 0;
    });

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    // First center once
    await _centerOnMe(zoom: 16);

    // Start tracking timer
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _trackingDuration++;
        });
      }
    });

    // Subscribe to high-accuracy location updates
    _posSub?.cancel();
    _posSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5, // Update every 5 meters
            timeLimit: Duration(seconds: 5),
          ),
        ).listen((pos) async {
          if (!mounted) return;

          final newPoint = GeoPoint(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );

          // Calculate speed and distance
          double speed = pos.speed; // m/s
          if (_currentPosition != null) {
            final distance = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              newPoint.latitude,
              newPoint.longitude,
            );

            // Add to tracking path
            _trackingPath.add(newPoint);
            if (_trackingPath.length > 100) {
              _trackingPath.removeAt(0); // Keep only recent 100 points
            }
          }

          _lastMyPoint = newPoint;
          _currentPosition = newPoint;

          // Calculate distance to destination
          double distanceToDestination = 0;
          if (_dest != null) {
            distanceToDestination = Geolocator.distanceBetween(
              newPoint.latitude,
              newPoint.longitude,
              _dest!.latitude,
              _dest!.longitude,
            );
          }

          setState(() {
            _currentSpeed = speed;
            _distanceToDestination = distanceToDestination;
            _estimatedTime = _calculateETA(distanceToDestination, speed);
          });

          // Smooth camera follow with adaptive zoom
          try {
            await _mapController.goToLocation(newPoint);

            // Adjust zoom based on speed - closer when slower, further when faster
            double targetZoom = 18.0;
            if (speed > 2) targetZoom = 17.0; // Walking
            if (speed > 10) targetZoom = 16.0; // Cycling
            if (speed > 25) targetZoom = 15.0; // Driving

            await _mapController.setZoom(zoomLevel: targetZoom);
          } catch (_) {
            // Ignore zoom errors
          }

          // Redraw route if destination exists
          if (_dest != null && _tracking) {
            try {
              await _mapController.drawRoad(
                newPoint,
                _dest!,
                roadType: RoadType.car,
                roadOption: const RoadOption(
                  roadWidth: 8,
                  roadColor: Colors.green,
                  zoomInto: false,
                ),
              );
            } catch (_) {
              /* ignore transient errors */
            }
          }
        });
  }

  void _stopTracking() {
    _posSub?.cancel();
    _posSub = null;
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _pulseController.stop();

    setState(() {
      _tracking = false;
      _isNavigating = false;
      _trackingDuration = 0;
      _currentSpeed = 0.0;
    });

    // Clear tracking path
    _trackingPath.clear();
  }

  String _formatTrackingTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  // ---- Enhanced UI -----------------------------------------------------------

  Widget _buildTrackingInfo() {
    if (!_tracking) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: const Icon(
                      Icons.radio_button_checked,
                      color: Colors.green,
                      size: 20,
                    ),
                  );
                },
              ),
              SizedBox(width: 8.h),
              Text(
                'Live Tracking Active',
                style: TextStyleHelper.instance.title16MediumInter.copyWith(
                  color: Colors.green.shade700,
                ),
              ),
              const Spacer(),
              Text(
                _formatTrackingTime(_trackingDuration),
                style: TextStyleHelper.instance.title16MediumInter.copyWith(
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          if (_currentSpeed > 0 || _distanceToDestination > 0) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (_currentSpeed > 0)
                  Column(
                    children: [
                      Text(
                        '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                        style: TextStyleHelper.instance.headline24BoldInter
                            .copyWith(color: AppColor.gray900),
                      ),
                      Text(
                        'Speed',
                        style: TextStyleHelper.instance.body12LightInter
                            .copyWith(color: AppColor.gray400),
                      ),
                    ],
                  ),
                if (_distanceToDestination > 0)
                  Column(
                    children: [
                      Text(
                        _formatDistance(_distanceToDestination),
                        style: TextStyleHelper.instance.headline24BoldInter
                            .copyWith(color: AppColor.gray900),
                      ),
                      Text(
                        'Distance',
                        style: TextStyleHelper.instance.body12LightInter
                            .copyWith(color: AppColor.gray400),
                      ),
                    ],
                  ),
                if (_estimatedTime != '--')
                  Column(
                    children: [
                      Text(
                        _estimatedTime,
                        style: TextStyleHelper.instance.headline24BoldInter
                            .copyWith(color: AppColor.gray900),
                      ),
                      Text(
                        'ETA',
                        style: TextStyleHelper.instance.body12LightInter
                            .copyWith(color: AppColor.gray400),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = SizeUtils.width;
    final bool isDesktop = w >= 1200;
    final bool isTablet = w >= 840 && w < 1200;
    final bool isMobile = w < 840;

    final double horizontalPadding = isDesktop
        ? 64.h
        : (isTablet ? 32.h : 16.h);
    final double sectionGap = 16.h;
    final double mapHeight = isDesktop ? 480.h : (isTablet ? 420.h : 365.h);
    final double walkIconSize = isDesktop ? 36.h : 32.h;
    final double walkIconBoxW = isDesktop ? 64.h : 59.h;

    final s = TextStyleHelper.instance;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 32.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: s.headline24MediumInter.copyWith(color: AppColor.gray900),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.subtitle,
            style: s.title16LightInter.copyWith(color: AppColor.gray900),
          ),

          SizedBox(height: sectionGap),

          // Enhanced tracking info
          _buildTrackingInfo(),

          // Distance Row + enhanced actions
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h),
                child: SizedBox(
                  width: walkIconBoxW,
                  height: 64.h,
                  child: Center(
                    child: Icon(
                      _tracking ? Icons.navigation : Icons.directions_walk,
                      size: walkIconSize,
                      color: _tracking ? Colors.green : AppColor.gray900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _distanceToDestination > 0
                          ? _formatDistance(_distanceToDestination)
                          : widget.distanceLabel,
                      style: s.headline24MediumInter.copyWith(
                        color: AppColor.gray900,
                      ),
                    ),
                    Text(
                      widget.destinationLabel,
                      style: s.title16LightInter.copyWith(
                        color: AppColor.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('My location'),
                    onPressed: () => _centerOnMe(zoom: 16),
                  ),
                  if (_dest != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.alt_route),
                      label: const Text('Route'),
                      onPressed: _drawRoadFromMe,
                    ),
                  if (_tracking)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      onPressed: _stopTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Track'),
                      onPressed: _startEnhancedTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),

          SizedBox(height: sectionGap),

          // Enhanced OSM Map
          ClipRRect(
            borderRadius: BorderRadius.circular(24.h),
            child: SizedBox(
              height: mapHeight,
              width: double.infinity,
              child: OSMFlutter(
                controller: _mapController,
                osmOption: OSMOption(
                  userTrackingOption: UserTrackingOption(
                    enableTracking: _tracking,
                    unFollowUser: false,
                  ),
                  zoomOption: const ZoomOption(
                    initZoom: 12,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(
                        _tracking
                            ? Icons.navigation
                            : Icons.location_history_rounded,
                        color: _tracking ? Colors.green : Colors.blue,
                        size: 48,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.navigation,
                        color: _tracking ? Colors.green : Colors.blue,
                        size: 48,
                      ),
                    ),
                  ),
                  roadConfiguration: RoadOption(
                    roadColor: _tracking ? Colors.green : Colors.blueAccent,
                  ),
                ),
                onMapIsReady: (ready) async {
                  if (!mounted) return;
                  setState(() => _mapReady = ready);
                  await _addDestinationMarker();
                },
              ),
            ),
          ),

          SizedBox(height: sectionGap),

          SizedBox(
            width: double.infinity,
            height: isMobile ? 64.h : 80.h,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onStartNavigation != null) {
                  widget.onStartNavigation!();
                } else if (_dest != null) {
                  // Fallback: open external map app
                  final lat = _dest!.latitude;
                  final lon = _dest!.longitude;
                  final uri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking',
                  );
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNavigating
                    ? Colors.green
                    : AppColor.gray900,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.h),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.h, vertical: 16.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isNavigating ? Icons.navigation : Icons.directions,
                    size: isMobile ? 24.h : 28.h,
                  ),
                  SizedBox(width: 8.h),
                  Text(
                    _isNavigating ? 'Navigate Now' : 'Start Navigation',
                    style:
                        (isMobile
                                ? s.headline24MediumInter
                                : s.headline24MediumInter)
                            .copyWith(color: AppColor.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
