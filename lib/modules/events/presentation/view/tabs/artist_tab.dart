// ===================== ArtistTabContent (mobile/tablet like screenshot, with line separator) =====================
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/events/data/models/fav_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/events/presentation/widgets/artist_widgets/artist_card_widget.dart';

// Favorites
import 'package:baseqat/modules/events/presentation/manger/events/events_cubit.dart';

import '../../../../artist_details/presentation/view/artist_details_page.dart';

class ArtistTabContent extends StatefulWidget {
  final List<Artist> artists;
  final void Function(Artist artist)? onArtistTap;

  /// user id for favorites
  final String userId;

  final void Function(Artist artist)? onFavoriteTap;

  // Optional empty-state customization
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final Widget? emptyStateIcon;

  // Optional pull-to-refresh
  final Future<void> Function()? onRefresh;

  const ArtistTabContent({
    super.key,
    required this.artists,
    required this.userId,
    this.onArtistTap,
    this.onFavoriteTap,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onRefresh,
  });

  @override
  State<ArtistTabContent> createState() => _ArtistTabContentState();
}

class _ArtistTabContentState extends State<ArtistTabContent> {
  bool get _useGrid {
    final w = MediaQuery.of(context).size.width;
    return w >= 768; // tablet & up
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final items = widget.artists;

    final body = items.isEmpty
        ? _EmptyState(
            title: widget.emptyStateTitle ?? 'No artists available',
            subtitle:
                widget.emptyStateSubtitle ?? 'Check back later for new artists.',
            icon: widget.emptyStateIcon,
          )
        : (_useGrid ? _buildGrid(items) : _buildList(items));

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: AppColor.primaryColor,
        backgroundColor: AppColor.white,
        displacement: 24,
        child: body,
      );
    }
    return body;
  }

  // ----- favorites default handler (UI doesn’t show a heart but keep logic) -----
  void _defaultToggleFav(Artist a) {
    context.read<EventsCubit>().toggleFavorite(
          userId: widget.userId,
          kind: EntityKind.artist,
          entityId: a.id,
        );
  }

  // ----- Mobile list (with line separator identical to screenshot) -----
  Widget _buildList(List<Artist> items) {
    final favIds = context.select<EventsCubit, Set<String>>(
      (c) => c.state.favArtistIds,
    );

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final artist = items[i];
        final isFav = favIds.contains(artist.id);

        return ArtistCardWidget(
          artist: artist,
          userId: widget.userId,
          isFavorite: isFav,
          onFavoriteTap: () =>
              (widget.onFavoriteTap ?? _defaultToggleFav)(artist),
          onTap: () {
            (widget.onArtistTap ??
                    (a) =>
                        navigateTo(context, ArtistDetailsPage(artistId: a.id)))
                .call(artist);
          },
          viewType: ArtistCardViewType.list,
        );
      },
      // thin gray separator line (full-bleed inside page padding)
      separatorBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Container(height: 1, color: AppColor.gray200),
      ),
    );
  }

  // ----- Tablet/Desktop grid (same vertical card; no separators in grid) -----
  Widget _buildGrid(List<Artist> items) {
    final favIds = context.select<EventsCubit, Set<String>>(
      (c) => c.state.favArtistIds,
    );

    final crossAxisCount = _isDesktop ? 3 : 2;
    // ratio tuned for big image + title row + multi-line bio
    final childAspectRatio = _isDesktop ? 0.82 : 0.88;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16.h,
        mainAxisSpacing: 16.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final artist = items[i];
        final isFav = favIds.contains(artist.id);

        return ArtistCardWidget(
          artist: artist,
          userId: widget.userId,
          isFavorite: isFav,
          onFavoriteTap: () =>
              (widget.onFavoriteTap ?? _defaultToggleFav)(artist),
          onTap: () {
            (widget.onArtistTap ??
                    (a) =>
                        navigateTo(context, ArtistDetailsPage(artistId: a.id)))
                .call(artist);
          },
          viewType: ArtistCardViewType.grid,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;

  const _EmptyState({required this.title, required this.subtitle, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? Icon(Icons.people_rounded, size: 80.h, color: AppColor.gray400),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.fSize,
                fontWeight: FontWeight.w600,
                color: AppColor.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16.fSize,
                color: AppColor.gray600,
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
