import 'package:baseqat/modules/events/presentation/widgets/artist_widgets/artist_card_widget.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class ArtistTabContent extends StatelessWidget {
  final List<Artist> artists;
  final void Function(Artist artist)? onArtistTap;

  const ArtistTabContent({super.key, required this.artists, this.onArtistTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      child: ListView.separated(
        itemCount: artists.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) => ArtistCardWidget(
          artist: artists[index],
          onTap: () => onArtistTap?.call(artists[index]),
        ),
      ),
    );
  }
}
