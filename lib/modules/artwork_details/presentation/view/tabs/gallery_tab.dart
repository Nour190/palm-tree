import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:url_launcher/url_launcher.dart';

/// GalleryTab
/// - Responsive grid (2/3/4 cols for mobile/tablet/web)
/// - Deduplicates incoming image list (keeps order)
/// - Tap -> full-screen lightbox (pinch to zoom, swipe, keyboard arrows)
/// - Hero transition, fade-in, error fallbacks
/// - Black is the primary accent (headers/overlays)
class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key, required this.images});

  /// Asset paths or http(s) URLs
  final List<String> images;

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  late final List<String> _items;

  @override
  void initState() {
    super.initState();
    // Stable de-duplication while keeping first occurrence order
    final seen = LinkedHashSet<String>();
    _items = [
      for (final p in widget.images)
        if (seen.add(p)) p,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final w = SizeUtils.width;
    final crossAxisCount = w >= 1200 ? 4 : (w >= 840 ? 3 : 2);
    final radius = 14.h;

    if (_items.isEmpty) {
      return _EmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        final path = _items[i];
        final isNetwork = path.startsWith('http');
        final heroTag = 'gallery:$path';

        Widget image;
        if (isNetwork) {
          image = _FadeInNetworkImage(url: path, fit: BoxFit.cover);
        } else {
          image = Image.asset(
            path,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          );
        }

        return Semantics(
          label: 'Image ${i + 1} of ${_items.length}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              onTap: () => _openLightbox(context, i),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: heroTag, child: image),
                  // Subtle hover/press overlay (desktop/web)
                  Positioned.fill(
                    child: _HoverOverlay(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.h,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(8.h),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openLightbox(BuildContext context, int startIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            _GalleryLightbox(images: _items, initialIndex: startIndex),
        transitionsBuilder: (context, animation, secondary, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }
}

/// Simple empty state
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColor.backgroundGray,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.photo_library_outlined, color: AppColor.gray600),
            SizedBox(width: 8),
            Text(
              'No images available',
              style: TextStyle(color: AppColor.gray600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fade-in network image with graceful error/placeholder
class _FadeInNetworkImage extends StatelessWidget {
  const _FadeInNetworkImage({required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      filterQuality: FilterQuality.low,
      frameBuilder: (context, child, frame, wasSync) {
        return AnimatedOpacity(
          opacity: wasSync || frame != null ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, event) {
        if (event == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColor.backgroundGray),
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                  value: event.expectedTotalBytes != null
                      ? event.cumulativeBytesLoaded / event.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColor.backgroundGray,
        child: Center(child: Icon(Icons.broken_image, color: AppColor.gray700)),
      ),
    );
  }
}

/// Hover overlay for desktop/web; transparent on mobile
class _HoverOverlay extends StatefulWidget {
  const _HoverOverlay({required this.child});
  final Widget child;

  @override
  State<_HoverOverlay> createState() => _HoverOverlayState();
}

class _HoverOverlayState extends State<_HoverOverlay> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = SizeUtils.width < 840;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: isMobile
            ? Colors.transparent
            : (_hover ? Colors.black.withOpacity(0.06) : Colors.transparent),
        child: widget.child,
      ),
    );
  }
}

/// Full-screen lightbox with swipe, pinch-zoom, keyboard controls, and actions
class _GalleryLightbox extends StatefulWidget {
  const _GalleryLightbox({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<_GalleryLightbox> {
  late final PageController _ctrl;
  late int _index;

  // Track scales per page so zoom state resets appropriately
  final Map<int, TransformationController> _transforms = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _ctrl = PageController(initialPage: _index);
    // Prefetch neighbors for smoother swipes
    _precacheAround(_index);
  }

  @override
  void dispose() {
    for (final t in _transforms.values) {
      t.dispose();
    }
    _ctrl.dispose();
    super.dispose();
  }

  void _precacheAround(int i) {
    // Best-effort; ignore errors
    if (!mounted) return;
    final ctx = context;
    Future<void> pre(String path) async {
      final provider = path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
      try {
        await precacheImage(provider, ctx);
      } catch (_) {
        /* ignore */
      }
    }

    pre(widget.images[i]);
    if (i - 1 >= 0) pre(widget.images[i - 1]);
    if (i + 1 < widget.images.length) pre(widget.images[i + 1]);
  }

  void _resetScale(int i) {
    _transforms[i] ??= TransformationController();
    _transforms[i]!.value = Matrix4.identity();
  }

  Future<void> _copyPath(String path) async {
    await Clipboard.setData(ClipboardData(text: path));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied')));
  }

  Future<void> _openInBrowser(String path) async {
    try {
      final ok = await launchUrl(
        Uri.parse(path),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_index + 1} / $total',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Copy path / Open in browser (for network images)
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_all),
            onPressed: () => _copyPath(widget.images[_index]),
          ),
          if (widget.images[_index].startsWith('http'))
            IconButton(
              tooltip: 'Open in browser',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openInBrowser(widget.images[_index]),
            ),
          SizedBox(width: 4.h),
        ],
      ),
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft):
              const PreviousFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            NextFocusIntent: CallbackAction<Intent>(
              onInvoke: (_) {
                if (_index < total - 1) {
                  _ctrl.nextPage(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                  );
                }
                return null;
              },
            ),
            PreviousFocusIntent: CallbackAction<Intent>(
              onInvoke: (_) {
                if (_index > 0) {
                  _ctrl.previousPage(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                  );
                }
                return null;
              },
            ),
            DismissIntent: CallbackAction<Intent>(
              onInvoke: (_) {
                Navigator.of(context).maybePop();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) {
                setState(() => _index = i);
                _precacheAround(i);
                _resetScale(i);
              },
              itemCount: total,
              itemBuilder: (context, i) {
                final path = widget.images[i];
                final isNetwork = path.startsWith('http');
                final heroTag = 'gallery:$path';

                _transforms[i] ??= TransformationController();

                Widget img = isNetwork
                    ? _FadeInNetworkImage(url: path, fit: BoxFit.contain)
                    : Image.asset(path, fit: BoxFit.contain);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () {
                    // Toggle zoom 1x <-> 2.5x centered
                    final t = _transforms[i]!;
                    final curr = t.value;
                    final isZoomed = curr.storage[0] > 1.01;
                    t.value = isZoomed ? Matrix4.identity() : Matrix4.identity()
                      ..scale(2.5);
                    setState(() {});
                  },
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: InteractiveViewer(
                        transformationController: _transforms[i],
                        minScale: 1,
                        maxScale: 4,
                        panEnabled: true,
                        scaleEnabled: true,
                        child: img,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _CaptionBar(path: widget.images[_index]),
    );
  }
}

/// Bottom caption bar showing filename/last segment; black-primary look.
class _CaptionBar extends StatelessWidget {
  const _CaptionBar({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    String label = path;
    // Pull last segment for URLs and assets
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.pathSegments.isNotEmpty)) {
      label = uri.pathSegments.last;
    } else {
      final parts = path.split(RegExp(r'[\\/]+'));
      if (parts.isNotEmpty) label = parts.last;
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 10.h),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
