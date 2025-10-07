import 'dart:async';
import 'dart:math' as math;

import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/events/data/datasources/speaker_remote_data_source.dart';
import 'package:baseqat/modules/events/data/repositories/speaker/speaker_repository_impl.dart';
import 'package:baseqat/modules/events/presentation/manger/speaker/speaker_cubit.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Speaker Info Screen — UI aligned to provided screenshot.
/// - Hero image with small eye badge
/// - Big time “9:00AM” + chevron
/// - Title + description
/// - “Live Now” pill with avatar + static waveform
/// - Distance line “3 min (0.4 miles) to …”
/// - Compact map
/// - Sticky bottom “Start Now / Stop Tracking” button
class SpeakersInfoScreen extends StatefulWidget {
  final Speaker speaker;
  final String userId;

  const SpeakersInfoScreen({
    super.key,
    required this.speaker,
    required this.userId,
  });

  @override
  State<SpeakersInfoScreen> createState() => _SpeakersInfoScreenState();
}

class _SpeakersInfoScreenState extends State<SpeakersInfoScreen> {
  // Map controller
  late final MapController _mapController;

  // Location tracking
  GeoPoint? _venueLocation;
  GeoPoint? _userLocation;
  bool _isMapReady = false;
  bool _isTracking = false;

  // Distance calculations
  double? _distanceInMeters;
  int? _estimatedWalkMinutes;

  // Subscriptions
  StreamSubscription<Position>? _locationSubscription;

  // Route tracking
  List<GeoPoint> _routePoints = [];
  RoadInfo? _currentRoute;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _getUserInitialLocation();
  }

  @override
  void dispose() {
    _stopTracking();
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  void _initializeMap() {
    if (widget.speaker.latitude != null && widget.speaker.longitude != null) {
      _venueLocation = GeoPoint(
        latitude: widget.speaker.latitude!,
        longitude: widget.speaker.longitude!,
      );
    }

    _mapController = MapController(
      initPosition: _venueLocation ??
          GeoPoint(latitude: 25.2048, longitude: 55.2708), // Dubai default
    );
  }

  // ============================================================================
  // LOCATION & TRACKING
  // ============================================================================

  Future<void> _getUserInitialLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) _showPermissionDeniedDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _userLocation = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _calculateDistance();
      });

      if (_isMapReady) {
        await _updateMapMarkers();
        await _fitMapBounds();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _startTracking() async {
    if (_isTracking) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        return;
      }

      setState(() {
        _isTracking = true;
        _routePoints.clear();
      });

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 10),
        ),
      ).listen(
        _onLocationUpdate,
        onError: (error) {
          debugPrint('Location stream error: $error');
          _stopTracking();
        },
      );

      if (_userLocation != null && _venueLocation != null) {
        await _drawRoute();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎯 Tracking started'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error starting tracking: $e');
      _stopTracking();
    }
  }

  void _stopTracking() {
    if (!_isTracking) return;

    _locationSubscription?.cancel();
    _locationSubscription = null;

    setState(() {
      _isTracking = false;
      _routePoints.clear();
    });

    _clearRoute();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏸️ Tracking stopped'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onLocationUpdate(Position position) async {
    if (!mounted || !_isTracking) return;

    final newLocation = GeoPoint(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    setState(() {
      _userLocation = newLocation;
      _routePoints.add(newLocation);
      _calculateDistance();
    });

    if (_isMapReady) {
      await _updateUserMarker();
      if (_shouldRecalculateRoute()) {
        await _drawRoute();
      }
      if (_isTracking) {
        await _mapController.moveTo(newLocation);
      }
    }
  }

  bool _shouldRecalculateRoute() {
    if (_routePoints.length < 10) return false;

    final lastTenPoints = _routePoints.skip(_routePoints.length - 10);
    double totalDistance = 0;

    for (int i = 0; i < lastTenPoints.length - 1; i++) {
      final p1 = lastTenPoints.elementAt(i);
      final p2 = lastTenPoints.elementAt(i + 1);
      totalDistance += Geolocator.distanceBetween(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
    }

    return totalDistance > 50;
  }

  // ============================================================================
  // MAP OPERATIONS
  // ============================================================================

  Future<void> _updateMapMarkers() async {
    if (!_isMapReady) return;

    try {
      await _clearAllMarkers();

      if (_venueLocation != null) {
        await _mapController.addMarker(
          _venueLocation!,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 48,
            ),
          ),
        );
      }

      if (_userLocation != null) {
        await _mapController.addMarker(
          _userLocation!,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 36,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating markers: $e');
    }
  }

  Future<void> _updateUserMarker() async {
    if (!_isMapReady || _userLocation == null) return;

    try {
      await _mapController.changeLocationMarker(
        oldLocation: _userLocation!,
        newLocation: _userLocation!,
        markerIcon: const MarkerIcon(
          icon: Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 36,
          ),
        ),
      );
    } catch (e) {
      await _updateMapMarkers();
    }
  }

  Future<void> _clearAllMarkers() async {
    try {
      if (_userLocation != null) {
        await _mapController.removeMarker(_userLocation!);
      }
      if (_venueLocation != null) {
        await _mapController.removeMarker(_venueLocation!);
      }
    } catch (_) {}
  }

  Future<void> _drawRoute() async {
    if (!_isMapReady || _userLocation == null || _venueLocation == null) return;

    try {
      await _clearRoute();

      _currentRoute = await _mapController.drawRoad(
        _userLocation!,
        _venueLocation!,
        roadType: RoadType.foot,
        roadOption: RoadOption(
          roadWidth: 6,
          roadColor: Colors.blue.withOpacity(0.7),
          zoomInto: false,
        ),
      );
    } catch (e) {
      debugPrint('Error drawing route: $e');
    }
  }

  Future<void> _clearRoute() async {
    if (_currentRoute != null) {
      try {
        await _mapController.removeRoad(roadKey: _currentRoute!.key);
        _currentRoute = null;
      } catch (e) {
        debugPrint('Error clearing route: $e');
      }
    }
  }

  Future<void> _fitMapBounds() async {
    if (!_isMapReady) return;

    try {
      if (_userLocation != null && _venueLocation != null) {
        final padding = 0.005; // ~500m
        final north =
            math.max(_userLocation!.latitude, _venueLocation!.latitude) +
                padding;
        final south =
            math.min(_userLocation!.latitude, _venueLocation!.latitude) -
                padding;
        final east =
            math.max(_userLocation!.longitude, _venueLocation!.longitude) +
                padding;
        final west =
            math.min(_userLocation!.longitude, _venueLocation!.longitude) -
                padding;

        await _mapController.zoomToBoundingBox(
          BoundingBox(north: north, south: south, east: east, west: west),
          paddinInPixel: 50,
        );
      } else if (_venueLocation != null) {
        await _mapController.moveTo(_venueLocation!);
        await _mapController.setZoom(stepZoom: 15);
      }
    } catch (e) {
      debugPrint('Error fitting bounds: $e');
    }
  }

  // ============================================================================
  // CALCULATIONS
  // ============================================================================

  void _calculateDistance() {
    if (_userLocation == null || _venueLocation == null) {
      setState(() {
        _distanceInMeters = null;
        _estimatedWalkMinutes = null;
      });
      return;
    }

    final meters = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      _venueLocation!.latitude,
      _venueLocation!.longitude,
    );

    // Walking speed: ~80 m/min (~5 km/h)
    final minutes = math.max(1, (meters / 80.0).round());

    setState(() {
      _distanceInMeters = meters;
      _estimatedWalkMinutes = minutes;
    });
  }

  // ============================================================================
  // FORMATTING HELPERS
  // ============================================================================

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute$period';
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '—';
    final miles = meters / 1609.344;
    if (miles < 0.1) return '${meters.round()} m';
    return '${miles.toStringAsFixed(1)} miles';
  }

  String _getVenueName() {
    final parts = <String>[
      if ((widget.speaker.addressLine ?? '').trim().isNotEmpty)
        widget.speaker.addressLine!.trim(),
      if ((widget.speaker.city ?? '').trim().isNotEmpty)
        widget.speaker.city!.trim(),
    ];
    return parts.isEmpty ? 'Festival Speakers' : parts.first;
  }

  // ============================================================================
  // DIALOGS
  // ============================================================================

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to use tracking features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show your position and provide directions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpeakerCubit>(
      create: (_) {
        final remote = SpeakerRemoteDataSourceImpl(Supabase.instance.client);
        final repo = SpeakerRepositoryImpl(remote);
        final cubit = SpeakerCubit(repo);
        cubit.initWithSpeaker(
          speaker: widget.speaker,
          userId: widget.userId,
          checkFavorite: true,
        );
        return cubit;
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildHeaderImage(),            // hero + eye badge
              const SizedBox(height: 16),
              _buildTimeRow(),                // 9:00AM + chevron
              const SizedBox(height: 8),
              _buildTitleAndDescription(),    // title + body
              const SizedBox(height: 12),
              _buildLiveNowPill(),            // avatar + waveform
              const SizedBox(height: 12),
              _buildDistanceLine(),           // “3 min (0.4 miles) to …”
              const SizedBox(height: 12),
              _buildMapCard(),                // compact map
              const SizedBox(height: 80),     // spacer for sticky button
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _venueLocation == null
                  ? null
                  : (_isTracking ? _stopTracking : _startTracking),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : AppColor.black,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isTracking ? Icons.stop : Icons.navigation, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isTracking ? 'Stop Tracking' : 'Start Now',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UI COMPONENTS (Screenshot-accurate)
  // ============================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColor.white,
      foregroundColor: AppColor.black,
      title: Text(
        widget.speaker.name, // e.g., "Clay Whispers"
        style: TextStyleHelper.instance.title16BoldInter,
      ),
    );
  }

  Widget _buildHeaderImage() {
    final imageUrl = widget.speaker.profileImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
          // small eye badge in top-left (matches screenshot)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.blueGray100),
              ),
              child: const Icon(Icons.remove_red_eye_outlined, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColor.backgroundGray,
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 56, color: Colors.black38),
    );
  }

  // Big time “9:00AM” with a chevron on the right
  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _formatTime(widget.speaker.startAt), // “9:00AM”
            style: TextStyleHelper.instance.headline28BoldInter.copyWith(
              fontSize: 36,
              height: 1.05,
              color: AppColor.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
        ),
      ],
    );
  }

  // Title “Sustainable Agriculture” + gray description
  Widget _buildTitleAndDescription() {
    final speaker = widget.speaker;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((speaker.topicName ?? '').trim().isNotEmpty)
          Text(
            speaker.topicName!,
            style: TextStyleHelper.instance.title16BoldInter.copyWith(
              color: AppColor.gray900,
            ),
          ),
        if ((speaker.topicDescription ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            speaker.topicDescription!,
            style: TextStyleHelper.instance.body14RegularInter.copyWith(
              color: AppColor.gray700,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  // Live Now pill with avatar + mini waveform (static bars to match screenshot)
  Widget _buildLiveNowPill() {
    final avatarUrl = widget.speaker.profileImage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.blueGray100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColor.backgroundGray,
            backgroundImage:
                (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? const Icon(Icons.person, size: 16, color: Colors.black45)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Live Now',
            style: TextStyleHelper.instance.body12MediumInter.copyWith(
              color: AppColor.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _waveformBars()),
          const SizedBox(width: 8),
          const Icon(Icons.play_arrow_rounded, size: 18),
        ],
      ),
    );
  }

  Widget _waveformBars() {
    // Static bar heights to visually match the screenshot’s pill
    final heights = [6.0, 10.0, 14.0, 18.0, 14.0, 10.0, 6.0];
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final h in heights) ...[
            Container(
              width: 2,
              height: h,
              decoration: BoxDecoration(
                color: AppColor.gray900,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }

  // Distance line: “3 min (0.4 miles) to Festival Speakers”
  Widget _buildDistanceLine() {
    final text = (_distanceInMeters == null || _estimatedWalkMinutes == null)
        ? 'Distance unavailable'
        : '${_estimatedWalkMinutes!} min (${_formatDistance(_distanceInMeters)}) to ${_getVenueName()}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blueGray100),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                color: AppColor.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact map (rounded like screenshot)
  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 220.sH,
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.blueGray100),
        ),
        child: Stack(
          children: [
            OSMFlutter(
              controller: _mapController,
              onMapIsReady: (ready) async {
                setState(() => _isMapReady = true);
                await _updateMapMarkers();
                await _fitMapBounds();
              },
              osmOption: OSMOption(
                showZoomController: true,
                enableRotationByGesture: true,
                zoomOption: const ZoomOption(
                  initZoom: 14,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userTrackingOption: UserTrackingOption(
                  enableTracking: _isTracking,
                  unFollowUser: !_isTracking,
                ),
                roadConfiguration: const RoadOption(roadColor: Colors.blue),
                staticPoints: const [],
              ),
            ),
            if (_isTracking)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
