import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class ArtistCardWidget extends StatelessWidget {
  final Artist artist;
  final double? size;

  const ArtistCardWidget({super.key, required this.artist, this.size});

  @override
  Widget build(BuildContext context) {
    final cardSize = size ?? 116.h;

    return Column(
      children: [
        CustomImageView(
          imagePath: artist.profileImage!,
          height: cardSize,
          width: cardSize,
          radius: BorderRadius.circular(cardSize / 2),
          fit: BoxFit.cover,
        ),
        SizedBox(height: 8.h),
        Text(
          artist.name,
          style: TextStyleHelper.instance.title16MediumInter.copyWith(
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class ArtistsSection extends StatelessWidget {
  final List<Artist> artists;
  final String title;
  final EdgeInsetsGeometry? headerPadding;
  final double? itemSize;

  const ArtistsSection({
    super.key,
    required this.artists,
    this.title = 'Artists',
    this.headerPadding,
    this.itemSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeaderWidget(
          title: title,
          padding: headerPadding ?? EdgeInsets.symmetric(horizontal: 24.h),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: (itemSize ?? 116.h) + 44.h, // image + name + spacing
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.h),
            itemCount: artists.length,
            separatorBuilder: (_, __) => SizedBox(width: 24.h),
            itemBuilder: (_, index) {
              return ArtistCardWidget(
                artist: artists[index],
                size: itemSize ?? 120.h,
              );
            },
          ),
        ),
      ],
    );
  }
}
