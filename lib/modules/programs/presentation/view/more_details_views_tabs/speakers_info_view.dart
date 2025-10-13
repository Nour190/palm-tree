import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';

class SpeakersInfoScreen extends StatefulWidget {
  const SpeakersInfoScreen({
    super.key,
    required this.speaker,
    required this.userId,
  });

  final Speaker speaker;
  final String userId;

  @override
  State<SpeakersInfoScreen> createState() => _SpeakersInfoScreenState();
}

class _SpeakersInfoScreenState extends State<SpeakersInfoScreen> {
  MapController? _mapController;
  bool _isMapReady = false;
  bool _isFavorite = false;
  Position? _currentPosition;
  double? _distanceInMeters;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionStream;
  RoadInfo? _currentRoad;
  bool _isNavigating = false;
  Timer? _mapUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _initializeLocation();
  }

  void _initializeMap() {
    if (widget.speaker.latitude != null && widget.speaker.longitude != null) {
      _mapController = MapController(
        initPosition: GeoPoint(
          latitude: widget.speaker.latitude!,
          longitude: widget.speaker.longitude!,
        ),
      );
    }
  }

  Future<void> _initializeLocation() async {
    try {
      // Check if we have valid speaker location
      if (widget.speaker.latitude == null || widget.speaker.longitude == null) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permission is required for navigation'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Location request timed out');
        },
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _distanceInMeters = _calculateDistance(
          position.latitude,
          position.longitude,
          widget.speaker.latitude!,
          widget.speaker.longitude!,
        );
        _isLoadingLocation = false;
      });

      // Update map if ready
      if (_isMapReady && _mapController != null) {
        await _updateMapWithRoute(position);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startNavigation() {
    if (_currentPosition == null || _mapController == null) return;

    setState(() => _isNavigating = true);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        widget.speaker.latitude!,
        widget.speaker.longitude!,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _distanceInMeters = distance;
      });

      // Check if arrived
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
    });

    // Update map periodically
    _mapUpdateTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (_currentPosition != null && _isNavigating && _mapController != null) {
        _updateMapWithRoute(_currentPosition!);
      }
    });
  }

  void _stopNavigation() {
    _positionStream?.cancel();
    _mapUpdateTimer?.cancel();
    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }

  Future<void> _updateMapWithRoute(Position currentPos) async {
    if (_mapController == null || !_isMapReady) return;
    if (widget.speaker.latitude == null || widget.speaker.longitude == null) return;

    try {
      final currentGeoPoint = GeoPoint(
        latitude: currentPos.latitude,
        longitude: currentPos.longitude,
      );
      final destinationGeoPoint = GeoPoint(
        latitude: widget.speaker.latitude!,
        longitude: widget.speaker.longitude!,
      );

      // Clear previous roads
      try {
        await _mapController!.clearAllRoads();
      } catch (e) {
        debugPrint('Error clearing roads: $e');
      }

      // Add current location marker
      await _mapController!.addMarker(
        currentGeoPoint,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 60,
          ),
        ),
      );

      // Add destination marker
      await _mapController!.addMarker(
        destinationGeoPoint,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.place,
            color: Colors.red,
            size: 60,
          ),
        ),
      );

      // Draw route
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

      // Zoom to show complete route
      final north = [currentPos.latitude, widget.speaker.latitude!]
          .reduce((a, b) => a > b ? a : b);
      final south = [currentPos.latitude, widget.speaker.latitude!]
          .reduce((a, b) => a < b ? a : b);
      final east = [currentPos.longitude, widget.speaker.longitude!]
          .reduce((a, b) => a > b ? a : b);
      final west = [currentPos.longitude, widget.speaker.longitude!]
          .reduce((a, b) => a < b ? a : b);

      await _mapController!.zoomToBoundingBox(
        BoundingBox(
          north: north,
          south: south,
          east: east,
          west: west,
        ),
        paddinInPixel: 100,
      );
    } catch (e) {
      debugPrint('Error updating map route: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
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
    _mapUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacingLarge = ProgramsLayout.spacingLarge(context);
    final spacingMedium = ProgramsLayout.spacingMedium(context);
    final languageCode = context.locale.languageCode;
    final localizedName = widget.speaker.localizedName(
      languageCode: languageCode,
    );
    final localizedTopicName =
        widget.speaker.localizedTopicName(languageCode: languageCode) ??
            localizedName;
    final localizedTopicDescription = widget.speaker.localizedTopicDescription(
      languageCode: languageCode,
    );

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          localizedName,
          style: ProgramsTypography.headingMedium(context),
        ),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.black,
        elevation: 0,
        actions: [
          if (_isNavigating)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _stopNavigation,
              tooltip: 'Stop Navigation',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ProgramsLayout.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SpeakerHeaderImage(
                imageUrl: widget.speaker.profileImage,
                isFavorite: _isFavorite,
                onFavoriteToggle: () {
                  setState(() => _isFavorite = !_isFavorite);
                },
              ),
              SizedBox(height: spacingLarge),
              _SessionTime(time: widget.speaker.startAt),
              SizedBox(height: spacingMedium),
              Text(
                localizedTopicName,
                style: ProgramsTypography.bodyPrimary(context).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColor.black,
                ),
              ),
              SizedBox(height: 4),
              if (localizedTopicDescription?.isNotEmpty ?? false)
                Text(
                  localizedTopicDescription!,
                  style: ProgramsTypography.bodySecondary(context).copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    height: 1.5,
                    color: AppColor.black,
                  ),
                ),
              SizedBox(height: spacingLarge),
              _NavigationInfo(
                distanceInMeters: _distanceInMeters,
                isLoading: _isLoadingLocation,
                isNavigating: _isNavigating,
                currentRoad: _currentRoad,
                formatDistance: _formatDistance,
                estimateWalkingTime: _estimateWalkingTime,
              ),
              SizedBox(height: spacingMedium),
              _MapPreview(
                controller: _mapController,
                isMapReady: _isMapReady,
                isNavigating: _isNavigating,
                distanceInMeters: _distanceInMeters,
                onReady: () {
                  setState(() => _isMapReady = true);
                  if (_currentPosition != null) {
                    _updateMapWithRoute(_currentPosition!);
                  }
                },
              ),
              SizedBox(height: spacingLarge),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          ProgramsLayout.pagePadding(context).left,
          0,
          ProgramsLayout.pagePadding(context).right,
          ProgramsLayout.spacingMedium(context),
        ),
        child: SizedBox(
          height: ProgramsLayout.size(context, 56),
          child: ElevatedButton(
            onPressed: (_currentPosition == null || 
                       _isLoadingLocation || 
                       _mapController == null)
                ? null
                : () {
                    if (_isNavigating) {
                      _stopNavigation();
                    } else {
                      _startNavigation();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNavigating ? Colors.red : AppColor.black,
              foregroundColor: AppColor.white,
              disabledBackgroundColor: AppColor.gray400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ProgramsLayout.radius16(context),
                ),
              ),
            ),
            child: _isLoadingLocation
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isNavigating ? Icons.stop : Icons.navigation),
                      SizedBox(width: 8),
                      Text(
                        _isNavigating ? 'Stop Navigation' : 'Start Navigation',
                        style: ProgramsTypography.bodyPrimary(context).copyWith(
                          color: AppColor.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SpeakerHeaderImage extends StatelessWidget {
  const _SpeakerHeaderImage({
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
          child: AspectRatio(
            aspectRatio: 343 / 174,
            child: imageUrl?.isNotEmpty ?? false
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder,
                  )
                : _placeholder,
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: _FavoriteButton(
            isFavorite: isFavorite,
            onPressed: onFavoriteToggle,
          ),
        ),
      ],
    );
  }

  Widget get _placeholder => Container(
        color: AppColor.gray100,
        child: Center(
          child: Icon(Icons.image_outlined, color: AppColor.gray400),
        ),
      );
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.white, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: AppColor.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SessionTime extends StatelessWidget {
  const _SessionTime({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final localeName = context.locale.toLanguageTag();
    final timeLabel = DateFormat.jm(localeName).format(time.toLocal());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          timeLabel,
          style: ProgramsTypography.headingLarge(context).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            color: AppColor.black,
          ),
        ),
        Transform.rotate(
          angle: -0.785398,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.arrow_upward,
              size: 35,
              color: AppColor.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavigationInfo extends StatelessWidget {
  const _NavigationInfo({
    required this.distanceInMeters,
    required this.isLoading,
    required this.isNavigating,
    required this.currentRoad,
    required this.formatDistance,
    required this.estimateWalkingTime,
  });

  final double? distanceInMeters;
  final bool isLoading;
  final bool isNavigating;
  final RoadInfo? currentRoad;
  final String Function(double) formatDistance;
  final int Function(double) estimateWalkingTime;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
              style: ProgramsTypography.bodySecondary(context).copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
      );
    }

    if (distanceInMeters == null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, size: 24, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Location unavailable',
                style: ProgramsTypography.bodySecondary(context).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final distance = formatDistance(distanceInMeters!);
    final walkingTime = estimateWalkingTime(distanceInMeters!);
    final roadDistance = currentRoad?.distance;
    final roadDuration = currentRoad?.duration;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNavigating ? Colors.blue.shade50 : AppColor.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNavigating ? Colors.blue : AppColor.gray200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNavigating ? Colors.blue : AppColor.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isNavigating ? Icons.navigation : Icons.directions_walk,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
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
                          style: ProgramsTypography.headingMedium(context)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: AppColor.black,
                          ),
                        ),
                        if (isNavigating) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      roadDuration != null
                          ? '${(roadDuration / 60).round()} min walking'
                          : '$walkingTime min walking',
                      style: ProgramsTypography.bodySecondary(context).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColor.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isNavigating) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade900),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Navigation active - Following your location',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.controller,
    required this.isMapReady,
    required this.isNavigating,
    required this.distanceInMeters,
    required this.onReady,
  });

  final BaseMapController? controller;
  final bool isMapReady;
  final bool isNavigating;
  final double? distanceInMeters;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.5;

    if (controller == null) {
      return Container(
        height: mapHeight,
        decoration: BoxDecoration(
          color: AppColor.gray100,
          borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
          border: Border.all(color: AppColor.black, width: 2),
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
      borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
      child: Container(
        height: mapHeight,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.black, width: 2),
          borderRadius: BorderRadius.circular(ProgramsLayout.radius16(context)),
        ),
        child: Stack(
          children: [
            OSMFlutter(
              controller: controller!,
              onMapIsReady: (ready) {
                if (ready) {
                  onReady();
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
            if (!isMapReady)
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
            if (isNavigating && isMapReady)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.navigation, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Navigating',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (distanceInMeters != null)
                              Text(
                                '${distanceInMeters! < 1000 ? "${distanceInMeters!.round()} m" : "${(distanceInMeters! / 1000).toStringAsFixed(1)} km"} to destination',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
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