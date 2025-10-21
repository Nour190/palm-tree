import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/museum_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/resourses/navigation_manger.dart';
import '../../view/museum_details_page.dart';

class MuseumTabContent extends StatelessWidget {
  const MuseumTabContent({
    super.key,
    required this.museums,
    required this.artists,
    required this.languageCode,
  });

  final List<Museum> museums;
  final List<Artist> artists;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    if (museums.isEmpty) {
      return _EmptyMuseumState(context);
    }

    return Padding(
      padding: ProgramsLayout.pagePadding(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20.sR),
          border: Border.all(color: AppColor.primaryColor,width: 2.sSp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          separatorBuilder: (context,index){
            return Divider(color: AppColor.primaryColor,);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: museums.length,
          itemBuilder: (context, index) {
            final museum = museums[index];
            return _MuseumCard(
              museum: museum,
              artists: artists,
              languageCode: languageCode,
              onTap: () => _navigateToDetails(context, museum, artists),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, Museum museum, List<Artist> artists) {
    navigateTo(
      context,
      MuseumDetailsPage(
        museum: museum,
        artists: artists,
        languageCode: languageCode,
      ),
    );
  }

  Widget _EmptyMuseumState(BuildContext context) {
    return Center(
      child: Padding(
        padding: ProgramsLayout.sectionPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ProgramsLayout.size(context, 112),
              height: ProgramsLayout.size(context, 112),
              decoration: BoxDecoration(
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(
                  ProgramsLayout.radius20(context),
                ),
              ),
              child: Icon(
                Icons.museum_outlined,
                size: ProgramsLayout.size(context, 48),
                color: AppColor.gray500,
              ),
            ),
            SizedBox(height: ProgramsLayout.spacingLarge(context)),
            Text(
              'programs.museum.empty_title'.tr(),
              style: ProgramsTypography.headingMedium(context)
                  .copyWith(color: AppColor.gray700),
            ),
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
            Text(
              'programs.museum.empty_subtitle'.tr(),
              style: ProgramsTypography.bodySecondary(context)
                  .copyWith(color: AppColor.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MuseumCard extends StatefulWidget {
  const _MuseumCard({
    required this.museum,
    required this.artists,
    required this.languageCode,
    required this.onTap,
  });

  final Museum museum;
  final List<Artist> artists;
  final String languageCode;
  final VoidCallback onTap;

  @override
  State<_MuseumCard> createState() => _MuseumCardState();
}

class _MuseumCardState extends State<_MuseumCard> {


  @override
  Widget build(BuildContext context) {
    final radius = ProgramsLayout.radius20(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image
        Padding(
          padding:  EdgeInsets.all(20.sSp),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),

            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _MuseumImage(url: widget.museum.coverImage),
            ),
          ),
        ),

        // Museum Info
        Padding(
          padding: EdgeInsets.all(ProgramsLayout.spacingMedium(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Expand Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.museum.localizedName(
                        languageCode: widget.languageCode,
                      ),
                      style: ProgramsTypography.headingMedium(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),


                ],
              ),

              SizedBox(height: ProgramsLayout.spacingMedium(context)),

              // Artists
              if (widget.museum.artistIds.isNotEmpty)
                _InfoRow(
                  icon: Icons.people,
                  text: _getArtistNames(),
                ),

              if (widget.museum.artworkTypes.isNotEmpty) ...[
                SizedBox(height: ProgramsLayout.spacingSmall(context)),
                _InfoRow(
                  icon: Icons.palette,
                  text: widget.museum.artworkTypes.join(', '),
                ),
              ],

              SizedBox(height: ProgramsLayout.spacingSmall(context)),

              // Location
              _InfoRow(
                icon: Icons.location_pin,
                text: widget.museum.location,
              ),

              // Expanded Content

                SizedBox(height: 30.sH),



                // Description

                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 130.sW,
                    height: 70.sH,
                    child: ElevatedButton(
                      onPressed: widget.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black,
                        foregroundColor: AppColor.white,
                        padding: EdgeInsets.symmetric(
                          vertical: ProgramsLayout.spacingMedium(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.sR,
                          ),
                        ),
                      ),
                      child: Text(
                        'programs.museum.visit_now'.tr(),
                        style: ProgramsTypography.labelSmall(context)
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                ),

            ],
          ),
        ),
      ],
    );
  }

  String _getArtistNames() {
    final artistNames = widget.museum.artistIds
        .map((id) {
      final artist = widget.artists.firstWhere(
            (a) => a.id == id,
        orElse: () => Artist(
          id: id,
          name: 'Unknown',
          nameAr: 'غير معروف',
        ),
      );
      return artist.localizedName(languageCode: widget.languageCode);
    })
        .toList();
    return artistNames.join(' - ');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30.sSp,
          color: AppColor.primaryColor,
        ),
        SizedBox(width: ProgramsLayout.spacingSmall(context)),
        Expanded(
          child: Text(
            text,
            style: ProgramsTypography.bodySecondary(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
