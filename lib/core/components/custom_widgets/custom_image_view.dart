import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resourses/color_manager.dart';
import '../../responsive/responsive.dart';

class CustomImageView extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BorderRadius? radius;
  final BoxFit fit;


  CustomImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.radius,
    this.fit = BoxFit.cover,
  });

  bool get _isNetwork {
    final p = imagePath.toLowerCase();
    return p.startsWith('http://') ||
        p.startsWith('https://') ||
        p.startsWith('data:');
  }

  bool get _isSvg {
    // robust: handles query strings and data URIs
    final lower = imagePath.toLowerCase().trimLeft();
    if (lower.startsWith('data:image/svg+xml')) return true;
    final parsed = Uri.tryParse(imagePath);
    final path = (parsed?.path.isNotEmpty ?? false) ? parsed!.path : imagePath;
    return path.toLowerCase().endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (_isSvg) {
      // ---- SVG branch ----
      if (_isNetwork) {
        image = SvgPicture.network(
          imagePath,
          height: height,
          width: width,
          fit: fit,
          placeholderBuilder: (_) => SizedBox(
            height: height,
            width: width,
            child:  Center(child: CircularProgressIndicator(
              color: AppColor.primaryColor,
            )),
          ),
        );
      } else {
        image = SvgPicture.asset(
          imagePath,
          height: height,
          width: width,
          fit: fit,
        );
      }
    } else {
      // ---- Raster branch (PNG/JPG/WebP/etc) ----
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
    }

    if (radius == null) return image;
    return ClipRRect(borderRadius: radius!, child: image);
  }
}
