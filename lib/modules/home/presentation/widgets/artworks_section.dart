// artworks_section.dart
//
// Artworks section:
// - Mobile: HORIZONTAL list (reduced card width) — title/desc up to 3 lines
// - Tablet: HORIZONTAL list (reduced card width) — title/desc up to 3 lines
// - Desktop: HORIZONTAL list (wider cards) — title/desc up to 3 lines
//
// No outer padding. Right-side black separator on cards.
// Capsule tag, favorite button, gradient overlay on images.
// Loading + empty states for list-only layouts.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';

class ArtworksSection extends StatelessWidget {
  final List<Artwork> artworks;
  final String title;
  final EdgeInsetsGeometry? headerPadding;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onCardTap;
  final void Function(int index)? onFavoriteTap;
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
    this.onFavoriteTap,
    this.isLoading = false,
    this.showSeeMoreButton = true,
    this.seeMoreButtonText = 'See All',
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(
          title: title,
          padding: headerPadding ?? EdgeInsets.zero, // no outer padding
          onSeeMore: onSeeMore,
          seeMoreButtonText: seeMoreButtonText,
          showSeeMore:
              showSeeMoreButton && onSeeMore != null && artworks.isNotEmpty,
        ),
        SizedBox(
          height: switch (deviceType) {
            DeviceType.desktop => 24.0.sH,
            DeviceType.tablet => 20.0.sH,
            DeviceType.mobile => 16.0.sH,
          },
        ),
        _buildBody(deviceType),
      ],
    );
  }

  Widget _buildBody(DeviceType deviceType) {
    if (isLoading) return _buildLoading(deviceType);
    if (artworks.isEmpty) return _buildEmpty(deviceType);

    switch (deviceType) {
      // H O R I Z O N T A L  (reduced width + 3-line text)
      case DeviceType.mobile:
        return _HorizontalStrip(
          height: 240.0.sH,
          itemWidth: 210.0.sW, // decreased width (was ~260)
          spacing: 12.0.sW,
          itemCount: artworks.length,
          itemBuilder: (context, i) => _HorizontalArtworkCard(
            artwork: artworks[i],
            index: i,
            onTap: onCardTap,
            onFavoriteTap: onFavoriteTap,
          ),
        );

      // H O R I Z O N T A L  (reduced width + 3-line text)
      case DeviceType.tablet:
        return _HorizontalStrip(
          height: 300.0.sH,
          itemWidth: 320.0.sW, // decreased width (was ~380)
          spacing: 14.0.sW,
          itemCount: artworks.length,
          itemBuilder: (context, i) => _HorizontalArtworkCard(
            artwork: artworks[i],
            index: i,
            onTap: onCardTap,
            onFavoriteTap: onFavoriteTap,
          ),
        );

      // H O R I Z O N T A L  (wider cards for desktop)
      case DeviceType.desktop:
        return _HorizontalStrip(
          height: 340.0.sH,
          itemWidth: 380.0.sW,
          spacing: 16.0.sW,
          itemCount: artworks.length,
          itemBuilder: (context, i) => _HorizontalArtworkCard(
            artwork: artworks[i],
            index: i,
            onTap: onCardTap,
            onFavoriteTap: onFavoriteTap,
          ),
        );
    }
  }

  // -------------------- Loading --------------------
  Widget _buildLoading(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _HorizontalStrip(
          height: 240.0.sH,
          itemWidth: 210.0.sW,
          spacing: 12.0.sW,
          itemCount: 4,
          itemBuilder: (_, __) =>
              _LoadingBlock(width: 210.0.sW, height: 240.0.sH, radius: 16.0.r),
        );
      case DeviceType.tablet:
        return _HorizontalStrip(
          height: 300.0.sH,
          itemWidth: 320.0.sW,
          spacing: 14.0.sW,
          itemCount: 5,
          itemBuilder: (_, __) =>
              _LoadingBlock(width: 320.0.sW, height: 300.0.sH, radius: 18.0.r),
        );
      case DeviceType.desktop:
        return _HorizontalStrip(
          height: 340.0.sH,
          itemWidth: 380.0.sW,
          spacing: 16.0.sW,
          itemCount: 6,
          itemBuilder: (_, __) =>
              _LoadingBlock(width: 380.0.sW, height: 340.0.sH, radius: 18.0.r),
        );
    }
  }

  // -------------------- Empty --------------------
  Widget _buildEmpty(DeviceType deviceType) {
    final iconSize = switch (deviceType) {
      DeviceType.desktop => 48.0.sW,
      DeviceType.tablet => 42.0.sW,
      DeviceType.mobile => 36.0.sW,
    };
    final titleSize = switch (deviceType) {
      DeviceType.desktop => 20.0.sSp,
      DeviceType.tablet => 18.0.sSp,
      DeviceType.mobile => 16.0.sSp,
    };
    final subtitleSize = switch (deviceType) {
      DeviceType.desktop => 16.0.sSp,
      DeviceType.tablet => 14.0.sSp,
      DeviceType.mobile => 12.0.sSp,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: switch (deviceType) {
          DeviceType.desktop => 48.0.sH,
          DeviceType.tablet => 40.0.sH,
          DeviceType.mobile => 32.0.sH,
        },
      ),
      decoration: BoxDecoration(
        color: AppColor.gray50,
        borderRadius: BorderRadius.circular(switch (deviceType) {
          DeviceType.desktop => 20.0.r,
          DeviceType.tablet => 18.0.r,
          DeviceType.mobile => 16.0.r,
        }),
        border: Border.all(color: AppColor.gray200, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: iconSize / 2,
            backgroundColor: AppColor.gray100,
            child: Icon(
              Icons.palette_outlined,
              size: iconSize,
              color: AppColor.gray400,
            ),
          ),
          SizedBox(height: 14.0.sH),
          Text(
            'No artworks available',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              color: AppColor.gray700,
            ),
          ),
          SizedBox(height: 6.0.sH),
          Text(
            'Check back later for new artworks',
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
              color: AppColor.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HORIZONTAL STRIP (shared by all devices)
// ============================================================================
class _HorizontalStrip extends StatelessWidget {
  const _HorizontalStrip({
    required this.height,
    required this.itemWidth,
    required this.spacing,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double height;
  final double itemWidth;
  final double spacing;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) => RepaintBoundary(
          key: ValueKey('artwork-horizontal-$index'),
          child: SizedBox(width: itemWidth, child: itemBuilder(context, index)),
        ),
      ),
    );
  }
}

// ============================================================================
// HORIZONTAL CARD (mobile/tablet/desktop) — 3-line title/desc
// ============================================================================
class _HorizontalArtworkCard extends StatelessWidget {
  final Artwork artwork;
  final int index;
  final void Function(int index)? onTap;
  final void Function(int index)? onFavoriteTap;

  const _HorizontalArtworkCard({
    super.key,
    required this.artwork,
    required this.index,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = 16.0.r;
    final deviceType = Responsive.deviceTypeOf(context);

    // Description sizing per device
    final double descSize = switch (deviceType) {
      DeviceType.mobile => 11.0.sSp,
      DeviceType.tablet => 13.0.sSp,
      DeviceType.desktop => 13.0.sSp,
    };

    return Semantics(
      button: onTap != null,
      label:
          'View artwork ${artwork.name} by ${artwork.artistName ?? 'Unknown'}',
      child: Material(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(radius),
        elevation: 3,
        shadowColor: AppColor.black.withOpacity(0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap != null ? () => onTap!(index) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: const Border(
                right: BorderSide(
                  color: Colors.black,
                  width: 1, // right-side black separator
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Builder(
                      builder: (_) {
                        final String cover = (artwork.gallery.isNotEmpty)
                            ? artwork.gallery.first
                            : (artwork.artistProfileImage ?? '');
                        return CustomImageView(
                          imagePath: cover,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  // gradient for text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColor.black.withOpacity(0.60),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // favorite
                  Positioned(
                    right: 10.0.sW,
                    top: 10.0.sH,
                    child: _FavCircleButton(
                      onPressed: onFavoriteTap != null
                          ? () => onFavoriteTap!(index)
                          : null,
                      size: 36.0.sW,
                      iconSize: 18.0.sW,
                    ),
                  ),
                  // content (title + description up to 3 lines)
                  Positioned(
                    left: 12.0.sW,
                    right: 12.0.sW,
                    bottom: 12.0.sH,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Capsule(text: 'Artwork'),
                        SizedBox(height: 6.0.sH),
                        Text(
                          artwork.name,
                          maxLines: 3, // increased to 3 lines
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0.sSp,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6.0.sH),
                        if ((artwork.description ?? '').isNotEmpty)
                          Text(
                            artwork.description!,
                            maxLines: 3, // force 3 lines max
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: descSize,
                              color: AppColor.gray100,
                              height: 1.25,
                            ),
                          ),
                        SizedBox(height: 8.0.sH),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0.r),
                              child: CustomImageView(
                                imagePath: artwork.artistProfileImage ?? '',
                                height: 18.0.sW,
                                width: 18.0.sW,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 8.0.sW),
                            Expanded(
                              child: Text(
                                artwork.artistName ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.0.sSp,
                                  color: AppColor.gray100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Small shared widgets
// ============================================================================
class _Capsule extends StatelessWidget {
  final String text;
  const _Capsule({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0.sW, vertical: 4.0.sH),
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 10.0.sSp,
          color: AppColor.gray700,
        ),
      ),
    );
  }
}

class _FavCircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  const _FavCircleButton({
    required this.onPressed,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Favorite artwork',
      child: Material(
        color: AppColor.white.withOpacity(0.95),
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: AppColor.black.withOpacity(0.15),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.favorite_border,
              size: iconSize,
              color: AppColor.gray700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _LoadingBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.circular(radius),
        border: const Border(right: BorderSide(color: Colors.black, width: 1)),
      ),
    );
  }
}
