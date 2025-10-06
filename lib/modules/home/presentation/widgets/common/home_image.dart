import 'package:flutter/material.dart';

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';


class HomeImage extends StatelessWidget {
  const HomeImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorChild,
    this.filterQuality = FilterQuality.high,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorChild;
  final FilterQuality filterQuality;

  bool get _looksLikeNetwork {
    final lower = path.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) return _wrapWithSizing(_errorFallback());

    if (_looksLikeNetwork) {
      return _wrapWithSizing(
        Image.network(
          path,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _wrapWithSizing(_placeholder());
          },
          errorBuilder: (context, error, stackTrace) =>
              _wrapWithSizing(_errorFallback()),
        ),
      );
    }

    return _wrapWithSizing(
      Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
            _wrapWithSizing(_errorFallback()),
      ),
    );
  }

  Widget _wrapWithSizing(Widget child) {
    final widget = borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: child)
        : child;

    if (width == null && height == null) return widget;
    return SizedBox(width: width, height: height, child: widget);
  }

  Widget _placeholder() {
    if (placeholder != null) return placeholder!;
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColor.gray100),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColor.gray400,
          size: 32.sSp,
        ),
      ),
    );
  }

  Widget _errorFallback() {
    if (errorChild != null) return errorChild!;
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black12),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white.withOpacity(0.75),
          size: 28.sSp,
        ),
      ),
    );
  }
}
