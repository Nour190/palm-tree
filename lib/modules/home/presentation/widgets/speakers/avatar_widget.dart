import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.imagePath,
    required this.size,
  });

  final String imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomImageView(
      imagePath: imagePath,
      height: size,
      width: size,
      radius: BorderRadius.circular(size / 2),
    );
  }
}
