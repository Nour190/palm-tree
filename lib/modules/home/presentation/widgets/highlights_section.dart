// enhanced_highlights_section.dart
//

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:card_swiper/card_swiper.dart';

import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/core/responsive/responsive.dart';

class EnhancedHighlightsSection extends StatefulWidget {
  final List<String> images;
  final String title;
  final VoidCallback? onSeeMore;
  final VoidCallback? onHighlightTap;
  final bool isLoading;
  final bool showSeeMoreButton;
  final String seeMoreButtonText;
  final bool autoPlay;
  final EdgeInsetsGeometry? headerPadding;
  final List<String>? titles;
  final List<String>? descriptions;

  const EnhancedHighlightsSection({
    super.key,
    required this.images,
    this.title = 'Highlights',
    this.onSeeMore,
    this.onHighlightTap,
    this.isLoading = false,
    this.showSeeMoreButton = true,
    this.seeMoreButtonText = 'View All',
    this.autoPlay = true,
    this.headerPadding,
    this.titles,
    this.descriptions,
  });

  @override
  State<EnhancedHighlightsSection> createState() =>
      _EnhancedHighlightsSectionState();
}

class _EnhancedHighlightsSectionState extends State<EnhancedHighlightsSection>
    with TickerProviderStateMixin {
  // ── State Management
  int _currentIndex = 0;
  bool _hovering = false;
  final PageController _mobilePageController = PageController(
    viewportFraction: 0.85,
  );
  final ScrollController _desktopScrollController = ScrollController();

  // ── Animation Controllers
  late final AnimationController _fadeController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  )..forward();

  late final AnimationController _autoPlayController = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  );

  late final AnimationController _hoverController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  // ── Swiper & Focus
  final SwiperController _swiperController = SwiperController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'HighlightsFocus');

  bool _didInitializeDependencies = false;

  // ── Responsive Breakpoints
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;
  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  // ── Layout Configuration
  double get _maxContentWidth {
    if (_isDesktop) return 1400; // Prevent ultra-wide stretching
    if (_isTablet) return 1024;
    return double.infinity;
  }

  double get _horizontalPadding {
    if (_isDesktop) return 32;
    if (_isTablet) return 24;
    return 16;
  }

  double get _borderRadius {
    if (_isDesktop) return 24;
    if (_isTablet) return 20;
    return 16;
  }

  // ── Aspect Ratios (prevents "too big" feeling)
  double get _heroAspectRatio => _isDesktop ? 2.2 : 1.8; // Wider but controlled
  double get _cardAspectRatio => _isMobile ? 1.5 : 1.6; // Taller on mobile

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitializeDependencies) {
      _didInitializeDependencies = true;
      _initializeAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant EnhancedHighlightsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.images.length != widget.images.length) {
      _initializeAutoPlay();
    }
  }

  void _initializeAutoPlay() {
    _autoPlayController.stop();
    _autoPlayController.reset();
    if (widget.autoPlay && widget.images.length > 1 && _isDesktop) {
      _autoPlayController.repeat();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _autoPlayController.dispose();
    _hoverController.dispose();
    _swiperController.dispose();
    _focusNode.dispose();
    _mobilePageController.dispose();
    _desktopScrollController.dispose();
    super.dispose();
  }

  // ── Navigation Methods
  void _navigatePrevious() {
    if (_isDesktop) {
      _swiperController.previous(animation: true);
    } else {
      final newIndex = _currentIndex > 0
          ? _currentIndex - 1
          : widget.images.length - 1;
      _mobilePageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    _restartAutoPlay();
  }

  void _navigateNext() {
    if (_isDesktop) {
      _swiperController.next(animation: true);
    } else {
      final newIndex = _currentIndex < widget.images.length - 1
          ? _currentIndex + 1
          : 0;
      _mobilePageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    _restartAutoPlay();
  }

  void _jumpToIndex(int index) {
    if (_isDesktop) {
      _swiperController.move(index, animation: true);
    } else {
      _mobilePageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    _restartAutoPlay();
  }

  void _restartAutoPlay() {
    if (widget.autoPlay && widget.images.length > 1 && _isDesktop) {
      _autoPlayController
        ..stop()
        ..reset()
        ..forward();
    }
  }

  void _onHoverChanged(bool hovering) {
    if (_isDesktop) {
      setState(() => _hovering = hovering);
      if (hovering) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutQuart,
      ),
      child: _buildMainLayout(),
    );
  }

  Widget _buildMainLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with enhanced styling
        // Content based on state and layout
        if (widget.isLoading)
          _buildLoadingState()
        else if (widget.images.isEmpty)
          _buildEmptyState()
        else if (_isDesktop)
          _buildDesktopLayout()
        else
          _buildMobileTabletLayout(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DESKTOP LAYOUT - Cinematic Hero Carousel
  // ═══════════════════════════════════════════════════════════

  Widget _buildDesktopLayout() {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onFocusChange: (hasFocus) => setState(() {}),
      onKeyEvent: _handleKeyboardNavigation,
      child: Column(
        children: [
          // Main Hero Carousel
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: _buildDesktopCarousel(),
              ),
            ),
          ),

          // Thumbnails & Controls
          if (widget.images.length > 1) ...[
            const SizedBox(height: 24),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                  child: _buildDesktopThumbnails(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopCarousel() {
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: AspectRatio(
        aspectRatio: _heroAspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_borderRadius),
            child: Stack(
              children: [_buildSwiperWidget(), _buildDesktopOverlays()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwiperWidget() {
    return Swiper(
      controller: _swiperController,
      itemCount: widget.images.length,
      viewportFraction: 0.94, // Show slight peek of adjacent slides
      scale: 1.0,
      loop: widget.images.length > 1,
      autoplay: widget.autoPlay && widget.images.length > 1,
      autoplayDelay: 5000,
      duration: 800,
      curve: Curves.easeInOutCubic,
      physics: widget.images.length > 1
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      onIndexChanged: (index) {
        setState(() => _currentIndex = index);
        _restartAutoPlay();
      },
      itemBuilder: (context, index) => _DesktopHeroCard(
        imagePath: widget.images[index],
        title: widget.titles?[index] ?? 'Featured Highlight ${index + 1}',
        description:
            widget.descriptions?[index] ??
            'Discover amazing content and experiences',
        borderRadius: _borderRadius,
        onTap: widget.onHighlightTap,
        index: index,
      ),
    );
  }

  Widget _buildDesktopOverlays() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Progress Bar
          if (widget.autoPlay && widget.images.length > 1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _autoPlayController,
                builder: (context, child) => Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: LinearProgressIndicator(
                    value: _autoPlayController.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ),

          // Navigation Arrows
          if (widget.images.length > 1 && (_hovering || _focusNode.hasFocus))
            ..._buildDesktopNavigationArrows(),

          // Index Counter
          if (widget.images.length > 1)
            Positioned(right: 20, bottom: 20, child: _buildIndexCounter()),
        ],
      ),
    );
  }

  List<Widget> _buildDesktopNavigationArrows() {
    return [
      // Left Arrow
      Positioned(
        left: 16,
        top: 0,
        bottom: 0,
        child: Center(
          child: _DesktopNavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: _navigatePrevious,
            hoverAnimation: _hoverController,
          ),
        ),
      ),
      // Right Arrow
      Positioned(
        right: 16,
        top: 0,
        bottom: 0,
        child: Center(
          child: _DesktopNavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: _navigateNext,
            hoverAnimation: _hoverController,
          ),
        ),
      ),
    ];
  }

  Widget _buildIndexCounter() {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_hoverController.value * 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.images.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.responsiveFontSize(context, 13),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopThumbnails() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _DesktopThumbnail(
          imagePath: widget.images[index],
          isSelected: index == _currentIndex,
          onTap: () => _jumpToIndex(index),
          borderRadius: _borderRadius * 0.6,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MOBILE/TABLET LAYOUT - Card Grid with Snap Scrolling
  // ═══════════════════════════════════════════════════════════

  Widget _buildMobileTabletLayout() {
    return Column(
      children: [
        // Horizontal scrolling cards
        SizedBox(
          height: _calculateMobileCardHeight(),
          child: PageView.builder(
            controller: _mobilePageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) => _MobileCard(
              imagePath: widget.images[index],
              title: widget.titles?[index] ?? 'Highlight ${index + 1}',
              description: widget.descriptions?[index] ?? 'Tap to explore',
              aspectRatio: _cardAspectRatio,
              borderRadius: _borderRadius,
              onTap: widget.onHighlightTap,
              isMobile: _isMobile,
            ),
          ),
        ),

        // Dots Indicator
        if (widget.images.length > 1) ...[
          const SizedBox(height: 16),
          _buildDotsIndicator(),
        ],
      ],
    );
  }

  double _calculateMobileCardHeight() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85 - (_isMobile ? 8 : 12);
    return cardWidth / _cardAspectRatio;
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length,
        (index) => _DotIndicator(
          isActive: index == _currentIndex,
          onTap: () => _jumpToIndex(index),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOADING & EMPTY STATES
  // ═══════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: AspectRatio(
            aspectRatio: _isDesktop ? _heroAspectRatio : _cardAspectRatio,
            child: _ShimmerLoading(borderRadius: _borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: AspectRatio(
            aspectRatio: _isDesktop ? _heroAspectRatio : _cardAspectRatio,
            child: _EmptyStateCard(borderRadius: _borderRadius),
          ),
        ),
      ),
    );
  }

  // ── Keyboard Navigation Handler
  KeyEventResult _handleKeyboardNavigation(FocusNode node, KeyEvent event) {
    if (!_isDesktop || widget.images.length <= 1) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _navigatePrevious();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _navigateNext();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}

// ═══════════════════════════════════════════════════════════
// DESKTOP COMPONENTS
// ═══════════════════════════════════════════════════════════

class _DesktopHeroCard extends StatelessWidget {
  const _DesktopHeroCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.borderRadius,
    required this.index,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String description;
  final double borderRadius;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            CustomImageView(imagePath: imagePath, fit: BoxFit.cover),

            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopNavButton extends StatelessWidget {
  const _DesktopNavButton({
    required this.icon,
    required this.onPressed,
    required this.hoverAnimation,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Animation<double> hoverAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: hoverAnimation,
      builder: (context, child) {
        final label = icon == Icons.chevron_left_rounded
            ? 'Previous highlight'
            : 'Next highlight';
        return Transform.scale(
          scale: 1.0 + (hoverAnimation.value * 0.1),
          child: Semantics(
            button: true,
            label: label,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColor.gray700, size: 28),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopThumbnail extends StatelessWidget {
  const _DesktopThumbnail({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
  });

  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open highlight',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : AppColor.gray200,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomImageView(imagePath: imagePath, fit: BoxFit.cover),
              if (isSelected)
                Container(color: AppColor.primaryColor.withOpacity(0.15)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MOBILE/TABLET COMPONENTS
// ═══════════════════════════════════════════════════════════

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.aspectRatio,
    required this.borderRadius,
    required this.isMobile,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String description;
  final double aspectRatio;
  final double borderRadius;
  final bool isMobile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isMobile ? 12 : 16,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomImageView(imagePath: imagePath, fit: BoxFit.cover),

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              _MobileCardContent(
                title: title,
                description: description,
                isMobile: isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileCardContent extends StatelessWidget {
  const _MobileCardContent({
    required this.title,
    required this.description,
    required this.isMobile,
  });

  final String title;
  final String description;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.responsiveFontSize(
              context,
              isMobile ? 18 : 20,
            ),
            fontWeight: FontWeight.bold,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: Responsive.responsiveFontSize(
              context,
              isMobile ? 14 : 15,
            ),
            fontWeight: FontWeight.w400,
            height: 1.3,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 32 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? AppColor.primaryColor : AppColor.gray400,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// LOADING & EMPTY STATE COMPONENTS
// ═══════════════════════════════════════════════════════════

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading({required this.borderRadius});

  final double borderRadius;

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
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

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColor.gray100,
                  AppColor.gray200.withOpacity(0.5),
                  AppColor.gray100,
                ],
                stops: [
                  math.max(0.0, _shimmerAnimation.value - 0.3),
                  _shimmerAnimation.value,
                  math.min(1.0, _shimmerAnimation.value + 0.3),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: AppColor.gray400,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.gray50, AppColor.white, AppColor.gray50],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColor.gray200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              size: 32,
              color: AppColor.gray500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No highlights available',
            style: TextStyle(
              color: AppColor.gray600,
              fontSize: Responsive.responsiveFontSize(context, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              color: AppColor.gray500,
              fontSize: Responsive.responsiveFontSize(context, 14),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ENHANCED INTERACTIVE FEATURES
// ═══════════════════════════════════════════════════════════

/// Extension to add haptic feedback on interactions
extension HapticFeedbackExtensions on Widget {
  Widget withHapticFeedback() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: this,
    );
  }
}
