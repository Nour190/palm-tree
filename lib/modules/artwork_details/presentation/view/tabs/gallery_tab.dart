import 'dart:collection';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({
    super.key,
    required this.images,
    this.title,
    this.about,
    this.hero,
  });

  final List<String> images;
  final String? title;
  final String? about;
  final String? hero;

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  late final List<String> _items;

  @override
  void initState() {
    super.initState();
    final seen = LinkedHashSet<String>();
    _items = [
      for (final p in widget.images)
        if (seen.add(p)) p,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((widget.about ?? '').isNotEmpty) ...[
          SizedBox(height: 10.h),
          _AboutBlock(text: widget.about!),
          SizedBox(height: 12.h),
        ],
        if (_items.isEmpty)
          _EmptyState()
        else
          _GalleryLayout(items: _items, onTap: _openLightbox),
      ],
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

class _GalleryLayout extends StatelessWidget {
  const _GalleryLayout({required this.items, required this.onTap});

  final List<String> items;
  final Function(BuildContext, int) onTap;

  @override
  Widget build(BuildContext context) {
    final radius = 20.h;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final path = items[index];
        final isNetwork = path.startsWith('http');
        final heroTag = 'gallery:$path';

        Widget image = isNetwork
            ? _FadeInNetworkImage(url: path, fit: BoxFit.cover)
            : Image.asset(path, fit: BoxFit.cover, filterQuality: FilterQuality.low);

        final position = index % 5;
        final isSingleImage = position == 0 || position == 1 || position == 3 || position == 4;

        if (isSingleImage) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _GalleryImageCard(
              heroTag: heroTag,
              image: image,
              radius: radius,
              height: 300.h,
              onTap: () => onTap(context, index),
              index: index,
              total: items.length,
            ),
          );
        } else {
          if (index + 1 < items.length) {
            final nextPath = items[index + 1];
            final nextIsNetwork = nextPath.startsWith('http');
            final nextHeroTag = 'gallery:$nextPath';

            Widget nextImage = nextIsNetwork
                ? _FadeInNetworkImage(url: nextPath, fit: BoxFit.cover)
                : Image.asset(nextPath, fit: BoxFit.cover, filterQuality: FilterQuality.low);

            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: _GalleryImageCard(
                      heroTag: heroTag,
                      image: image,
                      radius: radius,
                      height: 160.h,
                      onTap: () => onTap(context, index),
                      index: index,
                      total: items.length,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Expanded(
                    child: _GalleryImageCard(
                      heroTag: nextHeroTag,
                      image: nextImage,
                      radius: radius,
                      height: 160.h,
                      onTap: () => onTap(context, index + 1),
                      index: index + 1,
                      total: items.length,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _GalleryImageCard(
                heroTag: heroTag,
                image: image,
                radius: radius,
                height: 300.h,
                onTap: () => onTap(context, index),
                index: index,
                total: items.length,
              ),
            );
          }
        }
      },
    );
  }
}

class _GalleryImageCard extends StatelessWidget {
  const _GalleryImageCard({
    required this.heroTag,
    required this.image,
    required this.radius,
    required this.height,
    required this.onTap,
    required this.index,
    required this.total,
  });

  final String heroTag;
  final Widget image;
  final double radius;
  final double height;
  final VoidCallback onTap;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'image_semantics'
          .tr(namedArgs: {'index': '${index + 1}', 'total': '$total'}),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Hero(tag: heroTag, child: image),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: AppColor.backgroundGray,
        borderRadius: BorderRadius.circular(24.h),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, color: AppColor.gray600),
            const SizedBox(width: 8),
            Text('no_images'.tr(),
                style: const TextStyle(color: AppColor.gray600)),
          ],
        ),
      ),
    );
  }
}

class _AboutBlock extends StatefulWidget {
  const _AboutBlock({required this.text});
  final String text;

  @override
  State<_AboutBlock> createState() => _AboutBlockState();
}

class _AboutBlockState extends State<_AboutBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final body = widget.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about_artist'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          body,
          style: const TextStyle(color: AppColor.gray700, height: 1.6, fontSize: 15),
          maxLines: _expanded ? null : 6,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (body.length > 320) ...[
          SizedBox(height: 6.h),
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18),
            label: Text(_expanded ? 'show_less'.tr() : 'read_more'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ],
    );
  }
}

class _FadeInNetworkImage extends StatelessWidget {
  const _FadeInNetworkImage({required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      filterQuality: FilterQuality.low,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeInCurve: Curves.easeOut,
      placeholder: (context, url) => Stack(
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
              ),
            ),
          ),
        ],
      ),
      errorWidget: (context, url, error) => const ColoredBox(
        color: AppColor.backgroundGray,
        child: Center(child: Icon(Icons.broken_image_outlined, color: AppColor.gray700)),
      ),
    );
  }
}

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

  final Map<int, TransformationController> _transforms = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _ctrl = PageController(initialPage: _index);
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
    if (!mounted) return;
    final ctx = context;
    Future<void> pre(String path) async {
      final provider = path.startsWith('http')
          ? NetworkImage(path)
          : AssetImage(path) as ImageProvider;
      try {
        await precacheImage(provider, ctx);
      } catch (_) {}
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('copied'.tr())),
    );
  }

  Future<void> _openInBrowser(String path) async {
    try {
      final ok = await launchUrl(Uri.parse(path), mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_open'.tr())),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('invalid_link'.tr())),
        );
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
          tooltip: 'close'.tr(),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${_index + 1} / $total',
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'copy'.tr(),
            icon: const Icon(Icons.copy_all),
            onPressed: () => _copyPath(widget.images[_index]),
          ),
          if (widget.images[_index].startsWith('http'))
            IconButton(
              tooltip: 'open_in_browser'.tr(),
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _openInBrowser(widget.images[_index]),
            ),
          SizedBox(width: 4.h),
        ],
      ),
      body: PageView.builder(
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
              final t = _transforms[i]!;
              final curr = t.value;
              final isZoomed = curr.storage[0] > 1.01;
              t.value =
              isZoomed ? Matrix4.identity() : Matrix4.identity()..scale(2.5);
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
      bottomNavigationBar: _CaptionBar(path: widget.images[_index]),
    );
  }
}

class _CaptionBar extends StatelessWidget {
  const _CaptionBar({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    String label = path;
    final uri = Uri.tryParse(path);
    if (uri != null && uri.pathSegments.isNotEmpty) {
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
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ),
    );
  }
}

class NextFocusIntent extends Intent {}

class PreviousFocusIntent extends Intent {}

class DismissIntent extends Intent {}
