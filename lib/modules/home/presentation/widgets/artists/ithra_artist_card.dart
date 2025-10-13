import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/cached_home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';

class IthraArtistCard extends StatefulWidget {
  final Artist artist;
  final int index;
  final void Function(int index)? onTap;
  final DeviceType deviceType;
  final String languageCode;

  const IthraArtistCard({
    super.key,
    required this.artist,
    required this.index,
    this.onTap,
    required this.deviceType,
    required this.languageCode,
  });

  @override
  State<IthraArtistCard> createState() => _IthraArtistCardState();
}

class _IthraArtistCardState extends State<IthraArtistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 1.0,
    end: 0.95,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.deviceType == DeviceType.mobile;
    final bool isTablet = widget.deviceType == DeviceType.tablet;

    final double cardWidth = isMobile ? 90.sW : isTablet ? 100.sW : 120.sW;

    // Localized display name (no layout changes)
    final displayName = widget.artist.localizedName(languageCode: widget.languageCode);

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
                    width: 80.sW,
                    height: 90.sH,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.gray200,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(),
                    ),
                  ),

                  SizedBox(height: 14.sH),

                  // Artist name (localized)
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isMobile ? 12.sSp : isTablet ? 13.sSp : 14.sSp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black,
                      height: 1.2,
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

  Widget _buildAvatarImage() {
    final String? imagePath = widget.artist.profileImage;

    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.toLowerCase().startsWith('http')) {
        return CachedHomeImage(
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
    final displayName = widget.artist.localizedName(languageCode: widget.languageCode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.gray200, AppColor.gray400],
        ),
      ),
      child: Center(
        child: Text(
          _initialsFromName(displayName),
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

  String _initialsFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final ch = parts.first.characters.first;
      return ch.toUpperCase(); // Arabic remains visually same
    }
    final first = parts.first.characters.first;
    final last = parts.last.characters.first;
    return (first + last).toUpperCase();
  }
}
