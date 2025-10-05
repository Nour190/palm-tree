import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';

class IthraArtworksSection extends StatelessWidget {
  final List<Artwork> artworks;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onArtworkTap;
  final void Function(int index)? onFavoriteTap;
  final bool isLoading;

  const IthraArtworksSection({
    super.key,
    required this.artworks,
    this.onSeeMore,
    this.onArtworkTap,
    this.onFavoriteTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding = isDesktop
        ? 16.sW
        : isTablet
        ? 12.sW
        : 8.sW;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.art_works'.tr(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isDesktop
                      ? 24.sSp
                      : isTablet
                      ? 22.sSp
                      : 20.sSp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
              if (onSeeMore != null)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Text(
                    'home.see_more'.tr(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isDesktop ? 14.sSp : 13.sSp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.gray600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 24.sH),

          // Artworks horizontal list
          if (isLoading)
            _buildLoadingState(context, deviceType)
          else if (artworks.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildArtworksHorizontalList(context, deviceType),
        ],
      ),
    );
  }
  Widget _buildArtworksHorizontalList(
      BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    final double cardHeight = isMobile ? 370.sH : isTablet ? 430.sH : 470.sH;

    // sequence: Divider, Card, Divider, Card, ..., Divider
    final int totalItems = artworks.length * 2 + 1;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // even indices -> divider
          if (index.isEven) {
            return SizedBox(
              width: 8.sW, // total space for the divider (including padding)
              child: VerticalDivider(
                width: 8.sW,
                thickness: 2,
                color: AppColor.gray400,
              ),
            );
          }

          // odd indices -> card
          final int artworkIndex = index ~/ 2;
          return _IthraArtworkCard(
            artwork: artworks[artworkIndex],
            index: artworkIndex,
            onTap: onArtworkTap,
            onFavoriteTap: onFavoriteTap,
            deviceType: deviceType,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    final double cardHeight = isMobile ? 440.sH : isTablet ? 490.sH : 520.sH;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 16.sW),
        itemBuilder: (context, index) {
          return _LoadingArtworkCard(deviceType: deviceType);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      height: isMobile ? 200.sH : 240.sH,
      decoration: BoxDecoration(
        color: AppColor.gray50,
        borderRadius: BorderRadius.circular(12.sR),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: isMobile ? 32.sW : 40.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 8.sH),
            Text(
              'home.no_artworks_available'.tr(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 14.sSp : 16.sSp,
                fontWeight: FontWeight.w500,
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ARTWORK CARD
// ============================================================================
class _IthraArtworkCard extends StatefulWidget {
  final Artwork artwork;
  final int index;
  final void Function(int index)? onTap;
  final void Function(int index)? onFavoriteTap;
  final DeviceType deviceType;

  const _IthraArtworkCard({
    required this.artwork,
    required this.index,
    this.onTap,
    this.onFavoriteTap,
    required this.deviceType,
  });

  @override
  State<_IthraArtworkCard> createState() => _IthraArtworkCardState();
}

class _IthraArtworkCardState extends State<_IthraArtworkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.deviceType == DeviceType.mobile;
    final bool isTablet = widget.deviceType == DeviceType.tablet;

    final double cardWidth = isMobile ? 230.sW : isTablet ? 270.sW : 320.sW;
    final double imageHeight = isMobile ? 200.sH : isTablet ? 240.sH : 280.sH;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap != null ? () => widget.onTap!(widget.index) : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.sR),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artwork image with heart icon
                  Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.sW, vertical: 12.sH),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.sR),
                          ),
                          child: _buildArtworkImage(imageHeight, cardWidth),
                        ),
                      ),
                      // Heart icon at bottom-right of image
                      // Positioned(
                      //   right: 30.sW,
                      //   bottom: 30.sH,
                      //   child: _FavoriteButton(
                      //     onPressed: widget.onFavoriteTap != null
                      //         ? () => widget.onFavoriteTap!(widget.index)
                      //         : null,
                      //     size: isMobile ? 42.sW : 46.sW,
                      //     iconSize: isMobile ? 38.sSp : 36.sSp,
                      //   ),
                      // ),
                    ],
                  ),

                  // Content section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.artwork.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isMobile ? 16.sSp : isTablet ? 18.sSp : 20.sSp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.black,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: 8.sH),

                        // Description
                        if (widget.artwork.description?.isNotEmpty == true)
                          Text(
                            widget.artwork.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: isMobile ? 12.sSp : 13.sSp,
                              fontWeight: FontWeight.w400,
                              color: AppColor.gray600,
                              height: 1.4,
                            ),
                          ),

                        SizedBox(height: 16.sH),

                        // Artist info row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.artwork.artistName ?? 'home.unknown_artist'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: isMobile ? 13.sSp : 14.sSp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sW),
                            // Artist avatar
                            _buildArtistAvatar(isMobile),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtworkImage(double height, double width) {
    final String? imagePath = widget.artwork.gallery.isNotEmpty
        ? widget.artwork.gallery.first
        : null;

    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return HomeImage(
          path: imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorChild: _buildFallbackImage(height, width),
        );
      } else {
        return CustomImageView(
          imagePath: imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      }
    }

    return _buildFallbackImage(height, width);
  }

  Widget _buildFallbackImage(double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gray200,
            AppColor.gray400,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48.sW,
          color: AppColor.gray500,
        ),
      ),
    );
  }

  Widget _buildArtistAvatar(bool isMobile) {
    final String? imagePath = widget.artwork.artistProfileImage;
    final double avatarSize = isMobile ? 40.sW : 48.sW;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.gray200,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _buildAvatarContent(imagePath, avatarSize),
      ),
    );
  }

  Widget _buildAvatarContent(String? imagePath, double size) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return HomeImage(
          path: imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorChild: _buildFallbackAvatar(size),
        );
      } else {
        return CustomImageView(
          imagePath: imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }

    return _buildFallbackAvatar(size);
  }

  Widget _buildFallbackAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gray200,
            AppColor.gray500,
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getArtistInitials(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: widget.deviceType == DeviceType.mobile ? 16.sSp : 18.sSp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getArtistInitials() {
    final name = (widget.artwork.artistName ?? 'A').trim();
    if (name.isEmpty) return 'A';
    final words = name.split(RegExp(r'\s+'));
    if (words.isEmpty) return 'A';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }
}

// ============================================================================
// FAVORITE BUTTON
// ============================================================================
// class _FavoriteButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final double size;
//   final double iconSize;
//
//   const _FavoriteButton({
//     required this.onPressed,
//     required this.size,
//     required this.iconSize,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           color: AppColor.primaryColor.withOpacity(0.5),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: AppColor.black.withOpacity(0.15),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(
//           Icons.favorite_border,
//           size: iconSize,
//           color: AppColor.gray400,
//         ),
//       ),
//     );
//   }
// }

// ============================================================================
// LOADING CARD
// ============================================================================
class _LoadingArtworkCard extends StatefulWidget {
  final DeviceType deviceType;

  const _LoadingArtworkCard({required this.deviceType});

  @override
  State<_LoadingArtworkCard> createState() => _LoadingArtworkCardState();
}

class _LoadingArtworkCardState extends State<_LoadingArtworkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.deviceType == DeviceType.mobile;
    final bool isTablet = widget.deviceType == DeviceType.tablet;

    final double cardWidth = isMobile ? 280.sW : isTablet ? 320.sW : 360.sW;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.sR),
            border: Border.all(
              color: AppColor.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: cardWidth,
                height: isMobile ? 200.sH : isTablet ? 240.sH : 280.sH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.sR),
                    topRight: Radius.circular(16.sR),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColor.gray200,
                      AppColor.gray100,
                      AppColor.gray200,
                    ],
                    stops: [
                      (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.sW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    Container(
                      width: cardWidth * 0.7,
                      height: 20.sH,
                      decoration: BoxDecoration(
                        color: AppColor.gray200,
                        borderRadius: BorderRadius.circular(4.sR),
                      ),
                    ),
                    SizedBox(height: 8.sH),
                    // Description shimmer line 1
                    Container(
                      width: cardWidth * 0.9,
                      height: 14.sH,
                      decoration: BoxDecoration(
                        color: AppColor.gray100,
                        borderRadius: BorderRadius.circular(4.sR),
                      ),
                    ),
                    SizedBox(height: 6.sH),
                    // Description shimmer line 2
                    Container(
                      width: cardWidth * 0.75,
                      height: 14.sH,
                      decoration: BoxDecoration(
                        color: AppColor.gray100,
                        borderRadius: BorderRadius.circular(4.sR),
                      ),
                    ),
                    SizedBox(height: 16.sH),
                    // Artist info shimmer
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: cardWidth * 0.4,
                            height: 16.sH,
                            decoration: BoxDecoration(
                              color: AppColor.gray200,
                              borderRadius: BorderRadius.circular(4.sR),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sW),
                        // Avatar shimmer
                        Container(
                          width: isMobile ? 40.sW : 48.sW,
                          height: isMobile ? 40.sW : 48.sW,
                          decoration: BoxDecoration(
                            color: AppColor.gray200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
