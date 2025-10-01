import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/maps/presentation/manger/map_cubit.dart';
import 'package:baseqat/modules/maps/presentation/manger/map_state.dart';
import 'package:baseqat/modules/maps/data/datasources/map_remote_data_source.dart';
import 'package:baseqat/modules/maps/data/repositories/map_repository_impl.dart';
import 'package:baseqat/modules/maps/presentation/widgets/desktop_map_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
  final _mapController = MapController();

  LatLng? _user;
  List<LatLng> _route = const [];
  double? _routeKm;
  Duration? _routeDur;
  bool _isDarkMode = false;

  // tracking
  bool _tracking = false;
  Timer? _trackingTimer;
  final List<LatLng> _trackingTrail = [];

  // pulse for user marker
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // sheet guard
  bool _isSheetOpen = false;

  Color get _bg =>
      _isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _trackingTimer?.cancel();
    super.dispose();
  }

  // ---------- tracking ----------
  Future<void> _startTracking() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;
    setState(() {
      _tracking = true;
      _trackingTrail.clear();
    });
    // immediate fix + then every minute
    await _updateUserPosition();
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _updateUserPosition();
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    setState(() => _tracking = false);
  }

  Future<void> _updateUserPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _user = ll;
        _trackingTrail.add(ll);
      });
      // subtle map follow: if zoomed far out, don’t re-center
      if (_mapController.camera.zoom >= 14) {
        _mapController.move(ll, _mapController.camera.zoom);
      }
    } catch (e) {
      _toast('Tracking error: $e');
    }
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final repo = MapRepositoryImpl(
      MapRemoteDataSourceImpl(Supabase.instance.client),
    );
    return BlocProvider<MapCubit>(
      create: (_) => MapCubit(repo)..load(limit: 300),
      child: BlocConsumer<MapCubit, MapState>(
        listenWhen: (p, n) =>
            p.visiblePins != n.visiblePins ||
            p.status != n.status ||
            p.selectedPinId != n.selectedPinId,
        listener: (ctx, state) async {
          if (state.status == MapLoadStatus.success && state.hasPins) {
            _fitToPins(state.visiblePins);
          }
          if (state.selectedPin != null && !_isSheetOpen) {
            _isSheetOpen = true;
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return _PinSheet(
                  pin: state.selectedPin!,
                  isDarkMode: _isDarkMode,
                  routeKm: _routeKm,
                  routeDur: _routeDur,
                  hasRoute: _route.isNotEmpty,
                  onFocus: () {
                    final p = state.selectedPin!;
                    _mapController.move(
                      LatLng(p.lat, p.lon),
                      _mapController.camera.zoom,
                    );
                  },
                  onClearRoute: () {
                    setState(() {
                      _route = const [];
                      _routeKm = null;
                      _routeDur = null;
                    });
                  },
                  onRoute: () async {
                    final sel = state.selectedPin!;
                    if (_user == null) {
                      await _locateUser();
                      if (_user == null) return;
                    }
                    final res = await _fetchOsrmRoute(
                      _user!,
                      LatLng(sel.lat, sel.lon),
                    );
                    if (res != null) {
                      setState(() {
                        _route = res.points;
                        _routeKm = res.km;
                        _routeDur = res.duration;
                      });
                      _fitToLatLngs(res.points);
                    }
                  },
                  onCopyCoords: () {
                    final p = state.selectedPin!;
                    final text =
                        '${p.lat.toStringAsFixed(5)}, ${p.lon.toStringAsFixed(5)}';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied: $text'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            );
            if (mounted) context.read<MapCubit>().selectPin(null);
            _isSheetOpen = false;
          }
        },
        buildWhen: (p, n) =>
            p.status != n.status ||
            p.error != n.error ||
            p.showArtists != n.showArtists ||
            p.showSpeakers != n.showSpeakers ||
            p.selectedPinId != n.selectedPinId,
        builder: (context, state) {
          final cubit = context.read<MapCubit>();
          final markers = _buildMarkers(state, cubit);

          return Scaffold(
            backgroundColor: _bg,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(25.276987, 55.296249),
                      initialZoom: 12.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onTap: (tapPos, latlng) =>
                          _handleMapTap(latlng, state, cubit),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _isDarkMode
                            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                            : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.baseqat.app',
                      ),

                      // tracking trail polyline (thin)
                      if (_trackingTrail.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _trackingTrail,
                              strokeWidth: 3,
                              color: Colors.black,
                              borderStrokeWidth: 1.5,
                              borderColor: Colors.white,
                            ),
                          ],
                        ),

                      // route polyline
                      if (_route.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _route,
                              strokeWidth: 8,
                              color: Colors.black,
                              borderStrokeWidth: 3,
                              borderColor: Colors.white,
                              gradientColors: [
                                Colors.black87,
                                Colors.black,
                                Colors.grey[900]!,
                              ],
                            ),
                          ],
                        ),

                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),

                // Responsive, all-buttons nav bar (top)
                Positioned(
                  left: 12.sW,
                  right: 12.sW,
                  top: MediaQuery.of(context).padding.top + 8.sH,
                  child: ResponsiveMapNavBar(
                    state: state,
                    onToggleArtists: () => cubit.toggleArtistsLayer(),
                    onToggleSpeakers: () => cubit.toggleSpeakersLayer(),
                    onRefresh: () => cubit.load(limit: 300),
                    onFitBounds: () => _fitToPins(state.visiblePins),
                    onLocate: _locateUser,
                    onZoomIn: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    ),
                    onZoomOut: () => _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    ),
                    onClearRoute: () {
                      setState(() {
                        _route = const [];
                        _routeKm = null;
                        _routeDur = null;
                      });
                    },
                    onRouteToSelected: () async {
                      final sel = state.selectedPin;
                      if (sel == null) return;
                      if (_user == null) {
                        await _locateUser();
                        if (_user == null) return;
                      }
                      final res = await _fetchOsrmRoute(
                        _user!,
                        LatLng(sel.lat, sel.lon),
                      );
                      if (res != null) {
                        setState(() {
                          _route = res.points;
                          _routeKm = res.km;
                          _routeDur = res.duration;
                        });
                        _fitToLatLngs(res.points);
                      }
                    },
                    onSearch: () => _toast('Search tapped'),
                    isTracking: _tracking,
                    onStartTracking: _startTracking,
                    onStopTracking: _stopTracking,
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                ),

                if (state.error != null && state.error!.isNotEmpty)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 100.sH,
                    left: 20.sW,
                    right: 20.sW,
                    child: _errorCard(state.error!, () => cubit.clearError()),
                  ),
              ],
            ),
            floatingActionButton: _themeFab(),
          );
        },
      ),
    );
  }

  // ---------- helpers ----------
  Widget _themeFab() {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
      child: Icon(
        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Colors.white,
      ),
    );
  }

  List<Marker> _buildMarkers(MapState state, MapCubit cubit) {
    final markers = <Marker>[];

    // user marker (white icon, black bubble, soft pulse)
    if (_user != null) {
      markers.add(
        Marker(
          point: _user!,
          width: 70,
          height: 70,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // pins (white icons)
    for (final p in state.visiblePins) {
      final isSelected = p.id == state.selectedPinId;
      final borderColor = _isDarkMode ? Colors.white : Colors.black;
      final size = isSelected ? 60.0 : 52.0;

      markers.add(
        Marker(
          point: LatLng(p.lat, p.lon),
          width: size,
          height: size,
          child: GestureDetector(
            onTap: () => cubit.selectPin(p.id),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(
                  p.kind == MapPinKind.artist
                      ? FontAwesomeIcons.palette
                      : FontAwesomeIcons.microphone,
                  color: Colors.white,
                  size: isSelected ? 24 : 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _handleMapTap(LatLng tap, MapState state, MapCubit cubit) {
    MapPin? nearest;
    double best = double.infinity;
    for (final p in state.visiblePins) {
      final dLat = (p.lat - tap.latitude).abs();
      final dLon = (p.lon - tap.longitude).abs();
      final score = dLat + dLon;
      if (score < best) {
        best = score;
        nearest = p;
      }
    }
    if (nearest != null && best < 0.004) {
      cubit.selectPin(nearest.id);
    } else {
      cubit.selectPin(null);
    }
  }

  Future<void> _locateUser() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() => _user = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_user!, 15);
    } catch (e) {
      _toast('Locate error: $e');
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _toast('Location service disabled');
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _toast('Location permission denied');
      return false;
    }
    return true;
  }

  void _fitToPins(List<MapPin> pins) {
    if (pins.isEmpty) return;
    _fitToLatLngs(pins.map((p) => LatLng(p.lat, p.lon)).toList());
  }

  void _fitToLatLngs(List<LatLng> pts) {
    if (pts.isEmpty) return;
    double? minLat, maxLat, minLon, maxLon;
    for (final p in pts) {
      minLat = (minLat == null) ? p.latitude : math.min(minLat, p.latitude);
      maxLat = (maxLat == null) ? p.latitude : math.max(maxLat, p.latitude);
      minLon = (minLon == null) ? p.longitude : math.min(minLon, p.longitude);
      maxLon = (maxLon == null) ? p.longitude : math.max(maxLon, p.longitude);
    }
    final bounds = LatLngBounds(
      LatLng(minLat!, minLon!),
      LatLng(maxLat!, maxLon!),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16.sW),
      ),
    );
  }

  Future<_RouteResult?> _fetchOsrmRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) {
        _toast('Route error: ${res.statusCode}');
        return null;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] as List);
      if (routes.isEmpty) {
        _toast('No route found');
        return null;
      }
      final r0 = routes.first as Map<String, dynamic>;
      final geo = r0['geometry'] as Map<String, dynamic>;
      final coords = (geo['coordinates'] as List).cast<List>();
      final points = coords
          .map(
            (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          )
          .toList();
      final km = ((r0['distance'] as num?)?.toDouble() ?? 0) / 1000.0;
      final secs = ((r0['duration'] as num?)?.toDouble() ?? 0).round();
      return _RouteResult(
        points: points,
        km: km,
        duration: Duration(seconds: secs),
      );
    } catch (e) {
      _toast('Route error: $e');
      return null;
    }
  }

  Widget _errorCard(String error, VoidCallback onDismiss) {
    return Container(
      padding: EdgeInsets.all(16.sW),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sW),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 12.sW),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[200] : Colors.grey[900],
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sSp,
                  ),
                ),
                Text(
                  error,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 13.sSp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close,
              color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteResult {
  final List<LatLng> points;
  final double km;
  final Duration duration;
  _RouteResult({
    required this.points,
    required this.km,
    required this.duration,
  });
}

// ---------- Bottom Sheet ----------
class _PinSheet extends StatefulWidget {
  const _PinSheet({
    required this.pin,
    required this.isDarkMode,
    required this.onFocus,
    required this.onRoute,
    required this.onClearRoute,
    required this.onCopyCoords,
    required this.routeKm,
    required this.routeDur,
    required this.hasRoute,
  });

  final MapPin pin;
  final bool isDarkMode;
  final VoidCallback onFocus;
  final VoidCallback onRoute;
  final VoidCallback onClearRoute;
  final VoidCallback onCopyCoords;
  final double? routeKm;
  final Duration? routeDur;
  final bool hasRoute;

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  bool _isRouting = false;

  Color get _fg => widget.isDarkMode ? Colors.white : Colors.black;
  Color get _sub => widget.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  Color get _panel =>
      widget.isDarkMode ? const Color(0xFF0B0B0B) : Colors.white;

  String _formatDuration(Duration? d) {
    if (d == null) return '—';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final isArtist = widget.pin.kind == MapPinKind.artist;

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.32,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.fromLTRB(16.sW, 12.sH, 16.sW, 16.sH),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _iconTile(isArtist),
                        SizedBox(width: 12.sW),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pin.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20.sSp,
                                  fontWeight: FontWeight.w800,
                                  color: _fg,
                                ),
                              ),
                              if ((widget.pin.subtitle ?? '').isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 6.sH),
                                  child: _chip(widget.pin.subtitle!),
                                ),
                            ],
                          ),
                        ),
                        _softX(context),
                      ],
                    ),
                    SizedBox(height: 16.sH),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: FontAwesomeIcons.route,
                            label: 'Distance',
                            value: widget.routeKm == null
                                ? '—'
                                : '${widget.routeKm!.toStringAsFixed(1)} km',
                          ),
                        ),
                        SizedBox(width: 10.sW),
                        Expanded(
                          child: _infoCard(
                            icon: FontAwesomeIcons.clock,
                            label: 'Duration',
                            value: _formatDuration(widget.routeDur),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sH),
                    _details(),
                    SizedBox(height: 18.sH),
                    Wrap(
                      spacing: 10.sW,
                      runSpacing: 10.sH,
                      children: [
                        _actionBtn(
                          icon: FontAwesomeIcons.crosshairs,
                          label: 'Focus',
                          onTap: widget.onFocus,
                        ),
                        _actionBtn(
                          icon: FontAwesomeIcons.personWalking,
                          label: 'Route',
                          onTap: _isRouting
                              ? null
                              : () async {
                                  setState(() => _isRouting = true);
                                  widget.onRoute();
                                  if (mounted)
                                    setState(() => _isRouting = false);
                                },
                          trailing: _isRouting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        _actionBtn(
                          icon: FontAwesomeIcons.eraser,
                          label: 'Clear',
                          onTap: widget.hasRoute ? widget.onClearRoute : null,
                        ),
                        _actionBtn(
                          icon: FontAwesomeIcons.copy,
                          label: 'Copy',
                          onTap: widget.onCopyCoords,
                        ),
                      ],
                    ),
                    SizedBox(height: 18.sH),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.sW,
                            vertical: 8.sH,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconTile(bool isArtist) {
    return Container(
      width: 60.sW,
      height: 60.sW,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: FaIcon(
          isArtist ? FontAwesomeIcons.palette : FontAwesomeIcons.microphone,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sW, vertical: 4.sH),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _softX(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(10.sW),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final base = widget.isDarkMode ? Colors.grey[850]! : Colors.grey[200]!;
    return Container(
      padding: EdgeInsets.all(14.sW),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.sW),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(height: 8.sH),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sSp,
              fontWeight: FontWeight.w800,
              color: _fg,
            ),
          ),
          SizedBox(height: 2.sH),
          Text(
            label,
            style: TextStyle(fontSize: 12.sSp, color: _sub),
          ),
        ],
      ),
    );
  }

  Widget _details() {
    final a = widget.pin.artist;
    final s = widget.pin.speaker;
    final rows = <Widget>[];

    if (a != null) {
      rows.addAll([
        _row(Icons.person, 'Type', 'Artist'),
        if ((a.country ?? '').isNotEmpty)
          _row(Icons.flag, 'Country', a.country!),
        if ((a.city ?? '').isNotEmpty)
          _row(Icons.location_city, 'City', a.city!),
        if ((a.about ?? '').isNotEmpty)
          _row(Icons.info_outline, 'About', a.about!, maxLines: 3),
      ]);
    }
    if (s != null) {
      rows.addAll([
        _row(Icons.mic, 'Type', 'Speaker'),
        if ((s.topicName ?? '').isNotEmpty)
          _row(Icons.label, 'Topic', s.topicName!),
        _row(
          Icons.calendar_today,
          'Schedule',
          '${_fmt(s.startAt)} - ${_fmt(s.endAt)}',
        ),
        if ((s.timezone ?? '').isNotEmpty)
          _row(Icons.public, 'Timezone', s.timezone),
        if ((s.city ?? '').isNotEmpty || (s.country ?? '').isNotEmpty)
          _row(
            Icons.place,
            'Location',
            '${s.city ?? "—"}, ${s.country ?? "—"}',
          ),
        if ((s.addressLine ?? '').isNotEmpty)
          _row(Icons.location_on, 'Address', s.addressLine!),
      ]);
    }
    rows.add(
      _row(
        Icons.gps_fixed,
        'Coordinates',
        '${widget.pin.lat.toStringAsFixed(5)}, ${widget.pin.lon.toStringAsFixed(5)}',
      ),
    );

    return Container(
      padding: EdgeInsets.all(14.sW),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(IconData icon, String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.sW),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          SizedBox(width: 12.sW),
          SizedBox(
            width: 96.sW,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sSp,
                fontWeight: FontWeight.w700,
                color: _sub,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sSp, color: _fg),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? Colors.black : Colors.grey[700],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sW, vertical: 10.sH),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              SizedBox(width: 8.sW),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 8.sW), trailing],
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $hh:$mm';
  }
}
