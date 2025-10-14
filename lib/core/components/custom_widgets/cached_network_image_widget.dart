import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:baseqat/core/database/image_cache_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OfflineCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OfflineCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get cached image first
    final Uint8List? cachedBytes = ImageCacheService.getCachedImage(imageUrl);

    if (cachedBytes != null) {
      // Display cached image
      return Image.memory(
        cachedBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    }

    // Fallback to network image with caching
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      // Cache image when loaded
      imageBuilder: (context, imageProvider) {
        // Cache in background
        ImageCacheService.cacheImage(imageUrl).catchError((e) {
          debugPrint('[OfflineCachedImage] Error caching image: $e');
        });
        
        return Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
