import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'common/custom_image_view.dart';

class ResponsiveGallery extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> imageUrls;
  final bool isMobile, isTablet, isDesktop;
  final bool isLoading;
  final VoidCallback? onSeeMore;
  final VoidCallback? onRefresh;
  final Function(int)? onImageTap;
  final String seeMoreText;
  final bool showShimmer;
  final int? maxItems;

  const ResponsiveGallery({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrls,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    this.isLoading = false,
    this.onSeeMore,
    this.onRefresh,
    this.onImageTap,
    this.seeMoreText = "See More",
    this.showShimmer = true,
    this.maxItems,
  });

  @override
  State<ResponsiveGallery> createState() => _ResponsiveGalleryState();
}

class _ResponsiveGalleryState extends State<ResponsiveGallery>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = widget.isDesktop
        ? 4
        : widget.isTablet
        ? 3
        : 2;
    final spacing = widget.isDesktop
        ? 20.0
        : widget.isTablet
        ? 16.0
        : 12.0;
    final ratio = widget.isDesktop
        ? 4 / 5
        : widget.isTablet
        ? 3 / 4
        : 1.0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header
            SectionHeaderWidget(
              title: widget.title,
              showSeeMore: widget.onSeeMore != null,
              onSeeMore: widget.onSeeMore,
              seeMoreButtonText: widget.seeMoreText,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isDesktop ? 24 : 16,
              ),
            ),

            // Subtitle if provided
            if (widget.subtitle != null) ...[
              SizedBox(height: spacing * 0.3),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isDesktop ? 24 : 16,
                ),
                child: Text(
                  widget.subtitle!,
                  style: TextStyleHelper.instance.title14MediumInter.copyWith(
                    color: AppColor.gray600,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            SizedBox(height: spacing),

            // Gallery Grid with Enhanced UI
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isDesktop ? 24 : 16,
              ),
              child: _buildGalleryContent(crossAxisCount, spacing, ratio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryContent(
    int crossAxisCount,
    double spacing,
    double ratio,
  ) {
    if (widget.isLoading && widget.imageUrls.isEmpty) {
      return _buildShimmerGrid(crossAxisCount, spacing, ratio);
    }

    final displayImages = widget.maxItems != null
        ? widget.imageUrls.take(widget.maxItems!).toList()
        : widget.imageUrls;

    final itemCount = displayImages.isEmpty ? 8 : displayImages.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: ratio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildGalleryItem(displayImages, index, spacing);
      },
    );
  }

  Widget _buildGalleryItem(List<String> images, int index, double spacing) {
    final hasImage = index < images.length;
    final borderRadius = widget.isDesktop
        ? 24.0
        : widget.isTablet
        ? 20.0
        : 16.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      child: Hero(
        tag: hasImage ? 'gallery_image_$index' : 'placeholder_$index',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasImage ? () => widget.onImageTap?.call(index) : null,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColor.primaryColor.withOpacity(0.1),
            highlightColor: AppColor.primaryColor.withOpacity(0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.gray900.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColor.gray900.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or Placeholder
                    hasImage ? _buildImage(images[index]) : _buildPlaceholder(),

                    // Gradient Overlay for better text readability
                    if (hasImage)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.3),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),

                    // Interactive Overlay
                    if (hasImage) _buildInteractiveOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomImageView(imagePath: imageUrl, fit: BoxFit.cover),
        // Loading indicator overlay
        if (widget.isLoading)
          Container(
            color: Colors.white.withOpacity(0.8),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.gray100, AppColor.gray200.withOpacity(0.5)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssetsManager.imgPlaceholder,
            fit: BoxFit.cover,
            color: AppColor.gray400.withOpacity(0.6),
            colorBlendMode: BlendMode.overlay,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.image_outlined,
                size: widget.isDesktop ? 32 : 24,
                color: AppColor.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveOverlay() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.center,
            colors: [
              Colors.transparent,
              AppColor.primaryColor.withOpacity(0.0),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.zoom_in_rounded,
            color: Colors.white,
            size: 32,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(int crossAxisCount, double spacing, double ratio) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: ratio,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildShimmerItem(index);
      },
    );
  }

  Widget _buildShimmerItem(int index) {
    final borderRadius = widget.isDesktop
        ? 24.0
        : widget.isTablet
        ? 20.0
        : 16.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColor.gray900.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 1200 + (index * 100)),
          child: _ShimmerEffect(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.gray200,
                    AppColor.gray100,
                    AppColor.gray200,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Shimmer Effect Widget
class _ShimmerEffect extends StatefulWidget {
  final Widget child;

  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.gray200,
                Colors.white.withOpacity(0.8),
                AppColor.gray200,
              ],
              stops: [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value * 0.5),
            ).createShader(rect);
          },
          child: widget.child,
        );
      },
    );
  }
}
