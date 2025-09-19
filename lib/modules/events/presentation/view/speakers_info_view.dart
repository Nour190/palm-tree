import 'dart:async';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/speaker_model.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/resourses/assets_manager.dart';
import '../../../../core/resourses/style_manager.dart';

class SpeakersInfoScreen extends StatefulWidget {
  final Speaker speaker;
  const SpeakersInfoScreen({super.key, required this.speaker});

  @override
  State<SpeakersInfoScreen> createState() => _SpeakersInfoScreenState();
}

class _SpeakersInfoScreenState extends State<SpeakersInfoScreen> {
  bool _liked = false;

  // Map controller
  late MapController _mapController;

  // Location tracking
  StreamSubscription<Position>? _positionSubscription;
  GeoPoint? _currentPosition;
  GeoPoint? _venuePosition;
  bool _isTracking = false;
  bool _followUser = true;

  // Polyline and route data
  RoadInfo? _roadInfo;
  double? _distance;
  String? _duration;

  // Permission and error handling
  bool _locationPermissionGranted = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _initializeMap() {
    // Set venue position if available
    if (widget.speaker.latitude != null && widget.speaker.longitude != null) {
      _venuePosition = GeoPoint(
        latitude: widget.speaker.latitude!,
        longitude: widget.speaker.longitude!,
      );
    }

    // Initialize map controller
    _mapController = MapController(
      initPosition:
      _venuePosition ?? GeoPoint(latitude: 30.0444, longitude: 31.2357),
    );
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Location permissions are permanently denied';
      });
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final geoPoint = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _currentPosition = geoPoint;
      });

      // Add current location marker
      await _mapController.addMarker(
        geoPoint,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.my_location, color: Colors.blue, size: 32),
        ),
      );

      // Add venue marker if available
      if (_venuePosition != null) {
        await _mapController.addMarker(
          _venuePosition!,
          markerIcon: const MarkerIcon(
            icon: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        );

        // Draw route between current location and venue
        await _drawRoute();
      }

      // Center map to show both markers
      if (_venuePosition != null) {
        await _mapController.zoomToBoundingBox(
          BoundingBox(
            north:
            [
              geoPoint.latitude,
              _venuePosition!.latitude,
            ].reduce((a, b) => a > b ? a : b) +
                0.01,
            south:
            [
              geoPoint.latitude,
              _venuePosition!.latitude,
            ].reduce((a, b) => a < b ? a : b) -
                0.01,
            east:
            [
              geoPoint.longitude,
              _venuePosition!.longitude,
            ].reduce((a, b) => a > b ? a : b) +
                0.01,
            west:
            [
              geoPoint.longitude,
              _venuePosition!.longitude,
            ].reduce((a, b) => a < b ? a : b) -
                0.01,
          ),
        );
      } else {
        await _mapController.moveTo(geoPoint);
      }
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get current location: $e';
      });
    }
  }

  Future<void> _drawRoute() async {
    if (_currentPosition == null || _venuePosition == null) return;

    try {
      _roadInfo = await _mapController.drawRoad(
        _currentPosition!,
        _venuePosition!,
        roadType: RoadType.car,
        roadOption: const RoadOption(roadWidth: 10, roadColor: Colors.blue),
      );

      if (_roadInfo != null) {
        setState(() {
          _distance = _roadInfo!.distance;
          _duration = _roadInfo!.duration?.toString();
        });
      }
    } catch (e) {
      print('Error drawing route: $e');
    }
  }

  void _startLocationTracking() {
    if (!_locationPermissionGranted) {
      _checkLocationPermission();
      return;
    }

    setState(() {
      _isTracking = true;
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
              (Position position) async {
            final newPosition = GeoPoint(
              latitude: position.latitude,
              longitude: position.longitude,
            );

            setState(() {
              _currentPosition = newPosition;
            });

            // Update current location marker
            await _mapController.changeLocationMarker(
              oldLocation: _currentPosition ?? newPosition,
              newLocation: newPosition,
              markerIcon: const MarkerIcon(
                icon: Icon(Icons.navigation, color: Colors.blue, size: 32),
              ),
            );

            // Follow user if enabled
            if (_followUser) {
              await _mapController.moveTo(newPosition);
            }

            // Redraw route if venue exists
            if (_venuePosition != null) {
              await _drawRoute();
            }
          },
          onError: (e) {
            setState(() {
              _locationError = 'Location tracking error: $e';
              _isTracking = false;
            });
          },
        );
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    setState(() {
      _isTracking = false;
    });
  }

  void _toggleLocationTracking() {
    if (_isTracking) {
      _stopLocationTracking();
    } else {
      _startLocationTracking();
    }
  }

  void _toggleFollowUser() {
    setState(() {
      _followUser = !_followUser;
    });
  }

  void _centerOnUser() async {
    if (_currentPosition != null) {
      await _mapController.moveTo(_currentPosition!);
    }
  }

  void _centerOnVenue() async {
    if (_venuePosition != null) {
      await _mapController.moveTo(_venuePosition!);
    }
  }

  String _formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'N/A';
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String _formatDuration(String? duration) {
    if (duration == null) return 'N/A';
    // Parse duration and format it nicely
    return duration;
  }

  EdgeInsets _pagePadding(double w) {
    if (w >= 1200)
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (w >= 900)
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    if (w >= 600)
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  double _cardRadius(double w) => w >= 900 ? 16 : 12;

  void _onToggleLike() {
    setState(() => _liked = !_liked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_liked ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 800;
    final isDesktop = w >= 800;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
             // _buildResponsiveHeader(isMobile, isTablet, isDesktop),

              if (isDesktop)
                  _buildDesktopLayout(isMobile, isTablet, isDesktop)
              else
                _buildMobileTabletLayout(isMobile, isTablet, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(bool isMobile, bool isTablet, bool isDesktop) {
    final height = isDesktop ? 500.0.sH : isTablet ? 250.0.sH : 350.0.sH;
    final hasImage = (widget.speaker.profileImage ?? '').trim().isNotEmpty;
    final test = ( AppAssetsManager.imgProfile ?? '').trim().isNotEmpty;
    return Padding(
      padding:  isDesktop
          ?EdgeInsets.only(right: 0.sW)
          :EdgeInsets.symmetric( horizontal: 100.0.sH, vertical: 20.sW),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColor.backgroundGray,
          borderRadius: BorderRadius.circular((isDesktop ? 24 : 16))
        ),
        child: hasImage
            ? ClipRRect(
          borderRadius: BorderRadius.circular((isDesktop ? 24 : 16)),
          child:
          Image.network(
            widget.speaker.profileImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
              alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => Container(
              color: AppColor.backgroundGray,
              child: Icon(
                  Icons.person,
                  size: isDesktop ? 80 : 60,
                  color: AppColor.gray400
              ),
            ),
          ),

        )
            : Icon(
            Icons.person,
            size: isDesktop ? 80 : 60,
            color: AppColor.gray400
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(isMobile, isTablet, isDesktop) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
           SizedBox(height: 24.sH),
          Row(
            children: [
              Expanded(
                flex: 2,
                  child: _buildResponsiveHeader(isMobile, isTablet, isDesktop)),
              SizedBox(width:25.sW),
             // Spacer(),
              Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildTimeSection(true),
                       SizedBox(height: 40.sH),
                      _buildSpeakerDataCard(true),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildInfoCard(true),
                    //const SizedBox(height: 16),
                    //_buildLiveCard(true),

                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildLocationSection(true),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMobileTabletLayout(bool isMobile,isTablet, isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          _buildResponsiveHeader(isMobile, isTablet, isDesktop),
          _buildTimeSection(false),
          SizedBox(height: 16.sH),
          _buildInfoCard(false),
          SizedBox(height: 16.sH),
          //_buildLiveCard(false),
          SizedBox(height: 16.sH),
          SizedBox(height: 16.sH),
          SizedBox(height: 16.sH),
          _buildLocationSection(false),
          SizedBox(height: 16.sH),
        ],
      ),
    );
  }

  Widget _buildTimeSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: AppColor.blueGray100),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.speaker.name,
                  style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                   // fontSize: isDesktop ? 28 : 24,
                    color: AppColor.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.speaker.topicName != null)
                  Text(
                    widget.speaker.topicName!,
                    style: TextStyleHelper.instance.title16MediumInter.copyWith(
                    //  fontSize: isDesktop ? 18 : 16,
                      color: AppColor.gray700,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isDesktop ? 20 : 18,
                      color: AppColor.gray600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(widget.speaker.startAt),
                      style: TextStyleHelper.instance.body14RegularInter.copyWith(
                      //  fontSize: isDesktop ? 16 : 14,
                        color: AppColor.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _liked = !_liked),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _liked ? AppColor.red : AppColor.backgroundGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _liked ? Icons.favorite : Icons.favorite_border,
                color: _liked ? AppColor.white : AppColor.gray600,
                size: isDesktop ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  //
  // Widget _buildHeader(double w) {
  //   final height = w >= 900 ? 200.0 : 160.0;
  //   final hasImage = (widget.speaker.profileImage ?? '').trim().isNotEmpty;
  //
  //   return Container(
  //     width: double.infinity,
  //     height: height,
  //     color: AppColor.backgroundGray,
  //     child: hasImage
  //         ? Image.network(
  //       widget.speaker.profileImage!,
  //       fit: BoxFit.cover,
  //       errorBuilder: (_, __, ___) => Container(
  //         color: AppColor.backgroundGray,
  //         child: Icon(Icons.person, size: 60, color: AppColor.gray400),
  //       ),
  //     )
  //         : Icon(Icons.person, size: 60, color: AppColor.gray400),
  //   );
  // }
  //
  // Widget _buildTimeSectionOld(double w) {
  //   final status = TimeStatus.from(widget.speaker.startAt);
  //
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColor.white,
  //       borderRadius: BorderRadius.circular(_cardRadius(w)),
  //       border: Border.all(color: AppColor.blueGray100),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 48,
  //           height: 48,
  //           decoration: BoxDecoration(
  //             border: Border.all(color: AppColor.gray400),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(Icons.schedule, color: AppColor.gray700),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 TimeStatus.formatAbsolute(widget.speaker.startAt),
  //                 style: TextStyle(
  //                   fontSize: w >= 900 ? 18 : 16,
  //                   fontWeight: FontWeight.w600,
  //                   color: AppColor.gray900,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 status.label,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   color: status.color,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         IconButton(
  //           onPressed: _onToggleLike,
  //           icon: Icon(
  //             _liked ? Icons.favorite : Icons.favorite_border,
  //             color: _liked ? Colors.red : AppColor.gray700,
  //             size: 24,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoCard(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: AppColor.blueGray100),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the Session',
            style: TextStyleHelper.instance.headline28BoldInter
          ),
          const SizedBox(height: 12),
          if (widget.speaker.topicDescription != null)
            Text(
              widget.speaker.topicDescription!,
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
               // fontSize: isDesktop ? 16 : 14,
                color: AppColor.gray700,
                height: 1.5,
              ),
            ),
          if (widget.speaker.bio != null) ...[
            const SizedBox(height: 16),
            Text(
              'About the Speaker',
              style: TextStyleHelper.instance.title16BoldInter.copyWith(
                fontSize: isDesktop ? 18 : 16,
                color: AppColor.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.speaker.bio!,
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                //fontSize: isDesktop ? 16 : 14,
                color: AppColor.gray700,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildInfoCardOld(double w) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColor.white,
  //       borderRadius: BorderRadius.circular(_cardRadius(w)),
  //       border: Border.all(color: AppColor.blueGray100),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           widget.speaker.name,
  //           style: TextStyle(
  //             fontSize: w >= 900 ? 20 : 18,
  //             fontWeight: FontWeight.w600,
  //             color: AppColor.gray900,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           widget.speaker.bio?.toString() ?? 'No bio available',
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: AppColor.gray700,
  //             height: 1.5,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildLiveCard(bool isDesktop) {
  //   if (!widget.speaker.isLive) return const SizedBox.shrink();
  //
  //   final hasImage = (widget.speaker.profileImage ?? '').trim().isNotEmpty;
  //
  //   return Container(
  //     padding: EdgeInsets.all(isDesktop ? 20 : 16),
  //     decoration: BoxDecoration(
  //       color: AppColor.white,
  //       borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
  //       border: Border.all(color: Colors.red.withOpacity(0.3)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.red.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 8,
  //               height: 8,
  //               decoration: const BoxDecoration(
  //                 color: Colors.red,
  //                 shape: BoxShape.circle,
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Live Now',
  //               style: TextStyleHelper.instance.title16BoldInter.copyWith(
  //                 fontSize: isDesktop ? 18 : 16,
  //                 color: Colors.red,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             Container(
  //               width: isDesktop ? 70 : 60,
  //               height: isDesktop ? 70 : 60,
  //               decoration: BoxDecoration(
  //                 color: AppColor.gray400,
  //                 borderRadius: BorderRadius.circular(isDesktop ? 35 : 30),
  //                 image: hasImage
  //                     ? DecorationImage(
  //                   image: NetworkImage(widget.speaker.profileImage!),
  //                   fit: BoxFit.cover,
  //                 )
  //                     : null,
  //               ),
  //               child: !hasImage
  //                   ? Icon(
  //                   Icons.person,
  //                   color: AppColor.white,
  //                   size: isDesktop ? 35 : 30
  //               )
  //                   : null,
  //             ),
  //             const SizedBox(width: 16),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     widget.speaker.name,
  //                     style: TextStyleHelper.instance.title16BoldInter.copyWith(
  //                       fontSize: isDesktop ? 18 : 16,
  //                       color: AppColor.gray900,
  //                     ),
  //                   ),
  //                   if (widget.speaker.platform != null) ...[
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'Live on ${widget.speaker.platform}',
  //                       style: TextStyleHelper.instance.body14RegularInter.copyWith(
  //                         fontSize: isDesktop ? 14 : 12,
  //                         color: AppColor.gray600,
  //                       ),
  //                     ),
  //                   ],
  //                 ],
  //               ),
  //             ),
  //             if (widget.speaker.url != null)
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // Handle join live session
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.red,
  //                   foregroundColor: AppColor.white,
  //                   padding: EdgeInsets.symmetric(
  //                     horizontal: isDesktop ? 20 : 16,
  //                     vertical: isDesktop ? 12 : 10,
  //                   ),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Join Live',
  //                   style: TextStyleHelper.instance.body14RegularInter.copyWith(
  //                     fontSize: isDesktop ? 14 : 12,
  //                     color: AppColor.white,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildLiveCardOld(double w) {
  //   if (!widget.speaker.isLive) return const SizedBox.shrink();
  //
  //   final hasImage = (widget.speaker.profileImage ?? '').trim().isNotEmpty;
  //
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColor.white,
  //       borderRadius: BorderRadius.circular(_cardRadius(w)),
  //       border: Border.all(color: Colors.red.withOpacity(0.3)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               width: 8,
  //               height: 8,
  //               decoration: const BoxDecoration(
  //                 color: Colors.red,
  //                 shape: BoxShape.circle,
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Live Now',
  //               style: TextStyle(
  //                 fontSize: w >= 900 ? 18 : 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColor.gray900,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             Container(
  //               width: 60,
  //               height: 60,
  //               decoration: BoxDecoration(
  //                 color: AppColor.gray400,
  //                 borderRadius: BorderRadius.circular(30),
  //                 image: hasImage
  //                     ? DecorationImage(
  //                   image: NetworkImage(widget.speaker.profileImage!),
  //                   fit: BoxFit.cover,
  //                 )
  //                     : null,
  //               ),
  //               child: !hasImage
  //                   ? Icon(Icons.person, color: AppColor.white, size: 30)
  //                   : null,
  //             ),
  //             const SizedBox(width: 16),
  //             Expanded(
  //               child: Container(
  //                 height: 60,
  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
  //                 decoration: BoxDecoration(
  //                   color: AppColor.backgroundGray,
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: AppColor.blueGray100),
  //                 ),
  //                 child: Row(
  //                   children: List.generate(
  //                     6,
  //                         (i) => Expanded(
  //                       child: Container(
  //                         margin: const EdgeInsets.symmetric(horizontal: 2),
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Container(
  //                               width: 4,
  //                               height: 20 + (i * 4).toDouble(),
  //                               decoration: BoxDecoration(
  //                                 color: AppColor.gray700,
  //                                 borderRadius: BorderRadius.circular(2),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSpeakerDataCard(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        border: Border.all(color: AppColor.blueGray100),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speaker Details',
            style: TextStyleHelper.instance.headline20BoldInter.copyWith(
              fontSize: isDesktop ? 22 : 20,
              color: AppColor.gray900,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.speaker.organization != null)
            _buildDetailRow(
              'Organization',
              widget.speaker.organization!,
              isDesktop,
            ),
          if (widget.speaker.expertise != null)
            _buildDetailRow(
              'Expertise',
              widget.speaker.expertise!,
              isDesktop,
            ),
          if (widget.speaker.age != null)
            _buildDetailRow(
              'Age',
              '${widget.speaker.age} years',
              isDesktop,
            ),
          _buildDetailRow(
            'Session Duration',
            '${widget.speaker.endAt.difference(widget.speaker.startAt).inMinutes} minutes',
            isDesktop,
          ),
        ],
      ),
    );
  }

  // Widget _buildSpeakerDataCardOld(double w) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColor.white,
  //       borderRadius: BorderRadius.circular(_cardRadius(w)),
  //       border: Border.all(color: AppColor.blueGray100),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Speaker Details',
  //           style: TextStyle(
  //             fontSize: w >= 900 ? 18 : 16,
  //             fontWeight: FontWeight.w600,
  //             color: AppColor.gray900,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //
  //         // Speaker data rows
  //         _buildDataRow('ID', widget.speaker.id?.toString() ?? 'N/A'),
  //         if (widget.speaker.city != null)
  //           _buildDataRow('city', widget.speaker.city!),
  //         if (widget.speaker.country != null)
  //           _buildDataRow('country', widget.speaker.country!),
  //         _buildDataRow('Status', widget.speaker.isLive ? 'Live' : 'Offline'),
  //         if (widget.speaker.createdAt != null)
  //           _buildDataRow('Created', _formatDate(widget.speaker.createdAt!)),
  //         if (widget.speaker.updatedAt != null)
  //           _buildDataRow('Updated', _formatDate(widget.speaker.updatedAt!)),
  //
  //         // Coordinates if available
  //         if (widget.speaker.latitude != null &&
  //             widget.speaker.longitude != null) ...[
  //           const SizedBox(height: 12),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: AppColor.backgroundGray,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: AppColor.blueGray100),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Coordinates',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: AppColor.gray700,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'Latitude',
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               color: AppColor.gray600,
  //                             ),
  //                           ),
  //                           Text(
  //                             widget.speaker.latitude!.toStringAsFixed(6),
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.w500,
  //                               color: AppColor.gray900,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'Longitude',
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               color: AppColor.gray600,
  //                             ),
  //                           ),
  //                           Text(
  //                             widget.speaker.longitude!.toStringAsFixed(6),
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.w500,
  //                               color: AppColor.gray900,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.gray600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppColor.gray900),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildLocationSection(bool isDesktop) {
    final mapHeight = isDesktop ? 400.0 : 300.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location info and controls card
        Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            border: Border.all(color: AppColor.blueGray100),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      Icons.location_on,
                      color: AppColor.gray700,
                      size: isDesktop ? 26 : 24
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location & Navigation',
                          style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                            fontSize: isDesktop ? 20 : 18,
                            color: AppColor.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.speaker.addressLine ?? 'Address not available',
                          style: TextStyleHelper.instance.body14RegularInter.copyWith(
                            fontSize: isDesktop ? 16 : 14,
                            color: AppColor.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Route information
              if (_distance != null || _duration != null) ...[
                Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Distance: ${_formatDistance(_distance)}',
                        style: TextStyleHelper.instance.body14MediumInter.copyWith(
                          fontSize: isDesktop ? 14 : 12,
                          color: AppColor.gray900,
                        ),
                      ),
                      if (_duration != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: ${_formatDuration(_duration)}',
                          style: TextStyleHelper.instance.body14MediumInter.copyWith(
                            fontSize: isDesktop ? 14 : 12,
                            color: AppColor.gray900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Control buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildControlButton(
                    icon: _isTracking ? Icons.stop : Icons.play_arrow,
                    label: _isTracking ? 'Stop Tracking' : 'Start Tracking',
                    onTap: _toggleLocationTracking,
                    color: _isTracking ? Colors.red : Colors.green,
                    isDesktop: isDesktop,
                  ),
                  _buildControlButton(
                    icon: _followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
                    label: _followUser ? 'Following' : 'Follow User',
                    onTap: _toggleFollowUser,
                    color: _followUser ? Colors.blue : AppColor.gray600,
                    isDesktop: isDesktop,
                  ),
                  _buildControlButton(
                    icon: Icons.my_location,
                    label: 'Center on Me',
                    onTap: _centerOnUser,
                    isDesktop: isDesktop,
                  ),
                  if (_venuePosition != null)
                    _buildControlButton(
                      icon: Icons.location_pin,
                      label: 'Center on Venue',
                      onTap: _centerOnVenue,
                      isDesktop: isDesktop,
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // OSM Map with responsive sizing
        Container(
          height: mapHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            border: Border.all(color: AppColor.blueGray100),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            child: OSMFlutter(
              controller: _mapController,
              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(Icons.double_arrow, size: 48),
                  ),
                ),
                roadConfiguration: const RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              ),
              onMapIsReady: (isReady) {
                if (isReady) {
                  print("Map is ready");
                }
              },
              onLocationChanged: (myLocation) {
                print(
                  'User location: ${myLocation.latitude}, ${myLocation.longitude}',
                );
              },
              onGeoPointClicked: (geoPoint) {
                print(
                  'Clicked: ${geoPoint.latitude}, ${geoPoint.longitude}',
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSectionOld(double w) {
    final mapHeight = w >= 1200 ? 400.0 : (w >= 900 ? 350.0 : 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location info and controls card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(_cardRadius(w)),
            border: Border.all(color: AppColor.blueGray100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColor.gray700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location & Navigation',
                          style: TextStyle(
                            fontSize: w >= 900 ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.speaker.addressLine ?? 'Address not available',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Route information
              if (_distance != null || _duration != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Distance: ${_formatDistance(_distance)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColor.gray900,
                        ),
                      ),
                      if (_duration != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Duration: ${_formatDuration(_duration)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColor.gray900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Control buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildControlButton(
                    icon: _isTracking ? Icons.stop : Icons.play_arrow,
                    label: _isTracking ? 'Stop Tracking' : 'Start Tracking',
                    onTap: _toggleLocationTracking,
                    color: _isTracking ? Colors.red : Colors.green,
                  ),
                  _buildControlButton(
                    icon: _followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
                    label: _followUser ? 'Following' : 'Follow User',
                    onTap: _toggleFollowUser,
                    color: _followUser ? Colors.blue : AppColor.gray600,
                  ),
                  _buildControlButton(
                    icon: Icons.my_location,
                    label: 'Center on Me',
                    onTap: _centerOnUser,
                  ),
                  if (_venuePosition != null)
                    _buildControlButton(
                      icon: Icons.location_pin,
                      label: 'Center on Venue',
                      onTap: _centerOnVenue,
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // OSM Map
        Container(
          height: mapHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius(w)),
            border: Border.all(color: AppColor.blueGray100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_cardRadius(w)),
            child: OSMFlutter(
              controller: _mapController,
              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(Icons.double_arrow, size: 48),
                  ),
                ),
                roadConfiguration: const RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              ),
              onMapIsReady: (isReady) {
                if (isReady) {
                  print("Map is ready");
                }
              },
              onLocationChanged: (myLocation) {
                print(
                  'User location: ${myLocation.latitude}, ${myLocation.longitude}',
                );
              },
              onGeoPointClicked: (geoPoint) {
                print(
                  'Clicked on: ${geoPoint.latitude}, ${geoPoint.longitude}',
                );
              },
            ),
          ),
        ),

        // Error display
        if (_locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isDesktop = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? AppColor.backgroundGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color ?? AppColor.blueGray100,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isDesktop ? 18 : 16,
              color: color ?? AppColor.gray700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                fontSize: isDesktop ? 12 : 10,
                color: color ?? AppColor.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtonOld({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (color ?? AppColor.gray600).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (color ?? AppColor.gray600).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? AppColor.gray600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color ?? AppColor.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isDesktop ? 120 : 100,
            child: Text(
              label,
              style: TextStyleHelper.instance.body14MediumInter.copyWith(
                fontSize: isDesktop ? 14 : 12,
                color: AppColor.gray600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                fontSize: isDesktop ? 14 : 12,
                color: AppColor.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeStatus {
  final String label;
  final Color color;
  const TimeStatus(this.label, this.color);

  static TimeStatus from(DateTime startAt) {
    final now = DateTime.now();
    final diff = startAt.difference(now);
    if (diff.inMinutes >= 0 && diff.inMinutes <= 5) {
      return const TimeStatus('Starting now', Colors.orange);
    } else if (diff.isNegative) {
      final mins = diff.inMinutes.abs();
      if (mins < 60) return TimeStatus('Ended ${mins}m ago', Colors.grey);
      final hrs = mins ~/ 60;
      final rem = mins % 60;
      return TimeStatus('Ended ${hrs}h ${rem}m ago', Colors.grey);
    } else {
      final mins = diff.inMinutes;
      if (mins < 60) return TimeStatus('Starts in ${mins}m', Colors.green);
      final hrs = mins ~/ 60;
      final rem = mins % 60;
      return TimeStatus('Starts in ${hrs}h ${rem}m', Colors.green);
    }
  }

  static String formatAbsolute(DateTime dt) {
    final wdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final mons = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final wd = wdays[(dt.weekday - 1).clamp(0, 6)];
    final mo = mons[(dt.month - 1).clamp(0, 11)];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$wd, ${dt.day} $mo • $hh:$mm';
  }
}
