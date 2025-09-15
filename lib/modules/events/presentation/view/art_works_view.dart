import 'package:baseqat/modules/events/presentation/widgets/art_works_widgets/art_work_card_widget.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class ArtWorksGalleryContent extends StatelessWidget {
  final List<Artwork> artworks;
  final void Function(Artwork artwork)? onArtworkTap;

  const ArtWorksGalleryContent({
    super.key,
    required this.artworks,
    this.onArtworkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // vertical spacing belongs to the shell; keep horizontal here
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      child: ListView.separated(
        itemCount: artworks.length,
        separatorBuilder: (_, __) => SizedBox(height: 24.h),
        itemBuilder: (context, index) => ArtWorkCardWidget(
          artwork: artworks[index],
          onTap: () => onArtworkTap?.call(artworks[index]),
        ),
      ),
    );
  }
}
