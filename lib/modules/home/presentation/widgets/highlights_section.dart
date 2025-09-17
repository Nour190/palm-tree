import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';
import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';

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
  });

  @override
  State<EnhancedHighlightsSection> createState() =>
      _EnhancedHighlightsSectionState();
}

class _EnhancedHighlightsSectionState extends State<EnhancedHighlightsSection>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: widget.title,
            showSeeMore:
                widget.showSeeMoreButton &&
                widget.onSeeMore != null &&
                widget.images.isNotEmpty,
            onSeeMore: widget.onSeeMore,
            seeMoreButtonText: widget.seeMoreButtonText,
          ),
          SizedBox(height: 24.h),

          if (widget.isLoading)
            HighlightsLoadingState()
          else if (widget.images.isEmpty)
            HighlightsEmptyState()
          else
            _buildCarouselSection(),
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Column(
      children: [
        _buildCarousel(),
        if (widget.images.length > 1) ...[
          SizedBox(height: 20.h),
          _buildIndicators(),
        ],
      ],
    );
  }

  Widget _buildCarousel() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.h),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8.h),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.h),
            child: CarouselSlider.builder(
              itemCount: widget.images.length,
              options: CarouselOptions(
                height: 370.h,
                viewportFraction: 1.0,
                enableInfiniteScroll: widget.images.length > 1,
                autoPlay: widget.autoPlay && widget.images.length > 1,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInOutCubic,
                scrollPhysics: widget.images.length > 1
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: widget.onHighlightTap,
                  child: Container(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        CustomImageView(
                          imagePath: widget.images[index],
                          height: 320.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Gradient overlay for better text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColor.black.withOpacity(0.7),
                                  AppColor.black.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Optional content overlay
                        Positioned(
                          bottom: 24.h,
                          left: 24.h,
                          right: 24.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Featured Highlight ${index + 1}',
                                style: TextStyleHelper
                                    .instance
                                    .headline20BoldInter
                                    .copyWith(
                                      color: AppColor.white,
                                      fontWeight: FontWeight.w700,
                                      shadows: [
                                        Shadow(
                                          color: AppColor.black.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Discover amazing content',
                                style: TextStyleHelper
                                    .instance
                                    .body14RegularInter
                                    .copyWith(
                                      color: AppColor.white.withOpacity(0.9),
                                      shadows: [
                                        Shadow(
                                          color: AppColor.black.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
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
          ),
          // Navigation buttons for larger screens
          if (widget.images.length > 1) ...[
            _buildNavigationButton(
              icon: Icons.chevron_left_rounded,
              alignment: Alignment.centerLeft,
              onTap: () {},
            ),
            _buildNavigationButton(
              icon: Icons.chevron_right_rounded,
              alignment: Alignment.centerRight,
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required Alignment alignment,
    required VoidCallback onTap,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24.h),
              child: Container(
                width: 48.h,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColor.gray700, size: 24.h),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length,
        (index) => GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _currentIndex == index ? 32.h : 8.h,
            height: 8.h,
            margin: EdgeInsets.symmetric(horizontal: 4.h),
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? AppColor.primaryColor
                  : AppColor.gray400,
              borderRadius: BorderRadius.circular(4.h),
              boxShadow: _currentIndex == index
                  ? [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2.h),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class HighlightsLoadingState extends StatefulWidget {
  const HighlightsLoadingState({super.key});

  @override
  State<HighlightsLoadingState> createState() => _HighlightsLoadingStateState();
}

class _HighlightsLoadingStateState extends State<HighlightsLoadingState>
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

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            height: 320.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.gray100,
              borderRadius: BorderRadius.circular(24.h),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading highlights...',
                        style: TextStyleHelper.instance.body14RegularInter
                            .copyWith(color: AppColor.gray600),
                      ),
                    ],
                  ),
                ),
                // Shimmer effect
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.h),
                    child: Transform.translate(
                      offset: Offset(_shimmerAnimation.value * 200.h, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColor.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HighlightsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Container(
        height: 320.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.gray50, AppColor.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24.h),
          border: Border.all(color: AppColor.gray200, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.05),
              blurRadius: 12,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.h),
                decoration: BoxDecoration(
                  color: AppColor.gray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 48.h,
                  color: AppColor.gray400,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'No highlights available',
                style: TextStyleHelper.instance.title18MediumInter.copyWith(
                  color: AppColor.gray700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Check back later for featured content',
                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                  color: AppColor.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
