import 'package:flutter/material.dart';

class AnimatedCarouselItemWidget extends StatelessWidget {
  const AnimatedCarouselItemWidget({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
  });

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double t = 0;
        if (controller.position.haveDimensions) {
          final page = controller.page ?? controller.initialPage.toDouble();
          t = page - index;
        }
        // Closer to 0 => current page
        final scale = (1 - (t.abs() * 0.08)).clamp(0.9, 1.0);
        final opacity = (1 - (t.abs() * 0.35)).clamp(0.55, 1.0);

        return RepaintBoundary(
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity, child: child),
          ),
        );
      },
    );
  }
}
