import 'dart:math' as math;
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';

class ResponsiveGallery extends StatefulWidget {
  const ResponsiveGallery({
    super.key,
    required this.imageUrls,
    this.title,
    this.padding,
    this.onSeeMore,
  });

  final List<String> imageUrls;
  final String? title;
  final EdgeInsets? padding;
  final VoidCallback? onSeeMore;

  @override
  State<ResponsiveGallery> createState() => _ResponsiveGalleryState();
}

class _ResponsiveGalleryState extends State<ResponsiveGallery>
    with TickerProviderStateMixin {
  late final AnimationController _appear;
  late final Animation<double> _fade;
  int? _hoveredIndex; // for desktop/web hover highlight

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _fade = CurvedAnimation(parent: _appear, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = Responsive.deviceTypeOf(context);

    // Columns per device
    final crossAxisCount = switch (device) {
      DeviceType.mobile => 3,
      DeviceType.tablet => 4,
      DeviceType.desktop => 6,
    };

    // Spacing/padding per device
    final horizontal = switch (device) {
      DeviceType.mobile => 16.sW,
      DeviceType.tablet => 24.sW,
      DeviceType.desktop => 40.sW,
    };
    final spacing = switch (device) {
      DeviceType.mobile => 12.sW,
      DeviceType.tablet => 16.sW,
      DeviceType.desktop => 20.sW,
    };

    // Pattern: one 2x2 tile followed by four 1x1 tiles, then repeat (inverted)
    final pattern = const [
      QuiltedGridTile(2, 2),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
      QuiltedGridTile(1, 1),
    ];

    final pad = widget.padding ?? EdgeInsets.symmetric(horizontal: horizontal);

    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((widget.title ?? '').trim().isNotEmpty)
            Padding(
              padding: pad.copyWith(bottom: 8.sH, top: 8.sH),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        fontSize: 18.sSp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.onSeeMore != null)
                    TextButton(
                      onPressed: widget.onSeeMore,
                      child: Text(
                        'See more',
                        style: TextStyleHelper.instance.body14RegularInter,
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: pad.copyWith(bottom: 8.sH),
            child: GridView.custom(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: pattern,
              ),
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                if (index >= widget.imageUrls.length) return const SizedBox();
                final url = widget.imageUrls[index];
                final heroTag = _heroTag(url, index);
                final isHovered = _hoveredIndex == index;
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: Semantics(
                    button: true,
                    label: 'Open gallery image ${index + 1}',
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _hoveredIndex = index),
                      onTapCancel: () => setState(() => _hoveredIndex = null),
                      onTapUp: (_) => setState(() => _hoveredIndex = null),
                      onTap: () => _openViewer(context, index),
                      child: AnimatedScale(
                        scale: isHovered ? 1.02 : 1.0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.sH),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.12 + (isHovered ? 0.12 : 0.0),
                                ),
                                blurRadius: 4 + (isHovered ? 6 : 0),
                                offset: Offset(0, 4.sH),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(tag: heroTag, child: _buildImage(url)),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                color: Colors.black.withOpacity(
                                  0.08 + (isHovered ? 0.12 : 0.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: widget.imageUrls.length),
            ),
          ),
        ],
      ),
    );
  }

  // === Helpers ===

  String _heroTag(String url, int index) => 'rg-hero-$index-$url';

  Widget _buildImage(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return const HomeImage(path: '');
    }
    return HomeImage(path: trimmed, fit: BoxFit.cover);
  }

  void _openViewer(BuildContext context, int index) {
    final pageCtrl = PageController(initialPage: index);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.92),
        pageBuilder: (_, __, ___) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: SafeArea(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: pageCtrl,
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, i) {
                      final url = widget.imageUrls[i];
                      final tag = _heroTag(url, i);

                      // fresh controller per page for clean double-tap zoom
                      final transform = TransformationController();
                      double lastScale = 1.0;

                      void toggleZoom(TapDownDetails d, BoxConstraints c) {
                        const zoomIn = 2.2;
                        const zoomOut = 1.0;
                        final tap = d.localPosition;
                        final to = (lastScale == 1.0) ? zoomIn : zoomOut;
                        lastScale = to;

                        final x = -tap.dx * (to - 1);
                        final y = -tap.dy * (to - 1);
                        transform.value = Matrix4.identity()
                          ..translate(x, y)
                          ..scale(to);
                      }

                      return Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onDoubleTapDown: (d) =>
                                  toggleZoom(d, constraints),
                              onDoubleTap: () {},
                              child: InteractiveViewer(
                                transformationController: transform,
                                minScale: 1,
                                maxScale: 4,
                                child: Hero(tag: tag, child: _buildImage(url)),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // Close
                  Positioned(
                    top: 12.sH,
                    right: 12.sW,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),

                  // Page indicator
                  Positioned(
                    bottom: 16.sH,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sW,
                          vertical: 6.sH,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20.sH),
                        ),
                        child: AnimatedBuilder(
                          animation: pageCtrl,
                          builder: (context, _) {
                            final p = pageCtrl.hasClients
                                ? (pageCtrl.page ?? index.toDouble())
                                : index.toDouble();
                            final cur = p.round();
                            return Text(
                              '${cur + 1} / ${widget.imageUrls.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sSp,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
