import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/cached_home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/resourses/style_manager.dart';

class IthraArtworkCard extends StatefulWidget {
  final Artwork artwork;
  final int index;
  final void Function(int index)? onTap;
  final void Function(int index)? onFavoriteTap;
  final DeviceType deviceType;
  final bool isRTL;

  const IthraArtworkCard({
    super.key,
    required this.artwork,
    required this.index,
    this.onTap,
    this.onFavoriteTap,
    required this.deviceType,
    required this.isRTL,
  });

  @override
  State<IthraArtworkCard> createState() => _IthraArtworkCardState();
}

class _IthraArtworkCardState extends State<IthraArtworkCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

    final double cardWidth = isMobile ? 240.sW : isTablet ? 280.sW : 330.sW;

    final double imageHeight = isMobile ? 260.sH : isTablet ? 300.sH : 340.sH;

    // Localized fields without changing layout
    final String title = _localizedName(widget.artwork, widget.isRTL);
    final String? desc = _localizedDescription(widget.artwork, widget.isRTL);
    final String artistName =
        _localizedArtistName(widget.artwork, widget.isRTL) ?? 'home.unknown_artist'.tr();

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
                  // Artwork image (taller)
                  Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.sW, vertical: 12.sH),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(25.sR)),
                          child: _buildArtworkImage(imageHeight, cardWidth),
                        ),
                      ),
                      // Favorite button intentionally kept commented to keep UI identical
                    ],
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (localized)
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyleHelper.instance.title16BoldInter
                        ),

                        SizedBox(height: 8.sH),

                        // Description (localized)
                        if (desc != null && desc.isNotEmpty)
                          Text(
                            desc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style:TextStyleHelper.instance.body14RegularInter
                          ),

                        SizedBox(height: 16.sH),

                        // Artist info row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                artistName,
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
                            _buildArtistAvatar(isMobile, artistName),
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

  // ------------------- Media -------------------
  Widget _buildArtworkImage(double height, double width) {
    final String? imagePath =
    widget.artwork.gallery.isNotEmpty ? widget.artwork.gallery.first : null;

    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return CachedHomeImage(
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
          colors: [AppColor.gray200, AppColor.gray400],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, size: 48.sW, color: AppColor.gray500),
      ),
    );
  }

  // ------------------- Avatar -------------------
  Widget _buildArtistAvatar(bool isMobile, String artistNameLocalized) {
    final String? imagePath = widget.artwork.artistProfileImage;
    final double avatarSize = isMobile ? 40.sW : 48.sW;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.gray200, width: 2),
      ),
      child: ClipOval(
        child: _buildAvatarContent(imagePath, avatarSize, artistNameLocalized),
      ),
    );
  }

  Widget _buildAvatarContent(String? imagePath, double size, String artistNameLocalized) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return CachedHomeImage(
          path: imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorChild: _buildFallbackAvatar(size, artistNameLocalized),
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
    return _buildFallbackAvatar(size, artistNameLocalized);
  }

  Widget _buildFallbackAvatar(double size, String artistNameLocalized) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.gray200, AppColor.gray500],
        ),
      ),
      child: Center(
        child: Text(
          _initialsFromName(artistNameLocalized),
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

  // ------------------- Localized fields -------------------
  String _localizedName(Artwork a, bool isRTL) {
    final ar = (a.nameAr ?? '').trim();
    return (isRTL && ar.isNotEmpty) ? ar : a.name;
  }

  String? _localizedDescription(Artwork a, bool isRTL) {
    final ar = (a.descriptionAr ?? '').trim();
    final en = (a.description ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : null;
  }

  String? _localizedArtistName(Artwork a, bool isRTL) {
    final ar = (a.artistNameAr ?? '').trim();
    final en = (a.artistName ?? '').trim();
    if (isRTL && ar.isNotEmpty) return ar;
    return en.isNotEmpty ? en : null;
  }

  // ------------------- Initials -------------------
  String _initialsFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'A';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final ch = parts.first.characters.first;
      return ch.toUpperCase(); // Arabic stays visually same
    }
    final first = parts.first.characters.first;
    final last = parts.last.characters.first;
    return (first + last).toUpperCase();
  }
}
