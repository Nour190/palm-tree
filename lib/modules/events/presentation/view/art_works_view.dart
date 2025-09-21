// ===================== ArtWorksGalleryContent =====================
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
  });

  @override
  State<ArtWorksGalleryContent> createState() => _ArtWorksGalleryContentState();
}

class _ArtWorksGalleryContentState extends State<ArtWorksGalleryContent>
    with TickerProviderStateMixin {
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1200;
  bool get _shouldUseGrid => _isDesktop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = widget.artworks;

    return Column(
      children: [
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
    final scrollable = _shouldUseGrid
        ? _buildDesktopGrid(items)
        : _buildMobileList(items);

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        displacement: 24,
        color: AppColor.teal,
        child: scrollable,
      );
    }
    return scrollable;
  }

  void _defaultToggleFav(Artwork a) {
    context.read<EventsCubit>().toggleFavorite(
      userId: widget.userId,
      kind: EntityKind.artwork,
      entityId: a.id,
    );
  }

  Widget _buildMobileList(List<Artwork> items) {
    final favIds = context.select<EventsCubit, Set<String>>(
      (c) => c.state.favArtworkIds,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20.sSp),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, i) {
              final a = items[i];
              final isFav = favIds.contains(a.id);

              return ArtWorkCardWidget(
                artwork: a,
                isFavorite: isFav,
                onFavoriteTap: () =>
                    (widget.onFavoriteTap ?? _defaultToggleFav)(a),
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

  Widget _buildDesktopGrid(List<Artwork> items) {
    final favIds = context.select<EventsCubit, Set<String>>(
      (c) => c.state.favArtworkIds,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(15.sSp),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15.h,
              mainAxisSpacing: 15.h,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final a = items[i];
              final isFav = favIds.contains(a.id);

              return ArtWorkCardWidget(
                artwork: a,
                isFavorite: isFav,
                onFavoriteTap: () =>
                    (widget.onFavoriteTap ?? _defaultToggleFav)(a),
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
            }, childCount: items.length),
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
        padding: EdgeInsets.all(48.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120.h,
              height: 120.h,
              decoration: BoxDecoration(
                color: isDark ? AppColor.gray700 : AppColor.gray100,
                borderRadius: BorderRadius.circular(60.h),
              ),
              child:
                  icon ??
                  Icon(
                    Icons.palette_rounded,
                    size: 48.h,
                    color: isDark ? AppColor.gray400 : AppColor.gray500,
                  ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 24.fSize,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColor.white : AppColor.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16.fSize,
                color: isDark ? AppColor.gray400 : AppColor.gray600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
