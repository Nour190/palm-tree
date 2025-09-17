import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/events/presentation/widgets/art_works_widgets/art_work_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';

enum GalleryViewType { list, grid }

class ArtWorksGalleryContent extends StatefulWidget {
  final List<Artwork> artworks;
  final void Function(Artwork artwork)? onArtworkTap;

  // Optional empty-state customization
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final Widget? emptyStateIcon;

  // Optional pull-to-refresh
  final Future<void> Function()? onRefresh;

  const ArtWorksGalleryContent({
    super.key,
    required this.artworks,
    this.onArtworkTap,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onRefresh,
  });

  @override
  State<ArtWorksGalleryContent> createState() => _ArtWorksGalleryContentState();
}

class _ArtWorksGalleryContentState extends State<ArtWorksGalleryContent> {
  GalleryViewType _currentViewType = GalleryViewType.list;

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1200;

  int get _gridColumns {
    if (_isDesktop) return 3;
    if (_isTablet) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    // choose a sensible default view after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = MediaQuery.of(context).size.width;
      setState(() {
        _currentViewType = w < 768
            ? GalleryViewType.list
            : GalleryViewType.grid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = widget.artworks;

    // dynamic: show the view toggle automatically on tablet/desktop
    final showViewToggle = !_isMobile;

    return Column(
      children: [
        if (showViewToggle)
          Padding(
            padding: EdgeInsets.fromLTRB(
              _isMobile ? 16.h : 24.h,
              16.h,
              _isMobile ? 16.h : 24.h,
              8.h,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: _ViewToggle(
                value: _currentViewType,
                onChanged: (v) => setState(() => _currentViewType = v),
                isDark: isDark,
              ),
            ),
          ),
        Expanded(
          child: items.isEmpty
              ? _EmptyState(
                  title: widget.emptyStateTitle ?? 'No artworks available',
                  subtitle:
                      widget.emptyStateSubtitle ??
                      'Check back later for new artwork.',
                  icon: widget.emptyStateIcon,
                  isDark: isDark,
                )
              : _buildGallery(items),
        ),
      ],
    );
  }

  Widget _buildGallery(List<Artwork> items) {
    final scrollable = (_currentViewType == GalleryViewType.list)
        ? _buildList(items)
        : _buildGrid(items);

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        displacement: 24,
        child: scrollable,
      );
    }
    return scrollable;
  }

  Widget _buildList(List<Artwork> items) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: _isMobile ? 8.h : 16.h,
            vertical: 8.h,
          ),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: _isMobile ? 12.h : 16.h),
            itemBuilder: (context, i) {
              final a = items[i];
              return ArtWorkCardWidget(
                artwork: a,
                onTap: () {
                  print(a);
                  navigateTo(
                    context,
                    ArtWorkDetailsScreen(
                      artworkId: a.id,
                      userId: "d0030cf6-3830-47e8-9ca4-a2d00d51427a",
                      onBack: () => Navigator.pop(context),
                    ),
                  );
                },
                isGridView: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Artwork> items) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(_isMobile ? 8.h : 16.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridColumns,
              crossAxisSpacing: _isMobile ? 12.h : 20.h,
              mainAxisSpacing: _isMobile ? 12.h : 20.h,
              childAspectRatio: _isMobile ? 0.75 : 0.8,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final a = items[i];
              return ArtWorkCardWidget(
                artwork: a,
                onTap: () => widget.onArtworkTap?.call(a),
                isGridView: true,
              );
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final GalleryViewType value;
  final ValueChanged<GalleryViewType> onChanged;
  final bool isDark;

  const _ViewToggle({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isDark ? Colors.white : AppColor.gray900;
    final unselected = selectedColor.withOpacity(0.5);

    return SegmentedButton<GalleryViewType>(
      segments: const [
        ButtonSegment(
          value: GalleryViewType.list,
          icon: Icon(Icons.view_agenda_rounded),
          label: Text('List'),
        ),
        ButtonSegment(
          value: GalleryViewType.grid,
          icon: Icon(Icons.grid_view_rounded),
          label: Text('Grid'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? selectedColor
              : unselected;
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;
  final bool isDark;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = (isDark ? Colors.white : AppColor.gray900);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Icon(
                  Icons.palette_rounded,
                  size: 72.h,
                  color: color.withOpacity(0.3),
                ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.fSize,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.fSize,
                color: color.withOpacity(0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
