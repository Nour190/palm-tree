// ===================== ArtWorkCardWidget =====================
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

enum ArtworkCardViewType { list, grid }

class ArtWorkCardWidget extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback? onTap;
  final ArtworkCardViewType viewType;

  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ArtWorkCardWidget({
    super.key,
    required this.artwork,
    this.onTap,
    this.viewType = ArtworkCardViewType.list,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  State<ArtWorkCardWidget> createState() => _ArtWorkCardWidgetState();
}

class _ArtWorkCardWidgetState extends State<ArtWorkCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _hoverCtrl = AnimationController(
    duration: const Duration(milliseconds: 160),
    vsync: this,
  );

  late final Animation<double> _hoverScale = Tween(begin: 1.0, end: 1.015)
      .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));

  bool _isHovered = false;

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (_isHovered != isHovered) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverCtrl.forward();
      } else {
        _hoverCtrl.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _hoverScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverScale.value,
            child: _VerticalArtworkCard(
              artwork: widget.artwork,
              isFavorite: widget.isFavorite,
              onFavoriteTap: widget.onFavoriteTap,
              onTap: widget.onTap,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _VerticalArtworkCard extends StatelessWidget {
  final Artwork artwork;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;
  final bool isDark;

  const _VerticalArtworkCard({
    required this.artwork,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Alternate dark/light card like the reference
    final isAlt = artwork.id.hashCode.isEven;

    final cardBg = isAlt ? AppColor.backgroundBlack
                         : (isDark ? AppColor.gray700 : AppColor.white);
    final cardBorder = isAlt
        ? null
        : Border.all(
            color: isDark ? AppColor.gray200.withOpacity(.15) : AppColor.gray200,
            width: 1,
          );

    final textPrimary   = isAlt ? AppColor.white : (isDark ? AppColor.white : AppColor.gray900);
    final textSecondary = isAlt ? AppColor.gray400 : (isDark ? AppColor.gray400 : AppColor.gray600);

    // Arrow contrast aligns with card style
    final arrowBg   = isAlt ? AppColor.white : AppColor.black;
    final arrowIcon = isAlt ? AppColor.black : AppColor.white;

    final rCard  = 20.h;
    final rMedia = 16.h;

    final cover = _pickCover(artwork);

    return Material(
      color: cardBg,
      shadowColor: isAlt ? AppColor.black.withOpacity(0.28) : Colors.transparent,
      elevation: isAlt ? 8 : 0,
      borderRadius: BorderRadius.circular(rCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(rCard),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rCard),
            border: cardBorder,
          ),
          padding: EdgeInsets.all(12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Top media with heart chip ----
              ClipRRect(
                borderRadius: BorderRadius.circular(rMedia),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: isDark ? AppColor.gray600 : AppColor.gray100,
                        child: (cover == null || cover.isEmpty)
                            ? _buildImagePlaceholder(isDark)
                            : Image.network(
                                cover,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildImagePlaceholder(isDark),
                              ),
                      ),
                    ),
                    // Heart chip (top-left)
                    Positioned(
                      left: 12.h,
                      top: 12.h,
                      child: _RoundIconButton(
                        size: 34.h,
                        bg: Colors.white.withOpacity(isAlt ? 0.12 : 0.92),
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: isFavorite
                            ? AppColor.primaryColor
                            : (isAlt ? AppColor.white : AppColor.gray700),
                        borderColor: isAlt
                            ? AppColor.white.withOpacity(0.24)
                            : AppColor.gray400,
                        onTap: onFavoriteTap,
                        semanticsLabel: isFavorite ? 'Unfavorite' : 'Favorite',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // ---- Title ----
              Text(
                artwork.name,
                style: TextStyle(
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  height: 1.25,
                  letterSpacing: .2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 6.h),

              // ---- Long description ----
              if (artwork.description != null && artwork.description!.isNotEmpty)
                Text(
                  artwork.description!,
                  style: TextStyle(
                    fontSize: 13.fSize,
                    color: textSecondary,
                    height: 1.42,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),

              SizedBox(height: 12.h),

              // ---- Footer: avatar, name + role, arrow ----
              Row(
                children: [
                  Container(
                    width: 36.h,
                    height: 36.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAlt
                            ? AppColor.gray500
                            : (isDark ? AppColor.gray600 : AppColor.gray400),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: (artwork.artistProfileImage == null ||
                              artwork.artistProfileImage!.isEmpty)
                          ? Container(
                              color: isDark ? AppColor.gray700 : AppColor.gray100,
                              child: Icon(
                                Icons.person,
                                size: 18.h,
                                color: isDark ? AppColor.gray400 : AppColor.gray600,
                              ),
                            )
                          : Image.network(
                              artwork.artistProfileImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: isDark ? AppColor.gray700 : AppColor.gray100,
                                child: Icon(
                                  Icons.person,
                                  size: 18.h,
                                  color: isDark ? AppColor.gray400 : AppColor.gray600,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artwork.artistName ?? 'Unknown Artist',
                          style: TextStyle(
                            fontSize: 14.fSize,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            height: 1.05,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Artist',
                          style: TextStyle(
                            fontSize: 12.fSize,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    size: 40.h,
                    bg: arrowBg,
                    icon: Icons.north_east_rounded,
                    iconColor: arrowIcon,
                    borderColor: isAlt
                        ? AppColor.gray600
                        : AppColor.gray900.withOpacity(.75),
                    onTap: onTap,
                    semanticsLabel: 'Open details',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.image_rounded,
        size: 28.h,
        color: isDark ? AppColor.gray400 : AppColor.gray500,
      ),
    );
  }

  String? _pickCover(Artwork a) =>
      a.gallery.isNotEmpty ? a.gallery.first : null;
}

// Reusable circular icon button (heart + arrow)
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final Color? borderColor;
  final double size;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const _RoundIconButton({
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.size,
    this.borderColor,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size / 2),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onTap,
            child: Icon(icon, color: iconColor, size: size * 0.48),
          ),
        ),
      ),
    );
  }
}
