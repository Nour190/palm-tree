import 'package:baseqat/core/components/alerts/custom_loading.dart';
import 'package:baseqat/core/components/connectivity/offline_indicator.dart';
import 'package:baseqat/core/network/connectivity_service.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_page.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/data/models/event_model.dart';
import 'package:baseqat/modules/programs/presentation/manger/events/events_cubit.dart';
import 'package:baseqat/modules/programs/presentation/manger/events/events_state.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:baseqat/modules/programs/presentation/widgets/events_widgets/event_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class EventsTabContent extends StatefulWidget {
  final List<Event> events;
  final List<Artist> artists;
  final List<Artwork> artworks;
  final String languageCode;

  const EventsTabContent({
    required this.events,
    required this.artists,
    required this.artworks,
    required this.languageCode,
    Key? key,
  }) : super(key: key);

  @override
  State<EventsTabContent> createState() => _EventsTabContentState();
}

class _EventsTabContentState extends State<EventsTabContent> {
  int? _expandedEventIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ProgramsLayout.spacingLarge(context)),
          child: Text(
            'No events available',
            style: ProgramsTypography.bodyPrimary(context),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: ProgramsLayout.pagePadding(context),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.events.length,
      itemBuilder: (context, index) {
        final event = widget.events[index];
        final isExpanded = _expandedEventIndex == index;

        return Column(
          children: [
            EventCardWidget(
              event: event,
              isExpanded: isExpanded,
              onExpandToggle: () {
                setState(() {
                  _expandedEventIndex = isExpanded ? null : index;
                });
              },
              languageCode: widget.languageCode,
            ),
            if (isExpanded) ...[
              SizedBox(height: ProgramsLayout.spacingMedium(context)),
              EventDetailsWidget(
                event: event,
                artists: widget.artists,
                artworks: widget.artworks,
                languageCode: widget.languageCode,
              ),
            ],
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
          ],
        );
      },
    );
  }
}

class EventDetailsWidget extends StatelessWidget {
  final Event event;
  final List<Artist> artists;
  final List<Artwork> artworks;
  final String languageCode;

  const EventDetailsWidget({
    required this.event,
    required this.artists,
    required this.artworks,
    required this.languageCode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventArtworks = artworks
        .where((a) => event.artworkIds.contains(a.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.overviewImages != null && event.overviewImages!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(
              ProgramsLayout.radius16(context),
            ),
            child: Image.network(
              event.overviewImages!,
              height: 250.sH,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200.sH,
                  color: AppColor.gray200,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColor.gray400,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: ProgramsLayout.spacingMedium(context)),
        ],

        // Overview Text
        if (event.overview != null || event.overviewAr != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style:TextStyleHelper.instance.body18MediumInter,
              ),
              SizedBox(height: ProgramsLayout.spacingSmall(context)),
              Text(
                event.localizedOverview(languageCode: languageCode) ?? '',
                style: TextStyleHelper.instance.title16RegularInter,
              ),
            ],
          ),
          SizedBox(height: ProgramsLayout.spacingLarge(context)),
        ],

        if (eventArtworks.isNotEmpty) ...[
          Text(
            'Artist Gallery',
            style:TextStyleHelper.instance.headline20BoldInter,
          ),
          SizedBox(height: ProgramsLayout.spacingMedium(context)),
          Column(
            children: List.generate(
              eventArtworks.length,
                  (index) {
                final artwork = eventArtworks[index];
                final artist = artists.firstWhere(
                      (a) => a.id == artwork.artistId,
                  orElse: () => Artist(
                    id: '',
                    name: '',
                    profileImage: '',
                  ),
                );
                return ArtworkGalleryCard(
                  artwork: artwork,
                  artist: artist,
                  languageCode: languageCode,
                  onTap: () {
                    navigateTo(
                      context,
                      ArtistDetailsPage(artistId: artist.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class ArtworkGalleryCard extends StatelessWidget {
  final Artwork artwork;
  final Artist artist;
  final String languageCode;
  final VoidCallback onTap;

  const ArtworkGalleryCard({
    required this.artwork,
    required this.artist,
    required this.languageCode,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artwork Image
          ClipRRect(
            borderRadius: BorderRadius.circular(
              ProgramsLayout.radius16(context),
            ),
            child: Container(
              width: double.infinity,
              height: 180.sH,
              color: AppColor.gray200,
              child: artwork.gallery.isNotEmpty
                  ? Image.network(
                artwork.gallery[0],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColor.gray200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColor.gray400,
                    ),
                  );
                },
              )
                  : Icon(
                Icons.image_not_supported,
                color: AppColor.gray400,
              ),
            ),
          ),

          SizedBox(height:20.sH),

          // Artist Info Row - Avatar and Name in same row
          SizedBox(
            width: 180.sW,
            child: Row(

              children: [
                // Artist Avatar
                ClipOval(
                  child: Container(
                    width: 32.sW,
                    height: 32.sW,
                    color: AppColor.gray200,
                    child: artist.profileImage != null && artist.profileImage!.isNotEmpty
                        ? Image.network(
                      artist.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColor.gray400,
                          child: Icon(
                            Icons.person,
                            color: AppColor.gray400,
                            size: 16.sW,
                          ),
                        );
                      },
                    )
                        : Icon(
                      Icons.person,
                      color: AppColor.gray400,
                      size: 16.sW,
                    ),
                  ),
                ),
                SizedBox(width: 8.sW),

                // Artist Name
                Column(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.localizedName(languageCode: languageCode),
                      style: TextStyleHelper.instance.title16BoldInter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    //SizedBox(height: ProgramsLayout.spacingMedium(context)),

                    Text(
                      artist.localizedName(languageCode: languageCode),
                      style: TextStyleHelper.instance.body14RegularInter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
