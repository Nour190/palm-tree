import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';

/// Black‑primary, Google‑Maps‑like Location tab with no search bar.
///
///  • Destination is managed from props (lat/lon) or by **long‑pressing** on the map.
///  • All controls live **outside** the map.
///  • "3D" terrain & Satellite modes via tile‑layer switching (runtime) + a compass/bearing readout.
///  • Info panel (Destination) replaces search: name, address, lat/lon, distance, ETA, bearing, road summary.
///  • Responsive for mobile / tablet / web.
///
/// Notes:
///  - The flutter_osm_plugin is a raster‑tile engine; real camera tilt / extruded 3D buildings are not supported.
///    The "3D" switch uses OpenTopoMap terrain shading for a 3D‑ish effect.
///  - Satellite uses Esri World Imagery tiles. Review their usage terms before production.
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
    this.onStartNavigation, // deprecated, no longer used
    this.showHeader = true,
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

  /// Deprecated: navigation handoff removed
  final VoidCallback? onStartNavigation;

  /// Show the sticky header (default: true)
  final bool showHeader;

  @override
  State<LocationTab> createState() => _LocationTabState();
}

enum MapStyle { standard, terrain3D, satellite }

class _LocationTabState extends State<LocationTab>
    with TickerProviderStateMixin {
  late MapController _mapController;
  GeoPoint? _dest;
  SearchInfo?
  _destInfo; // captures address text when set via long‑press reverse search (optional)
  bool _mapReady = false;

  // Base map style
  MapStyle _style = MapStyle.standard;

  // Live tracking
  StreamSubscription<Position>? _posSub;
  bool _tracking = false;
  GeoPoint? _currentPosition;
  double _currentSpeed = 0.0; // m/s
  double _distanceToDestination = 0.0; // meters
  String _estimatedTime = '--';
  RoadInfo? _lastRoad; // from drawRoad()

  // Elapsed tracker (stream driven)
  DateTime? _trackingStart;

  // Route management (throttled)
  DateTime? _lastRouteRedrawAt;
  static const Duration _minRouteRedraw = Duration(seconds: 5);
  static const double _minMoveToRedraw = 20.0; // meters
  double _accumulatedMoveSinceRedraw = 0.0;

  // Speed-based zoom buckets to avoid spamming setZoom
  int _zoomBucket = 0; // 0: very slow, 1: walk, 2: cycle, 3: drive

  // Night overlay (tile dimming)
  bool _nightOverlay = false;

  // Pulse animation (UI flair; lightweight)
  late final AnimationController _pulseController = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _pulse = CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  );

  // Predefined tile layers
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
  CustomTile get _tileTerrain3D => CustomTile(
    sourceName: "opentopomap",
    tileExtension: ".png",
    minZoomLevel: 2,
    maxZoomLevel: 17,
    urlsServers: [
      TileURLs(url: "https://tile.opentopomap.org/", subdomains: []),
    ],
    tileSize: 256,
  );
  CustomTile get _tileSatellite => CustomTile(
    sourceName: "esri_world_imagery",
    tileExtension: "", // ArcGIS path already includes {z}/{y}/{x}
    minZoomLevel: 2,
    maxZoomLevel: 19,
    urlsServers: [
      TileURLs(
        url:
            "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/",
        subdomains: [],
      ),
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

    // Long‑press to set destination
    _mapController.listenerMapLongTapping.addListener(() async {
      final p = _mapController.listenerMapLongTapping.value;
      if (p != null) {
        await _setDestination(p);
      }
    });

    if (_dest != null) {
      // Put an initial marker and compute distance
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _ensureDestMarker();
        await _primeDistance();
      });
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------- Helpers ---------------------------------------------------------

  Future<void> _applyMapStyle(MapStyle style) async {
    if (!_mapReady) return;
    CustomTile tile;
    switch (style) {
      case MapStyle.terrain3D:
        tile = _tileTerrain3D;
        break;
      case MapStyle.satellite:
        tile = _tileSatellite;
        break;
      default:
        tile = _tileStandard;
    }
    await _mapController.changeTileLayer(tileLayer: tile);
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
      if (_currentSpeed > 0) {
        _estimatedTime = _eta(_distanceToDestination, _currentSpeed);
      }
      if (mounted) setState(() {});
    } catch (_) {
      // noop
    }
  }

  String _formatDistance(double meters) => meters < 1000
      ? '${meters.round()} m'
      : '${(meters / 1000).toStringAsFixed(1)} km';

  String _formatLatLon(double x) => x.toStringAsFixed(6);

  String _formatElapsed() {
    if (_trackingStart == null) return '--:--';
    final d = DateTime.now().difference(_trackingStart!);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0
        ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _eta(double meters, double mps) {
    if (mps <= 0 || meters <= 0) return '--';
    final secs = meters / mps;
    final mins = (secs / 60).round();
    if (mins < 60) return '${mins}min';
    final h = mins ~/ 60, r = mins % 60;
    return '${h}h ${r}min';
  }

  double _bearingDeg(GeoPoint from, GeoPoint to) {
    final lat1 = from.latitude * math.pi / 180;
    final lon1 = from.longitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final lon2 = to.longitude * math.pi / 180;
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * 180 / math.pi;
    return (brng + 360) % 360;
  }

  String _bearingCardinal(double deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((deg + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }

  Future<bool> _ensureLocationPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _dialog(
        'Location Service Disabled',
        'Please enable location services to use live features.',
      );
      return false;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      _dialog(
        'Location Permission Required',
        'Location permission is required for live features. Please grant permission in settings.',
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
      );
      return false;
    }
    return true;
  }

  void _dialog(String title, String body, {List<Widget>? actions}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions:
            actions ??
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
      ),
    );
  }

  Future<void> _centerOnMe({double? zoom}) async {
    if (!await _ensureLocationPermissions()) return;
    try {
      await _mapController.currentLocation();
      if (zoom != null) await _mapController.setZoom(zoomLevel: zoom);
      // cache last point best-effort
      final me = await _mapController.myLocation();
      _currentPosition = me;
      if (mounted) setState(() {});
    } catch (_) {
      /* ignore */
    }
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
    } catch (_) {
      /* ignore */
    }
  }

  // ---------- Routing & tracking ---------------------------------------------

  int _bucketForSpeed(double mps) {
    if (mps > 25) return 3; // driving
    if (mps > 10) return 2; // cycling
    if (mps > 2) return 1; // walking
    return 0; // very slow / standing
  }

  double _zoomForBucket(int b) {
    switch (b) {
      case 3:
        return 15;
      case 2:
        return 16;
      case 1:
        return 17;
      default:
        return 18;
    }
  }

  Future<void> _fitRouteBounds() async {
    if (_currentPosition == null || _dest == null) return;
    final box = BoundingBox.fromGeoPoints([_currentPosition!, _dest!]);
    await _mapController.zoomToBoundingBox(box, paddinInPixel: 36);
  }

  Future<void> _drawRoadThrottled(GeoPoint from) async {
    if (_dest == null) return;
    final now = DateTime.now();
    if (_lastRouteRedrawAt != null &&
        now.difference(_lastRouteRedrawAt!) < _minRouteRedraw) {
      return;
    }
    if (_accumulatedMoveSinceRedraw < _minMoveToRedraw &&
        _lastRouteRedrawAt != null) {
      return;
    }
    try {
      _lastRoad = await _mapController.drawRoad(
        from,
        _dest!,
        roadType: RoadType.car,
        roadOption: RoadOption(
          roadWidth: 8,
          roadColor: _tracking ? Colors.green : Colors.black,
          roadBorderColor: Colors.white,
          roadBorderWidth: 2,
          zoomInto: false,
        ),
      );
      _lastRouteRedrawAt = now;
      _accumulatedMoveSinceRedraw = 0.0;
    } catch (_) {
      /* ignore transient */
    }
  }

  Future<void> _startTracking() async {
    if (_tracking) return;
    if (!await _ensureLocationPermissions()) return;

    HapticFeedback.lightImpact();

    _tracking = true;
    _trackingStart = DateTime.now();
    _currentSpeed = 0;
    _accumulatedMoveSinceRedraw = 0;
    _lastRouteRedrawAt = null;

    setState(() {});
    await _centerOnMe(zoom: 16);

    _posSub?.cancel();
    _posSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 3,
          ),
        ).listen((pos) async {
          if (!mounted) return;

          final newPoint = GeoPoint(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );

          // movement & speed
          double newSpeed = pos.speed.isFinite && pos.speed >= 0
              ? pos.speed
              : 0.0; // m/s
          if (_currentPosition != null) {
            final moved = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              newPoint.latitude,
              newPoint.longitude,
            );
            _accumulatedMoveSinceRedraw += moved;

            // fallback speed if sensor returns 0
            if (newSpeed == 0 && pos.timestamp != null) {
              final dt =
                  DateTime.now().difference(pos.timestamp!).inMilliseconds /
                  1000.0;
              if (dt > 0) newSpeed = moved / dt;
            }
          }

          _currentPosition = newPoint;

          // distance & ETA
          double distToDest = _distanceToDestination;
          if (_dest != null) {
            distToDest = Geolocator.distanceBetween(
              newPoint.latitude,
              newPoint.longitude,
              _dest!.latitude,
              _dest!.longitude,
            );
          }
          final newEta = _eta(distToDest, newSpeed);

          // camera follow + zoom bucket (reduce setZoom churn)
          try {
            await _mapController.goToLocation(newPoint);
            final b = _bucketForSpeed(newSpeed);
            if (b != _zoomBucket) {
              _zoomBucket = b;
              await _mapController.setZoom(zoomLevel: _zoomForBucket(b));
            }
          } catch (_) {
            /* ignore */
          }

          // throttle route redraw
          if (_tracking && _dest != null) {
            await _drawRoadThrottled(newPoint);
          }

          // State updates only if meaningfully changed
          bool shouldRebuild = false;
          if ((newSpeed - _currentSpeed).abs() > 0.2) {
            _currentSpeed = newSpeed;
            shouldRebuild = true;
          }
          if ((distToDest - _distanceToDestination).abs() > 1.0) {
            _distanceToDestination = distToDest;
            shouldRebuild = true;
          }
          if (newEta != _estimatedTime) {
            _estimatedTime = newEta;
            shouldRebuild = true;
          }

          if (shouldRebuild) {
            setState(() {});
          } else {
            setState(() {}); // occasional refresh for elapsed clock
          }
        });
  }

  Future<void> _stopTracking() async {
    await _posSub?.cancel();
    _posSub = null;
    _tracking = false;
    _currentSpeed = 0;
    _zoomBucket = 0;
    _trackingStart = null;
    _accumulatedMoveSinceRedraw = 0;
    _lastRouteRedrawAt = null;

    try {
      await _mapController.clearAllRoads();
    } catch (_) {
      /* ignore */
    }
    if (mounted) setState(() {});
  }

  // -------------------- UI ----------------------------------------------------

  Widget _trackingInfoCard(TextStyleHelper s) {
    if (!_tracking) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: Colors.black.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulse,
                child: const Icon(
                  Icons.radio_button_checked,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              SizedBox(width: 8.h),
              Text(
                'Live Tracking',
                style: s.title16MediumInter.copyWith(color: Colors.black),
              ),
              const Spacer(),
              Text(
                _formatElapsed(),
                style: s.title16MediumInter.copyWith(color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 24.h,
            runSpacing: 12.h,
            children: [
              _metric(
                s,
                '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                'Speed',
              ),
              _metric(s, _formatDistance(_distanceToDestination), 'Distance'),
              if (_estimatedTime != '--') _metric(s, _estimatedTime, 'ETA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(TextStyleHelper s, String v, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(v, style: s.headline24BoldInter.copyWith(color: Colors.black)),
        Text(
          label,
          style: s.body12LightInter.copyWith(color: AppColor.gray500),
        ),
      ],
    );
  }

  Widget _header(TextStyleHelper s) {
    if (!widget.showHeader) return const SizedBox.shrink();

    final List<String?> parts = [
      widget.addressLine,
      [
        widget.city,
        widget.country,
      ].where((e) => (e ?? '').isNotEmpty).join(', '),
    ];
    final subtitle = parts.where((e) => (e ?? '').isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place, color: Colors.white, size: 22),
          SizedBox(width: 10.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: s.headline24MediumInter.copyWith(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle.isEmpty ? widget.subtitle : subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: s.title16LightInter.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.h),
          Wrap(
            spacing: 8.h,
            children: [
              _circleIcon(
                icon: Icons.share_location,
                onTap: () async {
                  if (_dest == null) return;
                  final uri =
                      'https://www.openstreetmap.org/?mlat=${_dest!.latitude}&mlon=${_dest!.longitude}#map=16/${_dest!.latitude}/${_dest!.longitude}';
                  await Clipboard.setData(ClipboardData(text: uri));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map link copied')),
                  );
                },
              ),
              _circleIcon(
                icon: Icons.copy_all,
                onTap: () async {
                  if (_dest == null) return;
                  await Clipboard.setData(
                    ClipboardData(
                      text: '${_dest!.latitude}, ${_dest!.longitude}',
                    ),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coordinates copied')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 36.h,
        height: 36.h,
        decoration: const BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _infoKvp(String k, String v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(v),
      ],
    );
  }

  Widget _styleChips({required bool isMobile}) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black12),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10.h : 14.h,
        vertical: isMobile ? 8.h : 10.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    Widget chip(String label, IconData icon, MapStyle target) {
      final selected = _style == target;
      return OutlinedButton.icon(
        style: style.copyWith(
          backgroundColor: MaterialStateProperty.all(
            selected ? Colors.black : Colors.white,
          ),
          foregroundColor: MaterialStateProperty.all(
            selected ? Colors.white : Colors.black,
          ),
          side: MaterialStateProperty.all(
            BorderSide(color: selected ? Colors.black : Colors.black12),
          ),
        ),
        icon: Icon(icon),
        label: Text(label),
        onPressed: () async {
          if (_style == target) return;
          setState(() => _style = target);
          await _applyMapStyle(target);
        },
      );
    }

    return Wrap(
      spacing: 8.h,
      runSpacing: 8.h,
      children: [
        chip('Standard', Icons.map, MapStyle.standard),
        chip('3D Terrain', Icons.terrain, MapStyle.terrain3D),
        // chip('Satellite', Icons.satellite_alt, MapStyle.satellite),
      ],
    );
  }

  Widget _controlsBar({required bool isMobile}) {
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isMobile ? 10.h : 14.h,
      vertical: isMobile ? 10.h : 12.h,
    );

    ButtonStyle outlined = OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black),
      padding: buttonPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    ButtonStyle filled = ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: buttonPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Wrap(
      spacing: 8.h,
      runSpacing: 8.h,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.my_location),
          label: const Text('My location'),
          onPressed: () => _centerOnMe(zoom: isMobile ? 16 : 15),
          style: outlined,
        ),
        if (_dest != null)
          OutlinedButton.icon(
            icon: const Icon(Icons.location_pin),
            label: const Text('Go to destination'),
            onPressed: () async {
              try {
                await _mapController.goToLocation(_dest!);
              } catch (_) {}
            },
            style: outlined,
          ),
        if (_dest != null)
          OutlinedButton.icon(
            icon: const Icon(Icons.alt_route),
            label: const Text('Route'),
            onPressed: () async {
              if (_currentPosition != null) {
                await _drawRoadThrottled(_currentPosition!);
              } else {
                await _centerOnMe(zoom: 16).then((_) async {
                  if (_currentPosition != null) {
                    await _drawRoadThrottled(_currentPosition!);
                  }
                });
              }
            },
            style: outlined,
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Zoom In'),
          onPressed: () async => _mapController.zoomIn(),
          style: outlined,
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.remove),
          label: const Text('Zoom Out'),
          onPressed: () async => _mapController.zoomOut(),
          style: outlined,
        ),
        OutlinedButton.icon(
          icon: Icon(Icons.route),
          label: Text('Fit Route'),
          onPressed: _fitRouteBounds,
          style: outlined,
        ),
        _tracking
            ? ElevatedButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                onPressed: _stopTracking,
                style: filled.copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
              )
            : ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Track'),
                onPressed: _startTracking,
                style: filled,
              ),
        OutlinedButton.icon(
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear route'),
          onPressed: () async {
            try {
              await _mapController.clearAllRoads();
            } catch (_) {}
            setState(() => _lastRoad = null);
          },
          style: outlined,
        ),
      ],
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
    final double mapHeight = isDesktop ? 560.h : (isTablet ? 480.h : 400.h);

    final s = TextStyleHelper.instance;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) _header(s),
          if (widget.showHeader) SizedBox(height: sectionGap),

          // Style toggles
          _styleChips(isMobile: isMobile),
          SizedBox(height: sectionGap),

          // Live tracking stats
          _trackingInfoCard(s),
          SizedBox(height: sectionGap),

          // Controls bar (outside map)
          _controlsBar(isMobile: isMobile),
          SizedBox(height: sectionGap),

          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(24.h),
            child: SizedBox(
              height: mapHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  OSMFlutter(
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
                            color: Colors.black,
                            size: 48,
                          ),
                        ),
                        directionArrowMarker: const MarkerIcon(
                          icon: Icon(
                            Icons.navigation,
                            color: Colors.black,
                            size: 48,
                          ),
                        ),
                      ),
                      roadConfiguration: RoadOption(
                        roadColor: _tracking ? Colors.green : Colors.black,
                      ),
                    ),
                    onMapIsReady: (ready) async {
                      if (!mounted) return;
                      _mapReady = ready;
                      await _applyMapStyle(
                        _style,
                      ); // ensure chosen style is applied
                      await _ensureDestMarker();
                    },
                  ),

                  if (_nightOverlay)
                    Container(color: Colors.black.withOpacity(0.18)),

                  // Hint strip
                  if (_dest == null)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Long‑press anywhere on the map to set destination.',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Mutators ---------------------------------------------

  Future<void> _setDestination(GeoPoint p, {SearchInfo? info}) async {
    // If same as current dest, ignore
    if (_dest != null &&
        p.latitude == _dest!.latitude &&
        p.longitude == _dest!.longitude) {
      return;
    }
    // Clear old road & marker
    try {
      await _mapController.clearAllRoads();
    } catch (_) {}
    if (_dest != null) {
      try {
        await _mapController.removeMarker(_dest!);
      } catch (_) {}
    }

    _dest = p;
    _destInfo = info; // may be null when set by long‑press

    // Add marker and recenter
    await _ensureDestMarker();
    try {
      await _mapController.goToLocation(_dest!);
    } catch (_) {}

    await _primeDistance();
    setState(() {});
  }
}
