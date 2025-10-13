import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Enhanced image widget with caching for home module
/// Images are cached automatically and won't reload on subsequent visits
class CachedHomeImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorChild;

  const CachedHomeImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorChild,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
            ),
          ),
      errorWidget: (context, url, error) =>
          errorChild ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 48,
            ),
          ),
      // Cache configuration
      maxHeightDiskCache: 1000,
      maxWidthDiskCache: 1000,
      memCacheHeight: 500,
      memCacheWidth: 500,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
