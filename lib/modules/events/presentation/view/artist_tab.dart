import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_page.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/events/presentation/widgets/artist_widgets/artist_card_widget.dart';

enum ArtistViewType { list, grid }

class ArtistTabContent extends StatefulWidget {
  final List<Artist> artists;
  final void Function(Artist artist)? onArtistTap;

  // Optional empty-state customization
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final Widget? emptyStateIcon;

  // Optional pull-to-refresh
  final Future<void> Function()? onRefresh;

  const ArtistTabContent({
    super.key,
    required this.artists,
    this.onArtistTap,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onRefresh,
  });

  @override
  State<ArtistTabContent> createState() => _ArtistTabContentState();
}

class _ArtistTabContentState extends State<ArtistTabContent> {
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = widget.artists;

    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? _EmptyState(
                  title: widget.emptyStateTitle ?? 'No artists available',
                  subtitle:
                      widget.emptyStateSubtitle ??
                      'Check back later for new artists.',
                  icon: widget.emptyStateIcon,
                  isDark: isDark,
                )
              : _buildList(items),
        ),
      ],
    );
  }

  Widget _buildList(List<Artist> items) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: _isMobile ? 14.h : 20.h,
        vertical: 8.h,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: _isMobile ? 12.h : 16.h),
      itemBuilder: (context, i) {
        final a = items[i];
        return ArtistCardWidget(
          artist: a,
          onTap: () {
            navigateTo(context, ArtistDetailsPage(artistId: a.id));
          },
          isGridView: false,
        );
      },
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
                  Icons.people_rounded,
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
