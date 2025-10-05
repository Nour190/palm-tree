// ===================== ArtWorksGalleryContent (Enhanced, Bigger Fonts) =====================
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:baseqat/modules/events/presentation/manger/events/events_cubit.dart';
import 'package:baseqat/modules/events/presentation/widgets/art_works_widgets/art_work_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';

/// Gallery list/grid with accessible, larger text by default.
/// - Global text scaling via [textScaleFactor] (affects cards too)
/// - Scrollbar, better responsiveness, safer defaults
class ArtWorksGalleryContent extends StatefulWidget {
  final List<Artwork> artworks;
  final void Function(Artwork artwork)? onArtworkTap;
  final String userId;
  final void Function(Artwork artwork)? onFavoriteTap;

  // Optional empty-state customization
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final Widget? emptyStateIcon;

  // Optional pull-to-refresh
  final Future<void> Function()? onRefresh;

  /// Scales all text inside this widget (including inside cards).
  /// 1.0 = system default. Big by default (1.30).
  final double textScaleFactor;

  /// Show a scrollbar when scrolling.
  final bool enableScrollbar;

  const ArtWorksGalleryContent({
    super.key,
    required this.artworks,
    required this.userId,
    this.onArtworkTap,
    this.onFavoriteTap,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onRefresh,
    this.textScaleFactor = 1.30,
    this.enableScrollbar = true,
  });

  @override
  State<ArtWorksGalleryContent> createState() => _ArtWorksGalleryContentState();
}

class _ArtWorksGalleryContentState extends State<ArtWorksGalleryContent> {
  bool get _isTablet {
    final w = MediaQuery.of(context).size.width;
    return w >= 768 && w < 1200;
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 1200;

  bool get _useGrid => _isTablet || _isDesktop;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Clamp text scale to avoid extreme UI breakage.
    final double scaled = mq.textScaleFactor * widget.textScaleFactor;
    final double textScale = scaled < 1.0
        ? 1.0
        : (scaled > 2.0
            ? 2.0
            : scaled);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = widget.artworks;

    final content = items.isEmpty
        ? _EmptyState(
            title: widget.emptyStateTitle ?? 'No artworks available',
            subtitle: widget.emptyStateSubtitle ??
                'Check back later for new artwork.',
            icon: widget.emptyStateIcon,
            isDark: isDark,
          )
        : _buildGallery(items);

    // Apply local text scaling so *all* descendant text grows, including inside cards.
    final scaledBody = MediaQuery(
      data: mq.copyWith(textScaleFactor: textScale),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: content,
      ),
    );

    return SafeArea(child: scaledBody);
  }

  Widget _buildGallery(List<Artwork> items) {
    final scrollable = _useGrid ? _buildGrid(items) : _buildList(items);

    final Widget withRefresh = widget.onRefresh != null
        ? RefreshIndicator(
            onRefresh: widget.onRefresh!,
            displacement: 36, // a bit more room for big text
            color: AppColor.teal,
            child: scrollable,
          )
        : scrollable;

    if (!widget.enableScrollbar) return withRefresh;

    return Scrollbar(
      interactive: true,
      thumbVisibility: false,
      child: withRefresh,
    );
  }

  void _defaultToggleFav(Artwork a) {
    context.read<EventsCubit>().toggleFavorite(
          userId: widget.userId,
          kind: EntityKind.artwork,
          entityId: a.id,
        );
  }

  // ---- Mobile: one-up list ----
  Widget _buildList(List<Artwork> items) {
    final favIds = context.select<EventsCubit, Set<String>>(
      (c) => c.state.favArtworkIds,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20.sSp), // a touch more breathing room
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 18.h),
            itemBuilder: (context, i) {
              final a = items[i];
              final isFav = favIds.contains(a.id);

              return ArtWorkCardWidget(
                key: ValueKey(a.id),
                artwork: a,
                isFavorite: isFav,
                onFavoriteTap: () => (widget.onFavoriteTap ?? _defaultToggleFav)(a),
                onTap: () {
                  navigateTo(
                    context,
                    ArtWorkDetailsScreen(
                      artworkId: a.id,
                      userId: widget.userId,
                    ),
                  );
                },
                viewType: ArtworkCardViewType.list,
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- Tablet/Desktop: grid using the same vertical card ----
  Widget _buildGrid(List<Artwork> items) {
    final favIds = context.select<EventsCubit, Set<String>>(
      (c) => c.state.favArtworkIds,
    );

    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1200;

    // Responsive columns: 2 on tablet, 3+ on wider screens.
    final int crossAxisCount = isDesktop ? 3 : 2;
    final double aspect = isDesktop ? 0.66 : 0.70;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20.sSp),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 18.h,
              mainAxisSpacing: 18.h,
              childAspectRatio: aspect,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final a = items[i];
                final isFav = favIds.contains(a.id);

                return ArtWorkCardWidget(
                  key: ValueKey(a.id),
                  artwork: a,
                  isFavorite: isFav,
                  onFavoriteTap: () => (widget.onFavoriteTap ?? _defaultToggleFav)(a),
                  onTap: () {
                    navigateTo(
                      context,
                      ArtWorkDetailsScreen(
                        artworkId: a.id,
                        userId: widget.userId,
                      ),
                    );
                  },
                  viewType: ArtworkCardViewType.grid,
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(56.h), // a bit larger to match the bigger text
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Empty artwork list icon',
              child: Container(
                width: 132.h,
                height: 132.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColor.gray700 : AppColor.gray100,
                  borderRadius: BorderRadius.circular(66.h),
                ),
                child: icon ?? Icon(
                  Icons.palette_rounded,
                  size: 54.h,
                  color: isDark ? AppColor.gray400 : AppColor.gray500,
                ),
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.fSize, // was 24 -> bigger base
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: isDark ? AppColor.white : AppColor.gray900,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.fSize, // was 16 -> bigger base
                color: isDark ? AppColor.gray400 : AppColor.gray600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
