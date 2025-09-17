import 'package:baseqat/modules/artist_details/presentation/widgets/artist_about_card.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/artist_gallery_grid.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/artist_header.dart';
import 'package:baseqat/modules/artist_details/presentation/widgets/artist_info_card.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

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
  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  @override
  Widget build(BuildContext context) {
    final padding = _isMobile
        ? 16.0
        : _isTablet
        ? 24.0
        : 32.0;
    final spacing = _isMobile ? 24.0 : 32.0;

    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1350),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArtistHeader(name: widget.name, image: widget.profileImage),
                  SizedBox(height: spacing),
                  if (_isMobile) ArtistAboutCard(about: widget.about),
                  if (_isMobile) SizedBox(height: spacing),
                  _isMobile
                      ? ArtistInfoCard(
                          age: widget.age,
                          country: widget.country,
                          city: widget.city,
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: ArtistAboutCard(about: widget.about),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 4,
                              child: ArtistInfoCard(
                                age: widget.age,
                                country: widget.country,
                                city: widget.city,
                              ),
                            ),
                          ],
                        ),
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
