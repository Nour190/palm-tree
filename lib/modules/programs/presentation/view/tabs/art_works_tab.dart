import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:baseqat/modules/programs/presentation/widgets/art_works_widgets/art_work_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ArtWorksGalleryContent extends StatelessWidget {
  const ArtWorksGalleryContent({
    super.key,
    required this.artworks,
    required this.languageCode,
    this.onArtworkTap,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onRefresh,
    this.enableScrollbar = true,
  });

  final List<Artwork> artworks;
  final String languageCode;
  final void Function(Artwork artwork)? onArtworkTap;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final Widget? emptyStateIcon;
  final Future<void> Function()? onRefresh;
  final bool enableScrollbar;

  bool _isTablet(BuildContext context) => ProgramsBreakpoints.isTablet(context);

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final content = artworks.isEmpty
        ? _EmptyState(
            title: emptyStateTitle ?? 'programs.empty.artworks_title'.tr(),
            subtitle: emptyStateSubtitle ?? 'programs.empty.artworks_subtitle'.tr(),
            icon: emptyStateIcon,
          )
        : (isTablet ? _buildGrid(context) : _buildList(context));

    Widget body = content;

    if (onRefresh != null) {
      body = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColor.teal,
        backgroundColor: AppColor.white,
        displacement: ProgramsLayout.size(context, 32),
        child: body,
      );
    }

    if (enableScrollbar) {
      body = Scrollbar(thumbVisibility: false, interactive: true, child: body);
    }

    return body;
  }

  Widget _buildList(BuildContext context) {
    final padding = ProgramsLayout.pagePadding(context).left;
    final spacing = ProgramsLayout.spacingLarge(context);

    return ListView.separated(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        final artwork = artworks[index];

        return ArtWorkCardWidget(
          artwork: artwork,
          viewType: ArtworkCardViewType.list,
          languageCode: languageCode,
          onTap: () => (onArtworkTap ?? _defaultNavigate)(context, artwork),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: spacing),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final padding = ProgramsLayout.pagePadding(context).left;
    final spacing = ProgramsLayout.spacingLarge(context);

    return GridView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 0.72,
      ),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        final artwork = artworks[index];

        return ArtWorkCardWidget(
          artwork: artwork,
          viewType: ArtworkCardViewType.grid,
          languageCode: languageCode,
          onTap: () => (onArtworkTap ?? _defaultNavigate)(context, artwork),
        );
      },
    );
  }

  void _defaultNavigate(BuildContext context, Artwork artwork) {
    navigateTo(
      context,
      ArtWorkDetailsScreen(artworkId: artwork.id , userId: "",),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle, this.icon});

  final String title;
  final String subtitle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final size = ProgramsLayout.size(context, 120);
    final radius = ProgramsLayout.radius20(context);
    final spacingLarge = ProgramsLayout.spacingLarge(context);
    final spacingMedium = ProgramsLayout.spacingMedium(context);

    return Center(
      child: Padding(
        padding: ProgramsLayout.sectionPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'programs.empty.artworks_semantics'.tr(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColor.gray100,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: icon ??
                    Icon(
                      Icons.palette_outlined,
                      size: ProgramsLayout.size(context, 48),
                      color: AppColor.gray400,
                    ),
              ),
            ),
            SizedBox(height: spacingLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ProgramsTypography.headingMedium(context)
                  .copyWith(color: AppColor.gray900),
            ),
            SizedBox(height: spacingMedium),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ProgramsTypography.bodySecondary(context)
                  .copyWith(color: AppColor.gray600),
            ),
          ],
        ),
      ),
    );
  }
}