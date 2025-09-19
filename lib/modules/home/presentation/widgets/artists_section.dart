import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/modules/home/data/models/artist_model.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';

class ArtistsSection extends StatefulWidget {
  final List<Artist> artists;
  final String title;
  final EdgeInsetsGeometry? headerPadding;
  final VoidCallback? onSeeMore;
  final void Function(int index)? onArtistTap;
  final bool isLoading;
  final bool showSeeMoreButton;
  final String seeMoreButtonText;
  final DeviceType? deviceTypeOverride;
  final bool enableAutoPlay;
  final Duration autoPlayInterval;

  const ArtistsSection({
    super.key,
    required this.artists,
    this.title = 'Artists',
    this.headerPadding,
    this.onSeeMore,
    this.onArtistTap,
    this.isLoading = false,
    this.showSeeMoreButton = true,
    this.seeMoreButtonText = 'See All Artists',
    this.deviceTypeOverride,
    this.enableAutoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
  });

  @override
  State<ArtistsSection> createState() => _ArtistsSectionState();
}

class _ArtistsSectionState extends State<ArtistsSection> {
  late ScrollController _scrollController;
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();

    if (widget.enableAutoPlay && widget.artists.isNotEmpty) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentPage < widget.artists.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  DeviceType _device(BuildContext context) =>
      widget.deviceTypeOverride ?? Responsive.deviceTypeOf(context);

  // Card metrics per device (horizontal-only redesign)
  double _cardWidth(DeviceType d) => switch (d) {
    DeviceType.mobile => 210.0.sW,
    DeviceType.tablet => 320.0.sW,
    DeviceType.desktop => 360.0.sW,
  };

  double _cardHeight(DeviceType d) => switch (d) {
    DeviceType.mobile => 240.0.sH,
    DeviceType.tablet => 300.0.sH,
    DeviceType.desktop => 300.0.sH,
  };

  double _avatarSize(DeviceType d) => switch (d) {
    DeviceType.mobile => 84.0.sW,
    DeviceType.tablet => 104.0.sW,
    DeviceType.desktop => 112.0.sW,
  };

  double _spacing(DeviceType d) => switch (d) {
    DeviceType.mobile => 12.0.sW,
    DeviceType.tablet => 14.0.sW,
    DeviceType.desktop => 16.0.sW,
  };

  double _headerGap(DeviceType d) => switch (d) {
    DeviceType.desktop => 24.0.sH,
    DeviceType.tablet => 20.0.sH,
    DeviceType.mobile => 16.0.sH,
  };

  @override
  Widget build(BuildContext context) {
    final d = _device(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced header with scroll indicators
        _buildEnhancedHeader(d),
        SizedBox(height: _headerGap(d)),
        if (widget.isLoading)
          _buildEnhancedLoading(d)
        else if (widget.artists.isEmpty)
          _buildEnhancedEmpty(d)
        else
          _buildEnhancedHorizontalList(d),
      ],
    );
  }

  Widget _buildEnhancedHeader(DeviceType d) {
    return SectionHeaderWidget(
      title: widget.title,
      padding: widget.headerPadding ?? EdgeInsets.zero,
      showSeeMore:
          widget.showSeeMoreButton &&
          widget.onSeeMore != null &&
          widget.artists.isNotEmpty,
      onSeeMore: widget.onSeeMore,
      seeMoreButtonText: widget.seeMoreButtonText,
    );
  }

  Widget _buildEnhancedHorizontalList(DeviceType d) {
    final w = _cardWidth(d);
    final h = _cardHeight(d);

    return MouseRegion(
      onEnter: (_) => widget.enableAutoPlay ? _stopAutoPlay() : null,
      onExit: (_) => widget.enableAutoPlay ? _startAutoPlay() : null,
      child: SizedBox(
        height: h,
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.0.sW),
          scrollDirection: Axis.horizontal,
          itemCount: widget.artists.length,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          separatorBuilder: (_, __) => SizedBox(width: _spacing(d)),
          itemBuilder: (context, index) => RepaintBoundary(
            key: ValueKey('artist-${widget.artists[index].id}-$index'),
            child: _EnhancedArtistCard(
              artist: widget.artists[index],
              index: index,
              width: w,
              height: h,
              avatarSize: _avatarSize(d),
              onTap: widget.onArtistTap,
              deviceType: d,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedLoading(DeviceType d) {
    final w = _cardWidth(d);
    final h = _cardHeight(d);

    return SizedBox(
      height: h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.0.sW),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: _spacing(d)),
        itemBuilder: (_, index) => _ShimmerSkeletonCard(
          width: w,
          height: h,
          radius: 18.0.r,
          delay: Duration(milliseconds: index * 200),
        ),
      ),
    );
  }

  Widget _buildEnhancedEmpty(DeviceType d) {
    final iconSize = switch (d) {
      DeviceType.desktop => 48.0.sW,
      DeviceType.tablet => 42.0.sW,
      DeviceType.mobile => 36.0.sW,
    };
    final titleSize = switch (d) {
      DeviceType.desktop => 20.0.sSp,
      DeviceType.tablet => 18.0.sSp,
      DeviceType.mobile => 16.0.sSp,
    };
    final subtitleSize = switch (d) {
      DeviceType.desktop => 16.0.sSp,
      DeviceType.tablet => 14.0.sSp,
      DeviceType.mobile => 12.0.sSp,
    };

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.0.sW),
              padding: EdgeInsets.symmetric(
                vertical: switch (d) {
                  DeviceType.desktop => 48.0.sH,
                  DeviceType.tablet => 40.0.sH,
                  DeviceType.mobile => 32.0.sH,
                },
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.gray50, AppColor.gray50.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(switch (d) {
                  DeviceType.desktop => 20.0.r,
                  DeviceType.tablet => 18.0.r,
                  DeviceType.mobile => 16.0.r,
                }),
                border: Border.all(
                  color: AppColor.gray200.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0.sW),
                    decoration: BoxDecoration(
                      color: AppColor.gray100.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      size: iconSize,
                      color: AppColor.gray400,
                    ),
                  ),
                  SizedBox(height: 16.0.sH),
                  Text(
                    'No artists available',
                    style: TextStyleHelper.instance.title16MediumInter.copyWith(
                      color: AppColor.gray700,
                      fontSize: titleSize,
                    ),
                  ),
                  SizedBox(height: 8.0.sH),
                  Text(
                    'Discover amazing artists and their creative works',
                    textAlign: TextAlign.center,
                    style: TextStyleHelper.instance.body14RegularInter.copyWith(
                      color: AppColor.gray500,
                      fontSize: subtitleSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Enhanced Artist Card with improved animations and interactions
// ============================================================================
class _EnhancedArtistCard extends StatefulWidget {
  final Artist artist;
  final int index;
  final double width;
  final double height;
  final double avatarSize;
  final void Function(int index)? onTap;
  final DeviceType deviceType;

  const _EnhancedArtistCard({
    required this.artist,
    required this.index,
    required this.width,
    required this.height,
    required this.avatarSize,
    required this.onTap,
    required this.deviceType,
  });

  @override
  State<_EnhancedArtistCard> createState() => _EnhancedArtistCardState();
}

class _EnhancedArtistCardState extends State<_EnhancedArtistCard>
    with TickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final AnimationController _tapCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _elevation;
  late final Animation<double> _tapScale;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _entryCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOutCubic));

    _elevation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOutCubic));

    _tapScale = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut));

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _slideIn = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    // Stagger the entry animation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    _tapCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _tapCtrl.forward();
  void _onTapUp(TapUpDetails details) => _tapCtrl.reverse();
  void _onTapCancel() => _tapCtrl.reverse();

  String _locationText(Artist a) {
    final parts = <String>[];
    if ((a.country ?? '').trim().isNotEmpty) parts.add(a.country!.trim());
    if ((a.city ?? '').trim().isNotEmpty) parts.add(a.city!.trim());
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final radius = 18.0.r;
    final artist = widget.artist;
    final about = (artist.about ?? '').trim();
    final loc = _locationText(artist);

    return SlideTransition(
      position: _slideIn,
      child: FadeTransition(
        opacity: _fadeIn,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverCtrl.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverCtrl.reverse();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_scale, _tapScale, _elevation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value * _tapScale.value,
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: Semantics(
                    button: widget.onTap != null,
                    label: 'View artist ${artist.name}',
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(radius),
                      elevation: _elevation.value,
                      shadowColor: AppColor.black.withOpacity(0.15),
                      child: GestureDetector(
                        onTapDown: _onTapDown,
                        onTapUp: _onTapUp,
                        onTapCancel: _onTapCancel,
                        onTap: widget.onTap != null
                            ? () => widget.onTap!(widget.index)
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(radius),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: Stack(
                              children: [
                                // Cover image with parallax effect
                                Positioned.fill(
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween(
                                      begin: 1.0,
                                      end: _isHovered ? 1.1 : 1.0,
                                    ),
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: CustomImageView(
                                          imagePath: artist.gallery.isNotEmpty
                                              ? artist.gallery[0]
                                              : '',
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Dynamic gradient overlay
                                Positioned.fill(
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween(
                                      begin: 0.4,
                                      end: _isHovered ? 0.6 : 0.4,
                                    ),
                                    builder: (context, intensity, child) {
                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              AppColor.black.withOpacity(
                                                intensity * 0.5,
                                              ),
                                              AppColor.black.withOpacity(
                                                intensity,
                                              ),
                                            ],
                                            stops: const [0.2, 0.6, 1.0],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Enhanced frosted info panel
                                Positioned(
                                  left: 12.0.sW,
                                  right: 12.0.sW,
                                  bottom: 12.0.sH,
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween(
                                      begin: 12.0,
                                      end: _isHovered ? 16.0 : 12.0,
                                    ),
                                    builder: (context, blur, child) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          16.0.r,
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: blur,
                                            sigmaY: blur,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(14.0.sW),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                _isHovered ? 0.18 : 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16.0.r),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  _isHovered ? 0.25 : 0.18,
                                                ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Enhanced Avatar
                                                _EnhancedAvatarCircle(
                                                  imagePath:
                                                      artist.profileImage,
                                                  nameForFallback: artist.name,
                                                  size: widget.avatarSize,
                                                  isHovered: _isHovered,
                                                ),
                                                SizedBox(width: 12.0.sW),

                                                // Enhanced text content
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Name + age chip with better typography
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              artist.name,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Inter',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                fontSize:
                                                                    16.0.sSp,
                                                                color: Colors
                                                                    .white,
                                                                height: 1.1,
                                                                letterSpacing:
                                                                    -0.2,
                                                              ),
                                                            ),
                                                          ),
                                                          if (artist.age !=
                                                              null) ...[
                                                            SizedBox(
                                                              width: 8.0.sW,
                                                            ),
                                                            _EnhancedAgeChip(
                                                              age: artist.age!,
                                                              isHovered:
                                                                  _isHovered,
                                                            ),
                                                          ],
                                                        ],
                                                      ),

                                                      if (about.isNotEmpty) ...[
                                                        SizedBox(
                                                          height: 6.0.sH,
                                                        ),
                                                        Text(
                                                          about,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12.0.sSp,
                                                            color: AppColor
                                                                .gray100,
                                                            height: 1.3,
                                                          ),
                                                        ),
                                                      ],

                                                      if (loc.isNotEmpty) ...[
                                                        SizedBox(
                                                          height: 8.0.sH,
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .location_on_rounded,
                                                              size: 14.0.sW,
                                                              color: AppColor
                                                                  .gray200,
                                                            ),
                                                            SizedBox(
                                                              width: 4.0.sW,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                loc,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      11.0.sSp,
                                                                  color: AppColor
                                                                      .gray200,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Enhanced shine effect
                                if (_isHovered)
                                  Positioned(
                                    top: -widget.height * 0.3,
                                    left: -widget.width * 0.3,
                                    child: TweenAnimationBuilder<double>(
                                      duration: const Duration(
                                        milliseconds: 600,
                                      ),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, progress, child) {
                                        return Transform.rotate(
                                          angle: -0.5,
                                          child: Transform.translate(
                                            offset: Offset(
                                              progress * widget.width * 0.5,
                                              progress * widget.height * 0.3,
                                            ),
                                            child: Container(
                                              width: widget.width * 0.6,
                                              height: widget.height * 0.4,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.25,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      0.1,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Enhanced Supporting Widgets
// ============================================================================

class _EnhancedAvatarCircle extends StatelessWidget {
  final String? imagePath;
  final String nameForFallback;
  final double size;
  final bool isHovered;

  const _EnhancedAvatarCircle({
    required this.imagePath,
    required this.nameForFallback,
    required this.size,
    required this.isHovered,
  });

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = (imagePath ?? '').trim().isNotEmpty;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: isHovered ? 1.1 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(isHovered ? 0.3 : 0.2),
                  blurRadius: isHovered ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(isHovered ? 0.5 : 0.35),
                width: isHovered ? 3 : 2,
              ),
            ),
            child: ClipOval(
              child: hasImg
                  ? CustomImageView(imagePath: imagePath!, fit: BoxFit.cover)
                  : Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.gray600,
                            AppColor.gray700,
                            AppColor.gray900,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Text(
                        _initials(nameForFallback),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: (size * 0.32).clamp(12.0, 28.0),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedAgeChip extends StatelessWidget {
  final int age;
  final bool isHovered;

  const _EnhancedAgeChip({required this.age, required this.isHovered});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: isHovered ? 1.05 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.0.sW,
              vertical: 5.0.sH,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.white.withOpacity(isHovered ? 1.0 : 0.95),
                  AppColor.white.withOpacity(isHovered ? 0.98 : 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: AppColor.gray200.withOpacity(isHovered ? 0.8 : 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(isHovered ? 0.15 : 0.08),
                  blurRadius: isHovered ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$age',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 10.0.sSp,
                color: AppColor.gray900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerSkeletonCard extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final Duration delay;

  const _ShimmerSkeletonCard({
    required this.width,
    required this.height,
    required this.radius,
    required this.delay,
  });

  @override
  State<_ShimmerSkeletonCard> createState() => _ShimmerSkeletonCardState();
}

class _ShimmerSkeletonCardState extends State<_ShimmerSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _shimmerController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColor.gray100, AppColor.gray50, AppColor.gray100],
              stops: [
                (0.3 + _shimmerAnimation.value * 0.1).clamp(0.0, 1.0),
                (0.5 + _shimmerAnimation.value * 0.1).clamp(0.0, 1.0),
                (0.7 + _shimmerAnimation.value * 0.1).clamp(0.0, 1.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Stack(
              children: [
                // Animated shimmer overlay
                Positioned(
                  top: 0,
                  left: widget.width * _shimmerAnimation.value,
                  child: Container(
                    width: widget.width * 0.5,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Mock content areas
                Positioned(
                  bottom: 12.0.sH,
                  left: 12.0.sW,
                  right: 12.0.sW,
                  child: Container(
                    padding: EdgeInsets.all(12.0.sW),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.0.r),
                    ),
                    child: Row(
                      children: [
                        // Mock avatar
                        Container(
                          width: 60.0.sW,
                          height: 60.0.sW,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.0.sW),

                        // Mock text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 14.0.sH,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4.0.r),
                                ),
                              ),
                              SizedBox(height: 6.0.sH),
                              Container(
                                width: double.infinity * 0.7,
                                height: 12.0.sH,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4.0.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
