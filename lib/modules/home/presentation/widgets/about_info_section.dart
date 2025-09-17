import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'common/custom_image_view.dart';

class AboutInfo extends StatefulWidget {
  final InfoModel info;
  final bool isMobile, isTablet, isDesktop;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const AboutInfo({
    super.key,
    required this.info,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<AboutInfo> createState() => _AboutInfoState();
}

class _AboutInfoState extends State<AboutInfo> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers
        .map(
          (controller) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _slideAnimations = _controllers
        .map(
          (controller) =>
              Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
              ),
        )
        .toList();

    // Start animations with delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _gap => widget.isDesktop
      ? 40.0
      : widget.isTablet
      ? 32.0
      : 24.0;
  double get _hPad => widget.isMobile
      ? 20.0
      : widget.isTablet
      ? 32.0
      : 40.0;

  Size get _imgSize {
    if (widget.isDesktop) return const Size(480, 320);
    if (widget.isTablet) return const Size(380, 280);
    return const Size(320, 240);
  }

  @override
  Widget build(BuildContext context) {
    final gap = _gap;
    final imageSize = _imgSize;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColor.gray50.withOpacity(0.3)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _hPad, vertical: gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Section
            _buildAnimatedSection(
              index: 0,
              title: 'About Us',
              subtitle: 'Discover our story and values',
              child: _SectionLayout(
                isMobile: widget.isMobile,
                gap: gap,
                left: _EnhancedTextBlock(
                  title: 'About',
                  text: widget.info.about ?? 'No information available',
                  accentColor: AppColor.black,
                  gradientColors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor,
                  ],
                  icon: Icons.info_outline_rounded,
                  isLoading: widget.isLoading,
                ),
                right: _EnhancedImageCard(
                  url: widget.info.aboutImages.isNotEmpty
                      ? widget.info.aboutImages.first
                      : null,
                  size: imageSize,
                  accentColor: AppColor.black,
                  isLoading: widget.isLoading,
                ),
                imageOnRight: true,
              ),
            ),

            SizedBox(height: gap * 2),

            // Vision Section
            _buildAnimatedSection(
              index: 1,
              title: 'Our Vision',
              subtitle: 'Where we see ourselves heading',
              child: _SectionLayout(
                isMobile: widget.isMobile,
                gap: gap,
                left: _EnhancedImageCard(
                  url: widget.info.visionImages.isNotEmpty
                      ? widget.info.visionImages.first
                      : null,
                  size: imageSize,
                  accentColor: const Color(0xFF059669),
                  isLoading: widget.isLoading,
                ),
                right: _EnhancedTextBlock(
                  title: 'Vision',
                  text: widget.info.vision ?? 'No vision statement available',
                  accentColor: AppColor.black,
                  gradientColors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor,
                  ],
                  icon: Icons.visibility_outlined,
                  isLoading: widget.isLoading,
                ),
                imageOnRight: false,
              ),
            ),

            SizedBox(height: gap * 2),

            // Mission Section
            _buildAnimatedSection(
              index: 2,
              title: 'Our Mission',
              subtitle: 'What drives us every day',
              child: _SectionLayout(
                isMobile: widget.isMobile,
                gap: gap,
                left: _EnhancedTextBlock(
                  title: 'Mission',
                  text: widget.info.mission ?? 'No mission statement available',
                  accentColor: AppColor.black,
                  gradientColors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor,
                  ],
                  icon: Icons.rocket_launch_outlined,
                  isLoading: widget.isLoading,
                ),
                right: _EnhancedImageCard(
                  url: widget.info.missionImages.isNotEmpty
                      ? widget.info.missionImages.first
                      : null,
                  size: imageSize,
                  accentColor: AppColor.black,
                  isLoading: widget.isLoading,
                ),
                imageOnRight: true,
              ),
            ),

            SizedBox(height: gap),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required int index,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeaderWidget(title: title, padding: EdgeInsets.zero),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyleHelper.instance.title16Inter.copyWith(
                color: AppColor.gray600,
                height: 1.4,
              ),
            ),
            SizedBox(height: _gap),
            child,
          ],
        ),
      ),
    );
  }
}

/// Enhanced two-column (or stacked on mobile) responsive section layout.
class _SectionLayout extends StatelessWidget {
  final bool isMobile;
  final double gap;
  final Widget left;
  final Widget right;
  final bool imageOnRight;

  const _SectionLayout({
    required this.isMobile,
    required this.gap,
    required this.left,
    required this.right,
    required this.imageOnRight,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageOnRight) left else right,
          SizedBox(height: gap),
          if (imageOnRight) right else left,
        ],
      );
    }

    final widgets = imageOnRight ? [left, right] : [right, left];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: widgets[0]),
        SizedBox(width: gap * 1.5),
        Expanded(child: widgets[1]),
      ],
    );
  }
}

/// Enhanced text block with modern design and loading states.
class _EnhancedTextBlock extends StatefulWidget {
  final String title;
  final String text;
  final Color accentColor;
  final List<Color> gradientColors;
  final IconData icon;
  final bool isLoading;

  const _EnhancedTextBlock({
    required this.title,
    required this.text,
    required this.accentColor,
    required this.gradientColors,
    required this.icon,
    this.isLoading = false,
  });

  @override
  State<_EnhancedTextBlock> createState() => _EnhancedTextBlockState();
}

class _EnhancedTextBlockState extends State<_EnhancedTextBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _isHovered
                    ? widget.accentColor.withOpacity(0.02)
                    : Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withOpacity(0.3)
                  : AppColor.gray200,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(_isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 32 : 20,
                offset: Offset(0, _isHovered ? 12 : 8),
                spreadRadius: _isHovered ? 2 : 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.isLoading
              ? _buildLoadingContent()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and accent bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.gradientColors,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.title,
                      style: styles.headline24BoldInter.copyWith(
                        color: AppColor.gray900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.text,
                      style: styles.title16Inter.copyWith(
                        color: AppColor.gray700,
                        height: 1.7,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ShimmerBox(width: 48, height: 48, borderRadius: 16),
            const SizedBox(width: 16),
            Expanded(child: _ShimmerBox(width: double.infinity, height: 4)),
          ],
        ),
        const SizedBox(height: 24),
        _ShimmerBox(width: 200, height: 28),
        const SizedBox(height: 16),
        _ShimmerBox(width: double.infinity, height: 20),
        const SizedBox(height: 8),
        _ShimmerBox(width: double.infinity, height: 20),
        const SizedBox(height: 8),
        _ShimmerBox(width: 250, height: 20),
      ],
    );
  }
}

/// Enhanced image card with modern design and loading states.
class _EnhancedImageCard extends StatefulWidget {
  final String? url;
  final Size size;
  final Color accentColor;
  final bool isLoading;

  const _EnhancedImageCard({
    required this.url,
    required this.size,
    required this.accentColor,
    this.isLoading = false,
  });

  @override
  State<_EnhancedImageCard> createState() => _EnhancedImageCardState();
}

class _EnhancedImageCardState extends State<_EnhancedImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.size.width,
        height: widget.size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(_isHovered ? 0.2 : 0.1),
              blurRadius: _isHovered ? 40 : 24,
              offset: Offset(0, _isHovered ? 20 : 12),
              spreadRadius: _isHovered ? 4 : 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.isLoading)
                _buildLoadingImage()
              else if (widget.url == null || widget.url!.isEmpty)
                _EnhancedPlaceholder(accentColor: widget.accentColor)
              else
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: CustomImageView(
                    imagePath: widget.url!,
                    fit: BoxFit.cover,
                  ),
                ),

              // Gradient overlay
              if (!widget.isLoading)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        widget.accentColor.withOpacity(_isHovered ? 0.1 : 0.05),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.gray200, AppColor.gray100, AppColor.gray200],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          ),
        ),
      ),
    );
  }
}

/// Enhanced placeholder with modern design.
class _EnhancedPlaceholder extends StatelessWidget {
  final Color accentColor;

  const _EnhancedPlaceholder({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.gray50, AppColor.gray100.withOpacity(0.8)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: accentColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Image coming soon',
            style: TextStyleHelper.instance.title14MediumInter.copyWith(
              color: AppColor.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading box
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.gray200,
                Colors.white.withOpacity(0.8),
                AppColor.gray200,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_controller.value * 2 * 3.14159),
            ),
          ),
        );
      },
    );
  }
}
