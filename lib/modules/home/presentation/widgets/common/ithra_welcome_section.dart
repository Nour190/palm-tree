import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class IthraWelcomeSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> images;

  const IthraWelcomeSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.images,
  });

  @override
  State<IthraWelcomeSection> createState() => _IthraWelcomeSectionState();
}

class _IthraWelcomeSectionState extends State<IthraWelcomeSection> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding = isDesktop
        ? 16.sW
        : isTablet
        ? 12.sW
        : 8.sW;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text section
          SizedBox(
            width: isDesktop
                ? MediaQuery.of(context).size.width * 0.4
                : double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isDesktop
                        ? 32.sSp
                        : isTablet
                        ? 28.sSp
                        : 24.sSp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.black,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16.sH),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isDesktop
                        ? 16.sSp
                        : isTablet
                        ? 15.sSp
                        : 14.sSp,
                    fontWeight: FontWeight.w400,
                    color: AppColor.gray600,
                    height: 1.5,
                  ), maxLines:isDesktop?3:4,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 24.sH),

                // Highlights label
                Text(
                  'Highlights',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isDesktop
                        ? 18.sSp
                        : isTablet
                        ? 16.sSp
                        : 15.sSp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.sH),

          // Hero image section
          _buildHeroImageSection(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildHeroImageSection(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;

    if (widget.images.isEmpty) {
      return _buildPlaceholderImage(context, deviceType);
    }

    final double carouselHeight = isMobile
        ? 280.sH
        : isTablet
        ? 320.sH
        : 400.sH;

    return Column(
      children: [
        Container(
          height: carouselHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.sR),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.sR),
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: carouselHeight,
                viewportFraction: 1.0,
                initialPage: 0,
                enableInfiniteScroll: widget.images.length > 1,
                reverse: false,
                autoPlay: widget.images.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: widget.images.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: [
                        // Main hero image
                        Positioned.fill(
                          child: HomeImage(
                            path: imagePath,
                            fit: BoxFit.cover,
                            errorChild: _buildPlaceholderImage(context, deviceType),
                          ),
                        ),

                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColor.black.withOpacity(0.3),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),

        if (widget.images.length > 1) ...[
          SizedBox(height: 16.sH),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length.clamp(0, 5), // Show max 5 dots
                  (index) => GestureDetector(
                onTap: () {
                  _carouselController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.sW),
                  width: index == _currentIndex ? 24.sW : 8.sW,
                  height: 8.sH,
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? AppColor.black
                        : AppColor.gray400,
                    borderRadius: BorderRadius.circular(4.sR),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.gray100,
            AppColor.gray200,
          ],
        ),
        borderRadius: BorderRadius.circular(16.sR),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: isMobile ? 48.sW : 64.sW,
              color: AppColor.gray400,
            ),
            SizedBox(height: 8.sH),
            Text(
              'Welcome to the palm tree',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isMobile ? 16.sSp : 18.sSp,
                fontWeight: FontWeight.w500,
                color: AppColor.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
