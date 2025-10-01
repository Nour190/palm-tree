import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';

class IthraArtistsSection extends StatelessWidget {
  final List<Artist> artists;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onArtistTap;
  final bool isLoading;

  const IthraArtistsSection({
    super.key,
    required this.artists,
    this.onSeeMore,
    this.onArtistTap,
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
                'home.artists'.tr(),
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

          // Artists grid
          if (isLoading)
            _buildLoadingState(context, deviceType)
          else if (artists.isEmpty)
            _buildEmptyState(context, deviceType)
          else
            _buildArtistsGrid(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildArtistsGrid(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    // Show max 5 artists in a horizontal row
    final displayArtists = artists.take(5).toList();

    return SizedBox(
      height: isMobile ? 120.sH : isTablet ? 140.sH : 160.sH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayArtists.length,
        separatorBuilder: (context, index) =>SizedBox.shrink(),
        itemBuilder: (context, index) {
          return _IthraArtistCard(
            artist: displayArtists[index],
            index: index,
            onTap: onArtistTap,
            deviceType: deviceType,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    return SizedBox(
      height: isMobile ? 120.sH : isTablet ? 140.sH : 160.sH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox.shrink(),
        itemBuilder: (context, index) {
          return _LoadingArtistCard(deviceType: deviceType);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      height: isMobile ? 120.sH : 160.sH,
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
              Icons.people_outline,
              size: isMobile ? 32.sW : 40.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 8.sH),
            Text(
              'home.no_artists_available'.tr(),
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

class _IthraArtistCard extends StatefulWidget {
  final Artist artist;
  final int index;
  final void Function(int index)? onTap;
  final DeviceType deviceType;

  const _IthraArtistCard({
    required this.artist,
    required this.index,
    this.onTap,
    required this.deviceType,
  });

  @override
  State<_IthraArtistCard> createState() => _IthraArtistCardState();
}

class _IthraArtistCardState extends State<_IthraArtistCard>
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
      end: 0.95,
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

    final double cardWidth = isMobile ? 70.sW : isTablet ? 90.sW : 110.sW;

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
            child: SizedBox(
              width: cardWidth,
              child: Column(
                children: [
                  // Circular avatar
                  Container(
                    width: 80.sH,
                    height: 80.sH,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.gray200,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(),
                    ),
                  ),

                  SizedBox(height: 12.sH),

                  // Artist name
                  Text(
                    widget.artist.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isMobile ? 12.sSp : isTablet ? 13.sSp : 14.sSp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      height: 1.2,
                    ),
                  ),

                  // SizedBox(height: 4.sH),
                  //
                  // // Artist specialty or location
                  // Text(
                  //   _getArtistSubtitle(),
                  //   textAlign: TextAlign.center,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: TextStyle(
                  //     fontFamily: 'Inter',
                  //     fontSize: isMobile ? 10.sSp : isTablet ? 11.sSp : 12.sSp,
                  //     fontWeight: FontWeight.w400,
                  //     color: AppColor.gray600,
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarImage() {
    final String? imagePath = widget.artist.profileImage;

    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return HomeImage(
          path: imagePath,
          fit: BoxFit.cover,
          errorChild: _buildFallbackAvatar(),
        );
      } else {
        return CustomImageView(
          imagePath: imagePath,
          fit: BoxFit.cover,
        );
      }
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
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
        child: Text(
          _getInitials(widget.artist.name),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: widget.deviceType == DeviceType.mobile ? 24.sSp : 28.sSp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  String _getArtistSubtitle() {
    final parts = <String>[];
    if (widget.artist.country?.isNotEmpty == true) {
      parts.add(widget.artist.country!);
    }
    if (widget.artist.city?.isNotEmpty == true) {
      parts.add(widget.artist.city!);
    }

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return 'Artist';
  }
}

class _LoadingArtistCard extends StatefulWidget {
  final DeviceType deviceType;

  const _LoadingArtistCard({required this.deviceType});

  @override
  State<_LoadingArtistCard> createState() => _LoadingArtistCardState();
}

class _LoadingArtistCardState extends State<_LoadingArtistCard>
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

    final double avatarSize = isMobile ? 80.sW : isTablet ? 100.sW : 120.sW;
    final double cardWidth = isMobile ? 90.sW : isTablet ? 110.sW : 130.sW;

    return SizedBox(
      width: cardWidth,
      child: Column(
        children: [
          // Shimmer avatar
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
              );
            },
          ),

          SizedBox(height: 12.sH),

          // Shimmer name
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: cardWidth * 0.8,
                height: 14.sH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.sR),
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
              );
            },
          ),

          SizedBox(height: 8.sH),

          // Shimmer subtitle
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                width: cardWidth * 0.6,
                height: 12.sH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.sR),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
