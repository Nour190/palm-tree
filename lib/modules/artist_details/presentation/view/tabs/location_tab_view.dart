import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class LocationTab extends StatelessWidget {
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

  /// Can be asset or network path.
  final String? mapImage;

  final VoidCallback? onStartNavigation;

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
            title,
            style: s.headline24MediumInter.copyWith(color: AppColor.gray900),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: s.title16LightInter.copyWith(color: AppColor.gray900),
          ),

          SizedBox(height: sectionGap),

          // Distance Row
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h),
                child: SizedBox(
                  width: walkIconBoxW,
                  height: 64.h,
                  child: Center(
                    child: Icon(
                      Icons.directions_walk,
                      size: walkIconSize,
                      color: AppColor.gray900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    distanceLabel,
                    style: s.headline24MediumInter.copyWith(
                      color: AppColor.gray900,
                    ),
                  ),
                  Text(
                    destinationLabel,
                    style: s.title16LightInter.copyWith(
                      color: AppColor.gray900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: sectionGap),

          // Map/Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24.h),
            child: Container(
              height: mapHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.h),
                border: Border.all(color: AppColor.gray900, width: 1),
              ),
              child: _buildMapPreview(),
            ),
          ),

          SizedBox(height: sectionGap),

          SizedBox(
            width: double.infinity,
            height: isMobile ? 64.h : 80.h,
            child: ElevatedButton(
              onPressed: () {
                if (onStartNavigation != null) {
                  onStartNavigation!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Starting navigation to '
                        '${latitude != null && longitude != null ? '$latitude,$longitude' : (addressLine ?? 'destination')} …',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.gray900,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.h),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.h, vertical: 16.h),
              ),
              child: Text(
                'Start Now',
                style:
                    (isMobile
                            ? s.headline24MediumInter
                            : s.headline32MediumInter)
                        .copyWith(color: AppColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    if (mapImage == null) {
      return const Center(
        child: Icon(Icons.map, color: AppColor.gray900, size: 64),
      );
    }
    if (mapImage!.startsWith('http')) {
      return Image.network(
        mapImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(Icons.map, color: AppColor.gray900, size: 64),
          );
        },
      );
    }
    return Image.asset(mapImage!, fit: BoxFit.cover);
  }
}
