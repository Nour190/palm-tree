import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/artwork_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';

class ArtWorkCardWidget extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback? onTap;
  final bool isGridView;

  const ArtWorkCardWidget({
    super.key,
    required this.artwork,
    this.onTap,
    this.isGridView = false,
  });

  @override
  State<ArtWorkCardWidget> createState() => _ArtWorkCardWidgetState();
}

class _ArtWorkCardWidgetState extends State<ArtWorkCardWidget>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _scaleCtrl = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final AnimationController _hoverCtrl = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  late final AnimationController _shimmerCtrl = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );

  // Animations
  late final Animation<double> _scale = Tween(
    begin: 1.0,
    end: 0.98,
  ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));

  late final Animation<double> _hoverScale = Tween(
    begin: 1.0,
    end: 1.02,
  ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOutCubic));

  late final Animation<double> _shadowIntensity = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));

  late final Animation<double> _shimmer = Tween(
    begin: -1.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl.repeat();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _hoverCtrl.dispose();
    _shimmerCtrl.dispose();
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

  void _onFocusChange(bool isFocused) {
    if (_isFocused != isFocused) {
      setState(() => _isFocused = isFocused);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isMobile = screenWidth < 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final art = widget.artwork;
    final artistName = art.artistName ?? 'Unknown Artist';
    final artistImg = art.artistProfileImage;
    final cover = _pickCover(art);

    // Responsive layout decision
    final shouldUseHorizontalLayout =
        !widget.isGridView && (isTablet || isDesktop);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Focus(
        onFocusChange: _onFocusChange,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scale, _hoverScale, _shadowIntensity]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value * _hoverScale.value,
              child: GestureDetector(
                onTapDown: (_) => _scaleCtrl.forward(),
                onTapUp: (_) {
                  _scaleCtrl.reverse();
                  widget.onTap?.call();
                },
                onTapCancel: () => _scaleCtrl.reverse(),
                child: _buildCard(
                  context,
                  shouldUseHorizontalLayout,
                  isDark,
                  isMobile,
                  isTablet,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isHorizontal,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.h : 16.h,
        vertical: 8.h,
      ),
      padding: EdgeInsets.all(isMobile ? 12.h : 20.h),
      decoration: _buildCardDecoration(isDark, isMobile),
      child: isHorizontal
          ? _buildHorizontalLayout(isDark, isMobile, isTablet)
          : _buildVerticalLayout(isDark, isMobile),
    );
  }

  BoxDecoration _buildCardDecoration(bool isDark, bool isMobile) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1B1E) : Colors.white,
      borderRadius: BorderRadius.circular(isMobile ? 16.h : 24.h),
      border: isDark
          ? Border.all(
              color: _isHovered
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1.h,
            )
          : Border.all(
              color: _isHovered
                  ? AppColor.gray900.withOpacity(0.2)
                  : AppColor.gray900.withOpacity(0.08),
              width: 1.h,
            ),
      boxShadow: [
        // Base shadow
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        // Hover shadow
        if (_shadowIntensity.value > 0)
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.1 * _shadowIntensity.value)
                : Colors.black.withOpacity(0.12 * _shadowIntensity.value),
            blurRadius: 32 * _shadowIntensity.value,
            offset: Offset(0, 12 * _shadowIntensity.value),
          ),
        // Focus shadow
        if (_isFocused)
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  Widget _buildHorizontalLayout(bool isDark, bool isMobile, bool isTablet) {
    final art = widget.artwork;
    final artistName = art.artistName ?? 'Unknown Artist';
    final artistImg = art.artistProfileImage;
    final cover = _pickCover(art);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Artwork Image
          _buildArtworkImage(cover, isDark, isMobile, isHorizontal: true),

          SizedBox(width: isMobile ? 12.h : 20.h),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildContentSection(isDark, isMobile),
                SizedBox(height: 16.h),
                _buildArtistSection(artistImg, artistName, isDark, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(bool isDark, bool isMobile) {
    final art = widget.artwork;
    final artistName = art.artistName ?? 'Unknown Artist';
    final artistImg = art.artistProfileImage;
    final cover = _pickCover(art);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Artwork Image
        _buildArtworkImage(cover, isDark, isMobile, isHorizontal: false),

        SizedBox(height: isMobile ? 12.h : 16.h),

        // Content
        _buildContentSection(isDark, isMobile),

        SizedBox(height: isMobile ? 12.h : 20.h),

        // Artist Section
        _buildArtistSection(artistImg, artistName, isDark, isMobile),
      ],
    );
  }

  Widget _buildArtworkImage(
    String? cover,
    bool isDark,
    bool isMobile, {
    required bool isHorizontal,
  }) {
    final imageWidth = isHorizontal
        ? (isMobile ? 120.h : 200.h)
        : double.infinity;
    final imageHeight = isHorizontal
        ? (isMobile ? 140.h : 220.h)
        : (isMobile ? 200.h : 280.h);

    return Hero(
      tag: 'artwork_${widget.artwork.id}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 12.h : 16.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 12.h : 16.h),
          child: Stack(
            children: [
              _EnhancedNetImage(
                url: cover,
                width: imageWidth,
                height: imageHeight,
              ),
              // Shimmer overlay for loading
              if (_isHovered && cover != null)
                AnimatedBuilder(
                  animation: _shimmer,
                  builder: (context, child) {
                    return Container(
                      width: imageWidth,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: [
                            (_shimmer.value - 0.3).clamp(0.0, 1.0),
                            _shimmer.value.clamp(0.0, 1.0),
                            (_shimmer.value + 0.3).clamp(0.0, 1.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(bool isDark, bool isMobile) {
    final art = widget.artwork;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with gradient text effect
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style:
              (isMobile
                      ? TextStyleHelper.instance.headline24MediumInter.copyWith(
                          fontSize: 18.h,
                        )
                      : TextStyleHelper.instance.headline24MediumInter)
                  .copyWith(
                    color: isDark ? Colors.white : AppColor.gray900,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
          child: Text(art.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),

        SizedBox(height: 8.h),

        // Description with better typography
        if ((art.description ?? '').isNotEmpty)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style:
                (isMobile
                        ? TextStyleHelper.instance.title16LightInter.copyWith(
                            fontSize: 14.h,
                          )
                        : TextStyleHelper.instance.title16LightInter)
                    .copyWith(
                      color: (isDark ? Colors.white : AppColor.gray900)
                          .withOpacity(0.75),
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
            child: Text(
              art.description!,
              maxLines: isMobile ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        SizedBox(height: 12.h),

        // Enhanced tags with animations
        _buildAnimatedTags(art, isDark, isMobile),
      ],
    );
  }

  Widget _buildAnimatedTags(Artwork art, bool isDark, bool isMobile) {
    final tags = <String>[];
    if ((art.materials ?? '').isNotEmpty) tags.add('Materials');
    if ((art.vision ?? '').isNotEmpty) tags.add('Vision');

    if (tags.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: Wrap(
        spacing: 8.h,
        runSpacing: 6.h,
        children: tags.asMap().entries.map((entry) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (entry.key * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: _EnhancedChip(
                    text: entry.value,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArtistSection(
    String? artistImg,
    String artistName,
    bool isDark,
    bool isMobile,
  ) {
    return Row(
      children: [
        _EnhancedAvatar(url: artistImg, isMobile: isMobile),
        SizedBox(width: 12.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artistName,
                style:
                    (isMobile
                            ? TextStyleHelper.instance.headline24MediumInter
                                  .copyWith(fontSize: 16.h)
                            : TextStyleHelper.instance.headline24MediumInter
                                  .copyWith(fontSize: 18.h))
                        .copyWith(
                          color: isDark ? Colors.white : AppColor.gray900,
                          letterSpacing: -0.3,
                        ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                'Artist',
                style: TextStyleHelper.instance.title16LightInter.copyWith(
                  color: (isDark ? Colors.white : AppColor.gray900).withOpacity(
                    0.6,
                  ),
                  fontSize: isMobile ? 12.h : 14.h,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        _buildActionButton(isDark, isMobile),
      ],
    );
  }

  Widget _buildActionButton(bool isDark, bool isMobile) {
    final buttonSize = isMobile ? 44.h : 56.h;

    return AnimatedBuilder(
      animation: _hoverCtrl,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.05 * _hoverCtrl.value),
          child: _EnhancedCircleButton(
            onPressed: widget.onTap,
            icon: Icons.arrow_forward_rounded,
            size: buttonSize,
            bg: isDark ? Colors.white : AppColor.gray900,
            fg: isDark ? AppColor.gray900 : Colors.white,
            isHovered: _isHovered,
          ),
        );
      },
    );
  }

  String? _pickCover(Artwork a) {
    if (a.gallery.isNotEmpty) return a.gallery.first;
    return null;
  }
}

// Enhanced Network Image with better loading states
class _EnhancedNetImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;

  const _EnhancedNetImage({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      width: width,
      height: height,
      child: Image.network(
        url!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, _) {
              return Opacity(
                opacity: wasSynchronouslyLoaded || frame != null ? value : 0.0,
                child: child,
              );
            },
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildPlaceholder(),
              Center(
                child: SizedBox(
                  width: 24.h,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value:
                        progress.cumulativeBytesLoaded /
                        (progress.expectedTotalBytes ?? 1),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[200]!, Colors.grey[100]!, Colors.grey[200]!],
        ),
      ),
      child: Icon(
        Icons.image_rounded,
        size: (width * 0.2).clamp(24.0, 48.0),
        color: Colors.grey[400],
      ),
    );
  }
}

// Enhanced Avatar with better styling
class _EnhancedAvatar extends StatelessWidget {
  final String? url;
  final bool isMobile;

  const _EnhancedAvatar({required this.url, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 44.h : 54.h;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.gray900.withOpacity(0.1),
          width: 2.h,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: (url == null || url!.isEmpty)
              ? _buildPlaceholder(size)
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(size),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildPlaceholder(size),
                        Center(
                          child: SizedBox(
                            width: size * 0.4,
                            height: size * 0.4,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[200]!, Colors.grey[100]!],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }
}

// Enhanced Chip with better styling
class _EnhancedChip extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool isMobile;

  const _EnhancedChip({
    required this.text,
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.h : 12.h,
        vertical: isMobile ? 4.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : AppColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 8.h : 12.h),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 10.fSize : 12.fSize,
          color: isDark ? Colors.white.withOpacity(0.9) : AppColor.primaryColor,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// Enhanced Circle Button with better interactions
class _EnhancedCircleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color bg;
  final Color fg;
  final bool isHovered;

  const _EnhancedCircleButton({
    required this.onPressed,
    required this.icon,
    required this.size,
    required this.bg,
    required this.fg,
    required this.isHovered,
  });

  @override
  State<_EnhancedCircleButton> createState() => _EnhancedCircleButtonState();
}

class _EnhancedCircleButtonState extends State<_EnhancedCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          _rippleController.forward().then((_) {
            _rippleController.reverse();
          });
          widget.onPressed?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.bg.withOpacity(widget.isHovered ? 0.3 : 0.1),
                blurRadius: widget.isHovered ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (_rippleAnimation.value > 0)
                    Container(
                      width: widget.size * _rippleAnimation.value,
                      height: widget.size * _rippleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.fg.withOpacity(
                          0.2 * (1 - _rippleAnimation.value),
                        ),
                      ),
                    ),
                  Icon(widget.icon, color: widget.fg, size: widget.size * 0.4),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
