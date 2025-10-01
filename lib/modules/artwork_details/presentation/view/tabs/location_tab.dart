import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

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
  late MapController _mapController;
  GeoPoint? _dest;
  bool _mapReady = false;
  GeoPoint? _currentPosition;
  double _distanceToDestination = 0.0;

  CustomTile get _tileStandard => CustomTile(
    sourceName: "osm",
    tileExtension: ".png",
    minZoomLevel: 2,
    maxZoomLevel: 19,
    urlsServers: [
      TileURLs(url: "https://tile.openstreetmap.org/", subdomains: const []),
    ],
    tileSize: 256,
  );

  @override
  void initState() {
    super.initState();

    _dest = (widget.latitude != null && widget.longitude != null)
        ? GeoPoint(latitude: widget.latitude!, longitude: widget.longitude!)
        : null;

    _mapController = MapController(
      initPosition: _dest ?? GeoPoint(latitude: 24.7136, longitude: 46.6753),
      areaLimit: const BoundingBox.world(),
    );

    if (_dest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _ensureDestMarker();
        await _primeDistance();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _primeDistance() async {
    if (_dest == null) return;
    if (!await _ensureLocationPermissions()) return;

    try {
      final p = await Geolocator.getCurrentPosition();
      final me = GeoPoint(latitude: p.latitude, longitude: p.longitude);
      _currentPosition = me;
      _distanceToDestination = Geolocator.distanceBetween(
        me.latitude,
        me.longitude,
        _dest!.latitude,
        _dest!.longitude,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  String _formatDistance(double meters) {
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(1)} ${'location.miles'.tr()}';
  }

  Future<bool> _ensureLocationPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> _ensureDestMarker() async {
    if (_dest == null || !_mapReady) return;
    try {
      await _mapController.addMarker(
        _dest!,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_pin, color: Colors.red, size: 64),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final w = SizeUtils.width;
    final bool isMobile = w < 840;
    final double horizontalPadding = isMobile ? 16.h : 24.h;
    final s = TextStyleHelper.instance;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.title, // ديناميكي - يترجم من ملف json إذا جالك key
              style: s.headline20BoldInter.copyWith(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.subtitle,
              style: s.body14RegularInter.copyWith(
                color: AppColor.gray600,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 20.h),

            // About Section
            if ((widget.aboutTitle ?? '').isNotEmpty) ...[
              Text(
                widget.aboutTitle!,
                style: s.title16MediumInter.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            if ((widget.aboutDescription ?? '').isNotEmpty) ...[
              Text(
                widget.aboutDescription!,
                style: s.body14RegularInter.copyWith(
                  color: AppColor.gray700,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // Distance Badge
            if (_dest != null) ...[
              Row(
                children: [
                  const Icon(Icons.directions_walk, size: 16, color: Colors.black),
                  SizedBox(width: 6.h),
                  Text(
                    '${(_distanceToDestination / 1000 * 0.621371).toStringAsFixed(1)} ${'location.min'.tr()} ( ${_formatDistance(_distanceToDestination)} )',
                    style: s.body14RegularInter.copyWith(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                widget.destinationLabel, // ديناميكي
                style: s.body14RegularInter.copyWith(
                  color: AppColor.gray600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // Map
            ClipRRect(
              borderRadius: BorderRadius.circular(12.h),
              child: Container(
                height: 280.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.gray200, width: 1),
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: OSMFlutter(
                  controller: _mapController,
                  osmOption: OSMOption(
                    zoomOption: const ZoomOption(
                      initZoom: 14,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.blue,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  onMapIsReady: (ready) async {
                    if (!mounted) return;
                    _mapReady = ready;
                    await _ensureDestMarker();
                  },
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Start Now Button
            GestureDetector(
              onTap: widget.onStartNavigation,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Text(
                  'location.start_now'.tr(),
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
      ),
    );
  }
}