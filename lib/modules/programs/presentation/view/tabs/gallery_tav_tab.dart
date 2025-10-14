import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/modules/programs/data/models/gallery_item.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';

class GalleryGrid extends StatelessWidget {
  const GalleryGrid({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<GalleryItem> items;
  final void Function(GalleryItem item)? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyGallery();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
        constraints.maxWidth >= ProgramsBreakpoints.tablet ? 3 : 2;
        final spacing = ProgramsLayout.spacingLarge(context);

        return GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: ProgramsLayout.pagePadding(context).left,
            vertical: spacing,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _GalleryTile(
              item: item,
              onTap: () => _openViewer(context, item),
            );
          },
        );
      },
    );
  }

  void _openViewer(BuildContext context, GalleryItem item) {
    onTap?.call(item);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _GalleryViewer(item: item),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.item, this.onTap});

  final GalleryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = ProgramsLayout.radius20(context);

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: item.imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GalleryImage(url: item.imageUrl),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.all(ProgramsLayout.spacingMedium(context)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    item.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProgramsTypography.bodyPrimary(context)
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return OfflineCachedImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: const ColoredBox(
        color: Color(0xFFE7E7E7),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      errorWidget: const ColoredBox(
        color: Colors.black12,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black45),
        ),
      ),
    );
  }
}

class _GalleryViewer extends StatefulWidget {
  const _GalleryViewer({required this.item});
  final GalleryItem item;

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ProgramsLayout.spacingLarge(context);

    return GestureDetector(
      onTap: Navigator.of(context).pop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: Hero(
                    tag: widget.item.imageUrl,
                    child: InteractiveViewer(
                      transformationController: _controller,
                      minScale: 1,
                      maxScale: 3,
                      child: _GalleryImage(url: widget.item.imageUrl),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  widget.item.artistName,
                  textAlign: TextAlign.center,
                  style: ProgramsTypography.headingMedium(context)
                      .copyWith(color: Colors.white),
                ),
                SizedBox(height: ProgramsLayout.spacingMedium(context)),
                Text(
                  widget.item.artistName ?? '',
                  textAlign: TextAlign.center,
                  style: ProgramsTypography.bodySecondary(context)
                      .copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    final spacingLarge = ProgramsLayout.spacingLarge(context);
    final radius = ProgramsLayout.radius20(context);

    return Center(
      child: Padding(
        padding: ProgramsLayout.sectionPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ProgramsLayout.size(context, 112),
              height: ProgramsLayout.size(context, 112),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: ProgramsLayout.size(context, 48),
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: spacingLarge),
            Text(
              'No Images Yet',
              style: ProgramsTypography.headingMedium(context)
                  .copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
            Text(
              'Your gallery will appear here',
              style: ProgramsTypography.bodySecondary(context)
                  .copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
