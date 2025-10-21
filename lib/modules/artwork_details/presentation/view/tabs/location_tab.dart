import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';

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
    this.mapImage,
    this.onStartNavigation,
    this.showHeader = true,
    this.aboutTitle,
    this.aboutDescription,
    this.routeHint,
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
  final String? mapImage;
  final VoidCallback? onStartNavigation;
  final bool showHeader;
  final String? aboutTitle;
  final String? aboutDescription;
  final String? routeHint;

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  MapController? _mapController;
  bool _mapReady = false;
  Position? _currentPosition;
  double? _distanceInMeters;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionStream;
  RoadInfo? _currentRoad;
  bool _isNavigating = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _checkConnectivity();
    _initializeLocation();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await ConnectivityService().hasConnection();
    if (mounted) {
      setState(() => _isOnline = isOnline);
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription = ConnectivityService().onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = results.any(
            (result) =>
        result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

      if (mounted && _isOnline != hasConnection) {
        setState(() => _isOnline = hasConnection);

        if (hasConnection) {
          _initializeLocation();
        }
      }
    });
  }

  void _initializeMap() {
    if (widget.latitude != null && widget.longitude != null) {
      _mapController = MapController(
        initPosition: GeoPoint(
          latitude: widget.latitude!,
          longitude: widget.longitude!,
        ),
      );
    }
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.latitude == null || widget.longitude == null) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _distanceInMeters = _calculateDistance(
          position.latitude,
          position.longitude,
          widget.latitude!,
          widget.longitude!,
        );
        _isLoadingLocation = false;
      });

      if (_mapReady && _mapController != null) {
        await _updateMapWithRoute(position);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      debugPrint('Error getting location: $e');

      if (_isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startNavigation() {
    if (_currentPosition == null || _mapController == null) return;

    setState(() => _isNavigating = true);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position position) {
            final distance = _calculateDistance(
              position.latitude,
              position.longitude,
              widget.latitude!,
              widget.longitude!,
            );

            if (!mounted) return;

            setState(() {
              _currentPosition = position;
              _distanceInMeters = distance;
            });

            if (distance < 20) {
              _stopNavigation();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You have arrived!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        );
  }

  void _stopNavigation() {
    _positionStream?.cancel();
    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }

  Future<void> _updateMapWithRoute(Position currentPos) async {
    if (_mapController == null || !_mapReady) return;
    if (widget.latitude == null || widget.longitude == null) return;

    try {
      final currentGeoPoint = GeoPoint(
        latitude: currentPos.latitude,
        longitude: currentPos.longitude,
      );
      final destinationGeoPoint = GeoPoint(
        latitude: widget.latitude!,
        longitude: widget.longitude!,
      );

      try {
        await _mapController!.clearAllRoads();
      } catch (e) {
        debugPrint('Error clearing roads: $e');
      }

      await _mapController!.addMarker(
        currentGeoPoint,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.my_location, color: Colors.blue, size: 60),
        ),
      );

      await _mapController!.addMarker(
        destinationGeoPoint,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.place, color: Colors.red, size: 60),
        ),
      );

      if (_isOnline) {
        final road = await _mapController!.drawRoad(
          currentGeoPoint,
          destinationGeoPoint,
          roadType: RoadType.foot,
          roadOption: RoadOption(
            roadWidth: 10,
            roadColor: _isNavigating ? Colors.blue : Colors.blue.shade300,
          ),
        );

        if (mounted) {
          setState(() => _currentRoad = road);
        }
      }

      final north = [
        currentPos.latitude,
        widget.latitude!,
      ].reduce((a, b) => a > b ? a : b);
      final south = [
        currentPos.latitude,
        widget.latitude!,
      ].reduce((a, b) => a < b ? a : b);
      final east = [
        currentPos.longitude,
        widget.longitude!,
      ].reduce((a, b) => a > b ? a : b);
      final west = [
        currentPos.longitude,
        widget.longitude!,
      ].reduce((a, b) => a < b ? a : b);

      await _mapController!.zoomToBoundingBox(
        BoundingBox(north: north, south: south, east: east, west: west),
        paddinInPixel: 100,
      );
    } catch (e) {
      debugPrint('Error updating map route: $e');
    }
  }

  double _calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
            cos((lat2 - lat1) * p) / 2 +
            cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a));
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  int _estimateWalkingTime(double meters) {
    return (meters / 1.4 / 60).round();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _connectivitySubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = SizeUtils.width;
    final bool isMobile = w < 840;
    final s = TextStyleHelper.instance;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: s.body16MediumInter.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.subtitle,
                      style: s.body12LightInter.copyWith(
                        color: AppColor.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isOnline)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Offline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 20.h),

          // About Section
          if ((widget.aboutTitle ?? '').isNotEmpty) ...[
            Text(
              widget.aboutTitle!,
              style: s.body16MediumInter.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if ((widget.aboutDescription ?? '').isNotEmpty) ...[
            Text(
              widget.aboutDescription!,
              style: s.body12LightInter.copyWith(
                color: AppColor.gray700,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // Navigation Info
          _buildNavigationInfo(s),

          SizedBox(height: 20.h),

          // Map
          _buildMapPreview(),

          SizedBox(height: 20.h),

          // Start Now Button
          GestureDetector(
            onTap: (_currentPosition == null ||
                _isLoadingLocation ||
                _mapController == null ||
                !_isOnline)
                ? null
                : () {
              if (_isNavigating) {
                _stopNavigation();
              } else {
                _startNavigation();
              }
              widget.onStartNavigation?.call();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: (_currentPosition == null ||
                    _isLoadingLocation ||
                    _mapController == null ||
                    !_isOnline)
                    ? AppColor.gray400
                    : (_isNavigating ? Colors.red : Colors.black),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isLoadingLocation
                  ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
                  : Text(
                !_isOnline
                    ? 'Navigation unavailable offline'
                    : (_isNavigating ? 'Stop Now' : 'start_now'.tr()),
                textAlign: TextAlign.center,
                style: s.title16MediumInter.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationInfo(TextStyleHelper s) {
    if (_isLoadingLocation) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.gray50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.black,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Getting your location...',
              style: s.body12LightInter.copyWith(
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
      );
    }

    if (_distanceInMeters == null) {
      return Row(
        children: [
          Icon(Icons.location_off, size: 24, color: AppColor.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Location unavailable',
              style: s.body12LightInter.copyWith(
                color: AppColor.gray900,
              ),
            ),
          ),
        ],
      );
    }

    final distance = _formatDistance(_distanceInMeters!);
    final walkingTime = _estimateWalkingTime(_distanceInMeters!);
    final roadDistance = _currentRoad?.distance;
    final roadDuration = _currentRoad?.duration;
    final isCachedLocation = !_isOnline && _currentPosition != null;

    return Column(
      children: [
        Row(
          children: [
            Icon(
              _isNavigating
                  ? Icons.navigation
                  : (isCachedLocation ? Icons.history : Icons.directions_walk),
              color: Colors.black,
              size: 40,
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        roadDistance != null
                            ? '${(roadDistance / 1000).toStringAsFixed(1)} km'
                            : distance,
                        style: s.body16MediumInter.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      if (_isNavigating) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (isCachedLocation) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'CACHED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    roadDuration != null
                        ? '${(roadDuration / 60).round()} min walking'
                        : '$walkingTime min walking',
                    style: s.body14RegularInter.copyWith(
                      color: AppColor.gray600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isCachedLocation) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColor.gray900),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing last known location (offline)',
                    style: TextStyle(
                      color: AppColor.gray900,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_isNavigating) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, color: Colors.blue.shade900, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navigating',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (_distanceInMeters != null)
                        Text(
                          '${_formatDistance(_distanceInMeters!)} to destination',
                          style: TextStyle(
                            color: Colors.blue.shade900.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMapPreview() {
    if (_mapController == null) {
      return Container(
        height: 162.h,
        decoration: BoxDecoration(
          color: AppColor.gray100,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(color: AppColor.gray200, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: AppColor.gray400),
              SizedBox(height: 16),
              Text(
                'Map unavailable',
                style: TextStyle(color: AppColor.gray600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.h),
      child: Container(
        height: 162.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.gray200, width: 1),
          borderRadius: BorderRadius.circular(12.h),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            OSMFlutter(
              controller: _mapController!,
              onMapIsReady: (ready) {
                if (ready) {
                  setState(() => _mapReady = true);
                  if (_currentPosition != null && _isOnline) {
                    _updateMapWithRoute(_currentPosition!);
                  }
                }
              },
              osmOption: OSMOption(
                zoomOption: ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1,
                ),
                showZoomController: true,
                showDefaultInfoWindow: false,
              ),
            ),
            if (!_mapReady)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColor.black),
                      SizedBox(height: 16),
                      Text(
                        'Loading map...',
                        style: TextStyle(color: AppColor.gray600),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isOnline && _mapReady)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline - Last known location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isNavigating && _mapReady)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Navigating',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (_distanceInMeters != null)
                              Text(
                                '${_formatDistance(_distanceInMeters!)} to go',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}