import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';

class CustomImageView extends StatelessWidget {
  final String imagePath; // URL or asset
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? radius;

  const CustomImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.radius,
  });

  bool get _isNetwork =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final Widget img = _isNetwork
        ? Image.network(
            imagePath,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) => _placeholder(),
            loadingBuilder: (ctx, child, progress) =>
                progress == null ? child : _placeholder(loading: true),
          )
        : Image.asset(
            imagePath,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) => _notFound(),
          );

    return radius == null ? img : ClipRRect(borderRadius: radius!, child: img);
  }

  Widget _placeholder({bool loading = false}) => SizedBox(
    height: height,
    width: width,
    child: loading
        ? const ColoredBox(
            color: Color(0xFFF2F2F2),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        : Image.asset(AppAssetsManager.imgPlaceholder, fit: BoxFit.cover),
  );

  Widget _notFound() => SizedBox(
    height: height,
    width: width,
    child: Image.asset(AppAssetsManager.imgImageNotFound, fit: BoxFit.cover),
  );
}
