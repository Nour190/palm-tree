import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';

class HeroImage extends StatelessWidget {
  const HeroImage({super.key, this.height = 304, this.path});

  final double height;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final String imgPath = path ?? AppAssetsManager.imgRectangle2;
    return RoundedImage(path: imgPath, height: height);
  }
}

class RoundedImage extends StatelessWidget {
  const RoundedImage({super.key, required this.path, required this.height});

  final String path;
  final double height;

  bool get isNetwork => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.h),
      child: SizedBox(
        height: height.h,
        width: double.infinity,
        child: isNetwork
            ? Image.network(
                path,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              )
            : Image.asset(
                path,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
      ),
    );
  }
}
