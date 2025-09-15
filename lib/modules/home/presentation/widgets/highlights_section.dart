import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';

class HighlightsSection extends StatelessWidget {
  final InfoModel highlights;

  const HighlightsSection({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeaderWidget(
            title: 'Highlights',
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 16.h),
          CarouselSlider.builder(
            itemCount: highlights.images.length,
            options: CarouselOptions(
              height: 350.h,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
            ),
            itemBuilder: (_, index, __) {
              return CustomImageView(
                imagePath: highlights.images[index],
                height: 350.h,
                width: double.infinity,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(24.h),
              );
            },
          ),
        ],
      ),
    );
  }
}
