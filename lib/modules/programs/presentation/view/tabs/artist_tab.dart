import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/programs/presentation/widgets/artist_widgets/artist_card_widget.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_page.dart';

class ArtistTabContent extends StatefulWidget {
  const ArtistTabContent({
    super.key,
    required this.artists,
    required this.languageCode,
    this.onArtistTap,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onRefresh,
  });

  final List<Artist> artists;
  final String languageCode;
  final void Function(Artist artist)? onArtistTap;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final Widget? emptyStateIcon;
  final Future<void> Function()? onRefresh;

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
    final body = widget.artists.isEmpty
        ? _EmptyState(
            title: widget.emptyStateTitle ?? 'programs.empty.artists_title'.tr(),
            subtitle: widget.emptyStateSubtitle ?? 'programs.empty.artists_subtitle'.tr(),
            icon: widget.emptyStateIcon,
          )
        : (_useGrid ? _buildGrid() : _buildList());

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

  Widget _buildList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
      itemCount: widget.artists.length,
      itemBuilder: (context, i) {
        final artist = widget.artists[i];

        return ArtistCardWidget(
          artist: artist,
          onTap: () => _handleTap(artist),
          viewType: ArtistCardViewType.list,
          userId: "",
          languageCode: widget.languageCode,
        );
      },
      separatorBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Container(height: 1, color: AppColor.gray200),
      ),
    );
  }

  Widget _buildGrid() {
    final crossAxisCount = _isDesktop ? 3 : 2;
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
      itemCount: widget.artists.length,
      itemBuilder: (context, i) {
        final artist = widget.artists[i];

        return ArtistCardWidget(
          artist: artist,
          userId: "",
          onTap: () => _handleTap(artist),
          viewType: ArtistCardViewType.grid,
          languageCode: widget.languageCode,
        );
      },
    );
  }

  void _handleTap(Artist artist) {
    if (widget.onArtistTap != null) {
      widget.onArtistTap!(artist);
    } else {
     // navigateTo(context, ArtistDetailsPage(artistId: artist.id));
    }
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.icon,
  });

  final String title;
  final String subtitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Icon(
                  Icons.people_rounded,
                  size: 80.h,
                  color: AppColor.gray400,
                ),
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