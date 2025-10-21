import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';

import '../../../../../core/utils/rtl_helper.dart';

class MuseumDetailsPage extends StatelessWidget {
  const MuseumDetailsPage({
    super.key,
    required this.museum,
    required this.artists,
    required this.languageCode,
  });

  final Museum museum;
  final List<Artist> artists;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Back Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.sW,
                  vertical: ProgramsLayout.spacingMedium(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Iconify(
                        RTLHelper.isRTL(context)
                            ? MaterialSymbols.arrow_forward_rounded
                            : MaterialSymbols.arrow_back_rounded,
                        color: Colors.black,
                        size: 32.sW,
                      ),
                    ),
                    Text(
                      museum.localizedName(languageCode: languageCode),
                      style: ProgramsTypography.headingLarge(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 32.sW),
                  ],
                ),
              ),

              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  ProgramsLayout.radius20(context),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: ProgramsLayout.pagePadding(context).left,
                    ),
                    child: _MuseumImage(url: museum.coverImage),
                  ),
                ),
              ),

              SizedBox(height: ProgramsLayout.spacingLarge(context)),

              // Museum Info
              Padding(
                padding: ProgramsLayout.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      museum.localizedName(languageCode: languageCode),
                      style: ProgramsTypography.headingLarge(context),
                    ),

                    SizedBox(height: ProgramsLayout.spacingMedium(context)),

                    // Artists
                    if (museum.artistIds.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.people_alt_outlined,
                        label: 'programs.museum.artists'.tr(),
                        value: _getArtistNames(),
                      ),
                      SizedBox(height: ProgramsLayout.spacingMedium(context)),
                    ],

                    // Artwork Types
                    if (museum.artworkTypes.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.palette_outlined,
                        label: 'programs.museum.artwork_types'.tr(),
                        value: museum.artworkTypes.join(', '),
                      ),
                      SizedBox(height: ProgramsLayout.spacingMedium(context)),
                    ],

                    // Location
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'programs.museum.location'.tr(),
                      value: museum.location,
                    ),

                    SizedBox(height: ProgramsLayout.spacingLarge(context)),

                    // Description
                    if (museum.localizedDescription(
                          languageCode: languageCode,
                        ) !=
                        null) ...[
                      Text(
                        'programs.museum.description'.tr(),
                        style: ProgramsTypography.labelSmall(context)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: ProgramsLayout.spacingSmall(context)),
                      Text(
                        museum.localizedDescription(
                          languageCode: languageCode,
                        )!,
                        style: ProgramsTypography.bodySecondary(context),
                      ),
                    ],

                    SizedBox(height: ProgramsLayout.spacingLarge(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getArtistNames() {
    final artistNames = museum.artistIds
        .map((id) {
          final artist = artists.firstWhere(
            (a) => a.id == id,
            orElse: () => Artist(
              id: id,
              name: 'Unknown',
              nameAr: 'غير معروف',
            ),
          );
          return artist.name;
        })
        .toList();
    return artistNames.join(' - ');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: ProgramsLayout.size(context, 20),
              color: AppColor.gray600,
            ),
            SizedBox(width: ProgramsLayout.spacingSmall(context)),
            Text(
              label,
              style: ProgramsTypography.labelSmall(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: ProgramsLayout.spacingSmall(context)),
        Text(
          value,
          style: ProgramsTypography.bodySecondary(context),
        ),
      ],
    );
  }
}

class _MuseumImage extends StatelessWidget {
  const _MuseumImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.gray50,
      child: url != null && url!.isNotEmpty
          ? OfflineCachedImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: Container(
                color: AppColor.gray100,
                child: const Center(
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: Container(
                color: AppColor.gray100,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColor.gray500,
                  ),
                ),
              ),
            )
          : Container(
              color: AppColor.gray100,
              child: Center(
                child: Icon(
                  Icons.museum_outlined,
                  size: ProgramsLayout.size(context, 48),
                  color: AppColor.gray400,
                ),
              ),
            ),
    );
  }
}
