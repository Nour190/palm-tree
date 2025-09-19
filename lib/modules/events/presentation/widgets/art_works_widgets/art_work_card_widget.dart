import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

enum ArtworkCardViewType { list, grid }

class ArtWorkCardWidget extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback? onTap;
  final ArtworkCardViewType viewType;

  const ArtWorkCardWidget({
    super.key,
    required this.artwork,
    this.onTap,
    this.viewType = ArtworkCardViewType.list,
  });

  @override
  State<ArtWorkCardWidget> createState() => _ArtWorkCardWidgetState();
}

class _ArtWorkCardWidgetState extends State<ArtWorkCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _hoverCtrl = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final Animation<double> _hoverScale = Tween(
    begin: 1.0,
    end: 1.02,
  ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _hoverScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverScale.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: widget.viewType == ArtworkCardViewType.list
                  ? _buildListCard(isDark, isMobile)
                  : _buildGridCard(isDark, isMobile),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListCard(bool isDark, bool isMobile) {
    final art = widget.artwork;
    final cover = _pickCover(art);

    final isAlternate = art.id.hashCode % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isAlternate
            ? AppColor.backgroundBlack  // Always dark for alternate cards
            : (isDark ? AppColor.gray700 : AppColor.white),  // Dark gray or white
        borderRadius: BorderRadius.circular(16.h),
        border: isAlternate
            ? null
            : Border.all(
          color: isDark ? AppColor.gray600 : AppColor.gray200,
          width: 1,
        ),
        boxShadow: isAlternate ? [
          BoxShadow(
            color: AppColor.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.h),
              child: Container(
                width: isMobile ? 100.sW : 140.sW,
                height: isMobile ? 100.sH : 140.sH,
                decoration: BoxDecoration(
                  color: isDark ? AppColor.gray700 : AppColor.gray100,
                ),
                child: cover == null || cover.isEmpty
                    ? _buildImagePlaceholder(isDark)
                    : Image.network(
                  cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(isDark),
                ),
              ),
            ),

            SizedBox(width: 16.h),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    art.name,
                    style: TextStyle(
                      fontSize: isMobile ? 18.fSize : 22.fSize,
                      fontWeight: FontWeight.w600,
                      color: isAlternate
                          ? AppColor.white  // White text on dark background
                          : (isDark ? AppColor.white : AppColor.gray900),  // White on dark theme, dark text on light theme
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8.h),

                  // Description
                  if (art.description != null && art.description!.isNotEmpty)
                    Text(
                      art.description!,
                      style: TextStyle(
                        fontSize: isMobile ? 14.fSize : 16.fSize,
                        color: isAlternate
                            ? AppColor.gray400  // Light gray on dark background
                            : (isDark ? AppColor.gray400 : AppColor.gray600),  // Light gray on dark, dark gray on light
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 16.h),

                  // Artist info
                  Row(
                    children: [
                      // Artist avatar
                      Container(
                        width: 32.h,
                        height: 32.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAlternate
                                ? AppColor.gray500  // Visible border on dark background
                                : (isDark ? AppColor.gray600 : AppColor.gray400),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: art.artistProfileImage == null || art.artistProfileImage!.isEmpty
                              ? Container(
                            color: isDark ? AppColor.gray700 : AppColor.gray100,
                            child: Icon(
                              Icons.person,
                              size: 16.h,
                              color: isDark ? AppColor.gray400 : AppColor.gray600,
                            ),
                          )
                              : Image.network(
                            art.artistProfileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: isDark ? AppColor.gray700 : AppColor.gray100,
                              child: Icon(
                                Icons.person,
                                size: 16.h,
                                color: isDark ? AppColor.gray400 : AppColor.gray600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 8.h),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              art.artistName ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 14.fSize,
                                fontWeight: FontWeight.w500,
                                color: isAlternate
                                    ? AppColor.white  // White on dark background
                                    : (isDark ? AppColor.white : AppColor.gray900),  // White on dark, dark on light
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Artist',
                              style: TextStyle(
                                fontSize: 12.fSize,
                                color: isAlternate
                                    ? AppColor.gray400  // Light gray on dark background
                                    : (isDark ? AppColor.gray400 : AppColor.gray600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 16.h),

            Column(
              children: [
                // Heart/Like button
                Container(
                  width: 44.h,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: isAlternate
                        ? AppColor.gray700  // Dark gray on dark background
                        : (isDark ? AppColor.gray700 : AppColor.gray100),
                    borderRadius: BorderRadius.circular(22.h),
                    border: Border.all(
                      color: isAlternate
                          ? AppColor.gray600  // Visible border
                          : (isDark ? AppColor.gray600 : AppColor.gray200),
                    ),
                  ),
                  child: Material(
                    color: AppColor.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22.h),
                      onTap: () {
                        // Handle like action
                      },
                      child: Icon(
                        Icons.favorite_border,
                        color: isAlternate
                            ? AppColor.white  // White icon on dark background
                            : (isDark ? AppColor.white : AppColor.gray600),
                        size: 20.h,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Arrow/Navigate button
                Container(
                  width: 44.h,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: isAlternate
                        ? AppColor.gray700  // Dark gray on dark background
                        : (isDark ? AppColor.gray700 : AppColor.gray100),
                    borderRadius: BorderRadius.circular(22.h),
                    border: Border.all(
                      color: isAlternate
                          ? AppColor.gray600  // Visible border
                          : (isDark ? AppColor.gray600 : AppColor.gray200),
                    ),
                  ),
                  child: Material(
                    color: AppColor.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22.h),
                      onTap: widget.onTap,
                      child: Icon(
                        Icons.arrow_forward,
                        color: isAlternate
                            ? AppColor.white  // White icon on dark background
                            : (isDark ? AppColor.white : AppColor.gray600),
                        size: 20.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(bool isDark, bool isMobile) {
    final art = widget.artwork;
    final cover = _pickCover(art);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColor.gray700 : AppColor.white,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(
          color: isDark ? AppColor.gray600 : AppColor.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite icon overlay
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColor.gray600 : AppColor.gray100,
                    ),
                    child: cover == null || cover.isEmpty
                        ? _buildImagePlaceholder(isDark)
                        : Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(isDark),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.h,
                  child: Container(
                    width: 36.h,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColor.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18.h),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: AppColor.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18.h),
                        onTap: () {
                          // Handle favorite action
                        },
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColor.gray600,
                          size: 18.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    art.name,
                    style: TextStyle(
                      fontSize: 16.fSize,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.white : AppColor.gray900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6.h),

                  // Small description under title
                  if (art.description != null && art.description!.isNotEmpty)
                    Text(
                      art.description!,
                      style: TextStyle(
                        fontSize: 13.fSize,
                        color: isDark ? AppColor.gray400 : AppColor.gray600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 18.h),

                  // Artist info
                  Row(
                    children: [
                      Container(
                        width: 24.h,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColor.gray600 : AppColor.gray200,
                          ),
                        ),
                        child: ClipOval(
                          child: art.artistProfileImage == null || art.artistProfileImage!.isEmpty
                              ? Container(
                            color: isDark ? AppColor.gray600 : AppColor.gray100,
                            child: Icon(
                              Icons.person,
                              size: 12.h,
                              color: isDark ? AppColor.gray400 : AppColor.gray600,
                            ),
                          )
                              : Image.network(
                            art.artistProfileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: isDark ? AppColor.gray600 : AppColor.gray100,
                              child: Icon(
                                Icons.person,
                                size: 12.h,
                                color: isDark ? AppColor.gray400 : AppColor.gray600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 6.h),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              art.artistName ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 13.fSize,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColor.white : AppColor.gray900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Artist',
                              style: TextStyle(
                                fontSize: 11.fSize,
                                color: isDark ? AppColor.gray400 : AppColor.gray600,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColor.gray600 : AppColor.gray100,
      ),
      child: Icon(
        Icons.image_rounded,
        size: 32.h,
        color: isDark ? AppColor.gray400 : AppColor.gray600,
      ),
    );
  }

  String? _pickCover(Artwork a) {
    if (a.gallery.isNotEmpty) return a.gallery.first;
    return null;
  }
}
