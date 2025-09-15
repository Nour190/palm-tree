import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key, required this.images});

  /// Asset paths or http(s) URLs
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final w = SizeUtils.width;
    final crossAxisCount = w >= 1200 ? 4 : (w >= 840 ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        final path = images[i];
        final isNetwork = path.startsWith('http');

        Widget child;
        if (isNetwork) {
          child = Image.network(
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
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: AppColor.backgroundGray,
              child: Center(
                child: Icon(Icons.broken_image, color: AppColor.gray700),
              ),
            ),
          );
        } else {
          child = Image.asset(
            path,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(14.h),
          child: child,
        );
      },
    );
  }
}
