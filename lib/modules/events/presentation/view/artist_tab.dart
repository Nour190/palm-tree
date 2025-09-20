import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artist_details/presentation/view/artist_details_page.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart' hide DeviceType;
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/events/presentation/widgets/artist_widgets/artist_card_widget.dart';
import 'package:baseqat/core/responsive/responsive.dart';

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
  DeviceType get _deviceType => Responsive.deviceTypeOf(context);
  bool get _isDesktop => _deviceType == DeviceType.desktop;

  @override
  Widget build(BuildContext context) {
    final items = widget.artists;
    Responsive.init(context);
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
          )
              : widget.onRefresh != null
              ? RefreshIndicator(
            onRefresh: widget.onRefresh!,
            color: AppColor.primaryColor,
            backgroundColor: AppColor.white,
            child: _buildContent(items),
          )
              : _buildContent(items),
        ),
      ],
    );
  }

  Widget _buildContent(List<Artist> items) {
    return _isDesktop ? _buildDesktopGrid(items) : _buildMobileList(items);
  }
  double _gridChildAspectRatio(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    if (Responsive.isDesktop(context)) {
      if (w >= 1400) {
        return 0.95;
      } else if (w >= 1200) {
        return 0.85;
      } else if (w >= 1000) {
        return 0.75;
      } else {
        return 0.55;
      }
    } else if (Responsive.isTablet(context)) {
      if (w >= 900) return 0.85;
      return 0.95;
    } else {
      return 0.9;
    }
  }

  Widget _buildDesktopGrid(List<Artist> items) {
    final aspect = _gridChildAspectRatio(context);
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 16.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: aspect,
        crossAxisSpacing: 20.h,
        mainAxisSpacing: 20.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final artist = items[i];
        return ArtistCardWidget(
          artist: artist,
          onTap: () {
            navigateTo(context, ArtistDetailsPage(artistId: artist.id));
          },
          viewType: ArtistCardViewType.grid,
        );
      },
    );
  }

  Widget _buildMobileList(List<Artist> items) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, i) {
        final artist = items[i];
        return ArtistCardWidget(
          artist: artist,
          onTap: () {
            navigateTo(context, ArtistDetailsPage(artistId: artist.id));
          },
          viewType: ArtistCardViewType.list,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.icon,
  });

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
