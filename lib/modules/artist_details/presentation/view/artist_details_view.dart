import 'package:baseqat/modules/artist_details/presentation/widgets/artist_about_card.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/artist_gallery_grid.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/artist_header.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/artist_info_card.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;

class ArtistDetailsView extends StatefulWidget {
  final String name;
  final String? profileImage;
  final int? age;
  final String? about;
  final String? country;
  final String? city;
  final List<String> gallery;

  const ArtistDetailsView({
    super.key,
    required this.name,
    this.profileImage,
    this.age,
    this.about,
    this.country,
    this.city,
    this.gallery = const <String>[],
  });

  @override
  State<ArtistDetailsView> createState() => _ArtistDetailsViewState();
}

class _ArtistDetailsViewState extends State<ArtistDetailsView>
    with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);


    return deviceType == DeviceType.desktop
        ? _buildDesktopLayout()
        : _buildMobileTabletLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.h, vertical: 32.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1400.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop header with side-by-side layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Image
                      Expanded(
                        flex: 2,
                        child: ArtistHeader(name: widget.name, image: widget.profileImage),
                      ),
                      SizedBox(width: 48.h),
                      // Right side - Info cards
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            SizedBox(height: 80.h), // Align with header text
                            ArtistInfoCard(
                              age: widget.age,
                              country: widget.country,
                              city: widget.city,
                            ),
                            SizedBox(height: 24.h),
                            ArtistAboutCard(about: widget.about),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
                  // Gallery section
                  ArtistGalleryGrid(gallery: widget.gallery),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTabletLayout() {
    final deviceType = Responsive.deviceTypeOf(context);
    final isMobile = deviceType == DeviceType.mobile;
    final spacing = isMobile ? 24.h : 32.h;
    final padding = isMobile ? 16.h : 24.h;

    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArtistHeader(name: widget.name, image: widget.profileImage),
                  SizedBox(height: spacing),
                  ArtistInfoCard(
                    age: widget.age,
                    country: widget.country,
                    city: widget.city,
                  ),
                  SizedBox(height: spacing),
                  ArtistAboutCard(about: widget.about),
                  SizedBox(height: spacing),
                  ArtistGalleryGrid(gallery: widget.gallery),
                  SizedBox(height: spacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
