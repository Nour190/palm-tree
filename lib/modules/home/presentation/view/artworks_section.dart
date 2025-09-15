import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class ArtworksSection extends StatelessWidget {
  final List<Artwork> artworks;
  final String title;
  final EdgeInsetsGeometry? headerPadding;
  final double? cardWidth;

  const ArtworksSection({
    super.key,
    required this.artworks,
    this.title = 'Art Works',
    this.headerPadding,
    this.cardWidth,
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
          height: 420.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.h),
            itemCount: artworks.length,
            separatorBuilder: (_, __) => SizedBox(width: 20.h),
            itemBuilder: (_, index) {
              return ArtworkCardWidget(
                artwork: artworks[index],
                width: cardWidth ?? 320.h,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ArtworkCardWidget extends StatelessWidget {
  final Artwork artwork;
  final double? width;

  const ArtworkCardWidget({super.key, required this.artwork, this.width});

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? 296.h;

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(
            imagePath: artwork.artistProfileImage!,
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(24.h),
          ),
          SizedBox(height: 16.h),
          Text(
            artwork.name,
            style: TextStyleHelper.instance.headline24BoldInter.copyWith(
              height: 1.25,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            artwork.description!,
            style: TextStyleHelper.instance.title16LightInter.copyWith(
              color: AppColor.gray900,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  artwork.artistName!,
                  style: TextStyleHelper.instance.title16MediumInter.copyWith(
                    height: 1.25,
                  ),
                ),
              ),
              CustomImageView(
                imagePath: artwork.artistProfileImage!,
                height: 40.h,
                width: 40.h,
                radius: BorderRadius.circular(20.h),
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
