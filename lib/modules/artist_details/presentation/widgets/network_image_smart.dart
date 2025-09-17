import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class NetworkImageSmart extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final BorderRadius? radius;

  const NetworkImageSmart({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.radius,
  });

  bool _isNet(String p) => p.startsWith('http://') || p.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final fallback = AppAssetsManager.imgPlaceholder;
    final src = (path == null || path!.isEmpty) ? fallback : path!;
    final r = radius ?? BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: r,
      child: _isNet(src)
          ? Image.network(
              src,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _skeleton();
              },
              errorBuilder: (context, error, stackTrace) => _errorIcon(),
            )
          : Image.asset(src, fit: fit),
    );
  }

  Widget _skeleton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.gray50, AppColor.gray100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _errorIcon() {
    return Container(
      color: AppColor.gray50,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColor.gray400,
        size: 40,
      ),
    );
  }
}
