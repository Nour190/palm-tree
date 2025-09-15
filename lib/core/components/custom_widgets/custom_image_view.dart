import 'package:flutter/material.dart';

class CustomImageView extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BorderRadius? radius;
  final BoxFit fit;

  const CustomImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.radius,
    this.fit = BoxFit.cover,
  });

  bool get _isNetwork {
    final p = imagePath.toLowerCase();
    return p.startsWith('http://') || p.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (_isNetwork) {
      image = Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        // Loading spinner
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        // Error fallback
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: Icon(Icons.broken_image_outlined)),
          );
        },
      );
    } else {
      image = Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined),
            ),
          );
        },
      );
    }

    if (radius == null) return image;
    return ClipRRect(borderRadius: radius!, child: image);
  }
}
