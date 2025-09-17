import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({
    super.key,
    required this.title, // e.g. artwork/collection title
    required this.about, // long paragraph
    this.materials, // optional long paragraph
    this.vision, // optional long paragraph
    this.galleryImages = const [], // asset or network urls
  });

  final String title;
  final String about;
  final String? materials;
  final String? vision;
  final List<String> galleryImages;

  @override
  Widget build(BuildContext context) {
    final s = TextStyleHelper.instance;

    // Build sections in order and drop empties.
    final sections = <MapEntry<String, String>>[
      MapEntry(title, about),
      if ((materials ?? '').trim().isNotEmpty)
        MapEntry('Materials', materials!.trim()),
      if ((vision ?? '').trim().isNotEmpty) MapEntry('Vision', vision!.trim()),
    ];

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text sections
          for (int i = 0; i < sections.length; i++) ...[
            _buildSection(
              title: sections[i].key,
              body: sections[i].value,
              styles: s,
            ),
            if (i != sections.length - 1) SizedBox(height: 16.h),
          ],

          if (galleryImages.isNotEmpty) SizedBox(height: 16.h),

          // First hero-ish image (optional)
          if (galleryImages.isNotEmpty)
            _buildRoundedImage(path: galleryImages.first, height: 304),

          if (galleryImages.length > 1) SizedBox(height: 12.h),

          // Remaining images in a light, lazy horizontal scroller (if any)
          if (galleryImages.length > 1)
            SizedBox(
              height: 160.h,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: galleryImages.length - 1,
                separatorBuilder: (_, __) => SizedBox(width: 12.h),
                itemBuilder: (_, idx) {
                  final img = galleryImages[idx + 1];
                  return _buildRoundedImage(path: img, height: 160);
                },
              ),
            ),

          if (galleryImages.isNotEmpty) SizedBox(height: 12.h),

          // Closing line (optional UX flourish)
          Text(
            'Subtle craftsmanship that stands up to daily use.',
            style: s.title16LightInter.copyWith(color: AppColor.gray900),
          ),
        ],
      ),
    );
  }

  // ---- Private builders (stay inside AboutTab) ----

  Widget _buildSection({
    required String title,
    required String body,
    required TextStyleHelper styles,
  }) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: ValueKey<String>('about_title_$title'),
            style: styles.headline24MediumInter.copyWith(
              color: AppColor.gray900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            body,
            key: ValueKey<String>('about_body_${title.hashCode}'),
            style: styles.title16LightInter.copyWith(
              color: AppColor.gray900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedImage({required String path, required double height}) {
    final radius = BorderRadius.circular(18.h);
    final isNetwork = path.startsWith('http');

    final Widget child = isNetwork
        ? Image.network(
            path,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            frameBuilder: (context, widget, frame, wasSync) {
              return AnimatedOpacity(
                opacity: wasSync || frame != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: widget,
              );
            },
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Colors.black12),
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          );

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(height: height.h, width: double.infinity, child: child),
    );
  }
}
