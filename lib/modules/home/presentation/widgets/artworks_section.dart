import 'package:flutter/material.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';

class ArtworksSection extends StatelessWidget {
  final List<Artwork> artworks;
  final String title;
  final EdgeInsetsGeometry? headerPadding;
  final VoidCallback? onSeeMore;

  /// Index-based taps for card and favourite
  final void Function(int index)? onCardTap;
  final void Function(int index)? onFavouiteTap;

  final bool isLoading;
  final bool showSeeMoreButton;
  final String seeMoreButtonText;

  const ArtworksSection({
    super.key,
    required this.artworks,
    this.title = 'Art Works',
    this.headerPadding,
    this.onSeeMore,
    this.onCardTap,
    this.onFavouiteTap,
    this.isLoading = false,
    this.showSeeMoreButton = true,
    this.seeMoreButtonText = 'See All',
  });

  @override
  Widget build(BuildContext context) {
    const hp = 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: title,
          padding: headerPadding ?? const EdgeInsets.symmetric(horizontal: hp),
          onSeeMore: onSeeMore,
          seeMoreButtonText: seeMoreButtonText,
          showSeeMore: showSeeMoreButton,
        ),
        const SizedBox(height: 16),

        if (isLoading)
          const _SkeletonGrid()
        else if (artworks.isEmpty)
          const _EmptyState()
        else
          _ResponsiveGrid(
            artworks: artworks,
            horizontalPadding: hp,
            onCardTap: onCardTap,
            onFavouiteTap: onFavouiteTap,
          ),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final List<Artwork> artworks;
  final double horizontalPadding;
  final void Function(int index)? onCardTap;
  final void Function(int index)? onFavouiteTap;

  const _ResponsiveGrid({
    required this.artworks,
    required this.horizontalPadding,
    this.onCardTap,
    this.onFavouiteTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth == double.infinity
            ? MediaQuery.of(context).size.width
            : c.maxWidth;

        // Small grid for mobile: 2 cols under 600px, then scale up
        final isPhone = width < 600;
        final spacing = isPhone ? 12.0 : 16.0;
        final crossAxisCount = isPhone
            ? 2
            : width < 900
            ? 3
            : 4;
        // Compact card aspect for “small grid” look (w/h)
        final childAspectRatio = isPhone ? 1 / 1.25 : 1 / 1.30;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GridView.builder(
            itemCount: artworks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) => ArtworkCardWidget(
              artwork: artworks[index],
              index: index,
              onTap: onCardTap == null ? null : () => onCardTap!(index),
              onFavouiteTap: onFavouiteTap == null
                  ? null
                  : () => onFavouiteTap!(index),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    const hp = 16.0;
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth == double.infinity
            ? MediaQuery.of(context)
                  .size
                  .width // fallback for rare cases
            : c.maxWidth;
        final isPhone = width < 600;
        final spacing = isPhone ? 12.0 : 16.0;
        final crossAxisCount = isPhone
            ? 2
            : width < 900
            ? 3
            : 4;
        final childAspectRatio = isPhone ? 1 / 1.25 : 1 / 1.15;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: hp),
          child: GridView.builder(
            itemCount: crossAxisCount * 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (_, __) => const _SkeletonCard(),
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget bar(double h, double w, double r) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: AppColor.gray200,
        borderRadius: BorderRadius.circular(r),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.gray100, width: 0.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: bar(14, 120, 4)),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: bar(12, 180, 4)),
          const SizedBox(height: 10),
          Row(
            children: [
              bar(28, 28, 14),
              const SizedBox(width: 8),
              Expanded(child: bar(12, double.infinity, 4)),
              const SizedBox(width: 8),
              bar(28, 28, 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.gray50, AppColor.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.gray200, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColor.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.palette_outlined,
              size: 40,
              color: AppColor.gray400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No artworks available',
            style: TextStyleHelper.instance.title18MediumInter.copyWith(
              color: AppColor.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check back later for new artworks',
            style: TextStyleHelper.instance.body14RegularInter.copyWith(
              color: AppColor.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class ArtworkCardWidget extends StatelessWidget {
  final Artwork artwork;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onFavouiteTap;

  const ArtworkCardWidget({
    super.key,
    required this.artwork,
    required this.index,
    this.onTap,
    this.onFavouiteTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = 12.0;

    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.gray100, width: 0.75),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3, // compact image ratio for small grid
                      child: Container(
                        color: AppColor.gray100,
                        child: CustomImageView(
                          imagePath: artwork.artistProfileImage ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _FavButton(onPressed: onFavouiteTap),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork.name,
                        style: TextStyleHelper.instance.body16MediumInter
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        artwork.description ?? 'No description available',
                        style: TextStyleHelper.instance.caption12RegularInter
                            .copyWith(color: AppColor.gray700, height: 1.25),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      // Artist row
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.primaryColor.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: CustomImageView(
                                imagePath: artwork.artistProfileImage ?? '',
                                height: 28,
                                width: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              artwork.artistName ?? 'Unknown Artist',
                              style: TextStyleHelper
                                  .instance
                                  .caption12RegularInter
                                  .copyWith(
                                    color: AppColor.gray700,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _FavButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _FavButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.favorite_border, size: 18, color: AppColor.gray700),
        ),
      ),
    );
  }
}
