import 'package:baseqat/core/components/custom_widgets/cached_network_image_widget.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/programs/data/models/gallery_item.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

import '../../../../../core/resourses/navigation_manger.dart';

const List<String> kArtworkTypes = [
  'All',
  'Photography',
  'Eastern Art',
  'Drawings',
  'Abstract Art',
  'Old Masters',
  'Sculpture',
  'Digital Art',
];

const Map<String, IconData> kCategoryIcons = {
  'All': Icons.grid_view_rounded,
  'Photography': Icons.camera_alt_outlined,
  'Eastern Art': Icons.image_outlined,
  'Drawings': Icons.palette_outlined,
  'Abstract Art': Icons.crop_square_rounded,
  'Old Masters': Icons.apple_outlined,
  'Sculpture': Icons.view_in_ar_outlined,
  'Digital Art': Icons.computer_outlined,
};

class GalleryGrid extends StatefulWidget {
  const GalleryGrid({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<GalleryItem> items;
  final void Function(GalleryItem item)? onTap;

  @override
  State<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> {
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<GalleryItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return widget.items;
    }
    return widget.items.where((item) {
      final type = item.artworkType ?? 'All';
      return type.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const _EmptyGallery();
    }

    final filteredItems = _filteredItems;

    return Column(
      children: [
        _CategoryFilterBar(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        SizedBox(height: ProgramsLayout.spacingLarge(context)),

        Expanded(
          child: filteredItems.isEmpty
              ? _EmptyCategoryState(category: _selectedCategory)
              : _MasonryGalleryGrid(
            items: filteredItems,
            onTap: (item, index) => _openFullScreenViewer(context, item, index, filteredItems),
          ),
        ),
      ],
    );
  }

  void _openFullScreenViewer(
      BuildContext context,
      GalleryItem item,
      int initialIndex,
      List<GalleryItem> allItems,
      ) {
    widget.onTap?.call(item);

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenGalleryViewer(
          item: item,
          initialImageIndex: 0,
          allGalleryItems: allItems,
          initialGalleryItemIndex: initialIndex,
        ),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProgramsLayout.size(context, 100),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ProgramsLayout.pagePadding(context).left,
        ),
        itemCount: kArtworkTypes.length,
        itemBuilder: (context, index) {
          final category = kArtworkTypes[index];
          final isSelected = category == selectedCategory;
          final icon = kCategoryIcons[category] ?? Icons.category_outlined;

          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: ProgramsLayout.spacingMedium(context),
            ),
            child: _CategoryChip(
              label: category,
              icon: icon,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final circleSize = ProgramsLayout.size(context, 56);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circleSize / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: isSelected ? AppColor.black : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColor.black : AppColor.gray400,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: ProgramsLayout.size(context, 24),
              color: isSelected ? AppColor.white : AppColor.gray700,
            ),
          ),
          SizedBox(height: ProgramsLayout.spacingSmall(context)),
          SizedBox(
            width: circleSize + 20,
            child: Text(
              label,
              style: ProgramsTypography.bodySecondary(context).copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColor.black : AppColor.gray700,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasonryGalleryGrid extends StatelessWidget {
  const _MasonryGalleryGrid({
    required this.items,
    required this.onTap,
  });

  final List<GalleryItem> items;
  final Function(GalleryItem, int) onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = ProgramsLayout.spacingMedium(context);
    final padding = ProgramsLayout.pagePadding(context).left;
    final isTablet = ProgramsBreakpoints.isTablet(context);

    final crossAxisCount = isTablet ? 3 : 2;

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: isTablet ? 0.75 : 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final heightFactor = _getHeightFactor(index);

        return _GalleryTile(
          item: item,
          heightFactor: heightFactor,
          onTap: () => onTap(item, index),
        );
      },
    );
  }

  double _getHeightFactor(int index) {
    final pattern = [1.15, 0.9, 0.95, 1.1, 0.85, 1.05];
    return pattern[index % pattern.length];
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.item,
    required this.heightFactor,
    this.onTap,
  });

  final GalleryItem item;
  final double heightFactor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = ProgramsLayout.radius20(context);

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'gallery_${item.imageUrl}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: AspectRatio(
            aspectRatio: 1 / heightFactor,
            child: _GalleryImage(url: item.imageUrl),
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
    return Container(
      color: AppColor.gray50,
      child: OfflineCachedImage(
        imageUrl: url,
        fit: BoxFit.cover,
        //alignment: Alignment.center,
        placeholder: Container(
          color: AppColor.gray100,
          child: const Center(
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: Container(
          color: AppColor.gray100,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: AppColor.gray500),
          ),
        ),
      ),
    );
  }
}

class _FullScreenGalleryViewer extends StatefulWidget {
  const _FullScreenGalleryViewer({
    required this.item,
    required this.initialImageIndex,
    required this.allGalleryItems,
    required this.initialGalleryItemIndex,
  });

  final GalleryItem item;
  final int initialImageIndex;
  final List<GalleryItem> allGalleryItems;
  final int initialGalleryItemIndex;

  @override
  State<_FullScreenGalleryViewer> createState() => _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<_FullScreenGalleryViewer> {
  late PageController _pageController;
  late int _currentImageIndex;
  late GalleryItem _currentItem;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _currentImageIndex = widget.initialImageIndex;
    _pageController = PageController(initialPage: _currentImageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  List<String> get _currentGallery => _currentItem.fullGallery.isNotEmpty
      ? _currentItem.fullGallery
      : [_currentItem.imageUrl];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                    _transformController.value = Matrix4.identity();
                  });
                },
                itemCount: _currentGallery.length,
                itemBuilder: (context, index) {
                  final imageUrl = _currentGallery[index];
                  return GestureDetector(
                    onDoubleTap: () {
                      final currentScale = _transformController.value.getMaxScaleOnAxis();
                      if (currentScale > 1.0) {
                        _transformController.value = Matrix4.identity();
                      } else {
                        _transformController.value = Matrix4.identity()..scale(2.5);
                      }
                      setState(() {});
                    },
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Hero(
                          tag: index == widget.initialImageIndex
                              ? 'gallery_${widget.item.imageUrl}'
                              : 'gallery_image_$index',
                          child: OfflineCachedImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: Container(
                              color: Colors.black,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: Container(
                              color: Colors.black,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white54,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(ProgramsLayout.spacingMedium(context)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      '${_currentImageIndex + 1} / ${_currentGallery.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(ProgramsLayout.spacingLarge(context)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentItem.artworkName,
                      style: ProgramsTypography.headingMedium(context).copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_currentItem.artistName != null) ...[
                      SizedBox(height: ProgramsLayout.spacingSmall(context)),
                      Text(
                        _currentItem.artistName!,
                        style: ProgramsTypography.bodySecondary(context).copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    SizedBox(height: ProgramsLayout.spacingLarge(context)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (_currentItem.artworkId.isNotEmpty) {
                            navigateTo(
                              context,
                              ArtWorkDetailsScreen(
                                artworkId: _currentItem.artworkId,
                                userId: 'anonymous',
                                initialTabIndex: 0,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.info_outline),
                        label: Text('view_artwork_details'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: ProgramsLayout.spacingLarge(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ProgramsLayout.radius16(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: ProgramsLayout.size(context, 48),
                color: AppColor.gray500,
              ),
            ),
            SizedBox(height: spacingLarge),
            Text(
              'programs.gallery.empty_title'.tr(),
              style: ProgramsTypography.headingMedium(context)
                  .copyWith(color: AppColor.gray700),
            ),
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
            Text(
              'programs.gallery.empty_subtitle'.tr(),
              style: ProgramsTypography.bodySecondary(context)
                  .copyWith(color: AppColor.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ProgramsLayout.sectionPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off,
              size: ProgramsLayout.size(context, 64),
              color: AppColor.gray400,
            ),
            SizedBox(height: ProgramsLayout.spacingLarge(context)),
            Text(
              'programs.gallery.no_items_in_category'.tr(namedArgs: {'category': category}),
              style: ProgramsTypography.headingMedium(context)
                  .copyWith(color: AppColor.gray600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
