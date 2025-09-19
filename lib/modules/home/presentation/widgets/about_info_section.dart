import 'package:baseqat/modules/home/presentation/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import 'common/custom_image_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

class AboutInfo extends StatefulWidget {
  final InfoModel info;
  final DeviceType? deviceTypeOverride;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const AboutInfo({
    super.key,
    required this.info,
    this.deviceTypeOverride,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<AboutInfo> createState() => _AboutInfoState();
}

class _AboutInfoState extends State<AboutInfo> with TickerProviderStateMixin {
  DeviceType get _deviceType =>
      widget.deviceTypeOverride ?? Responsive.deviceTypeOf(context);

  bool get isMobile =>
      _deviceType == DeviceType.mobile || _deviceType == DeviceType.tablet;
  bool get isDesktop => _deviceType == DeviceType.desktop;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColor.gray50.withOpacity(0.3)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20.sW : 40.sW,
            vertical: isMobile ? 24.sH : 40.sH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'About Us',
                subtitle: 'Discover our story and values',
                text: widget.info.about ?? 'No information available',
                image: widget.info.aboutImages.isNotEmpty
                    ? widget.info.aboutImages.first
                    : null,
                icon: Icons.info_outline_rounded,
                imageOnRight: true,
              ),

              SizedBox(height: isMobile ? 40.sH : 60.sH),

              _buildSection(
                title: 'Our Vision',
                subtitle: 'Where we see ourselves heading',
                text: widget.info.vision ?? 'No vision statement available',
                image: widget.info.visionImages.isNotEmpty
                    ? widget.info.visionImages.first
                    : null,
                icon: Icons.visibility_outlined,
                imageOnRight: false,
              ),

              SizedBox(height: isMobile ? 40.sH : 60.sH),

              _buildSection(
                title: 'Our Mission',
                subtitle: 'What drives us every day',
                text: widget.info.mission ?? 'No mission statement available',
                image: widget.info.missionImages.isNotEmpty
                    ? widget.info.missionImages.first
                    : null,
                icon: Icons.rocket_launch_outlined,
                imageOnRight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required String text,
    required String? image,
    required IconData icon,
    required bool imageOnRight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(title: title, padding: EdgeInsets.zero),
        SizedBox(height: 8.sH),
        Text(
          subtitle,
          style: TextStyleHelper.instance.title16Inter.copyWith(
            color: AppColor.gray600,
            fontSize: isMobile ? 14.sSp : 16.sSp,
            height: 1.4,
          ),
        ),
        SizedBox(height: isMobile ? 20.sH : 30.sH),

        if (isMobile)
          _buildMobileLayout(text, image, icon, imageOnRight)
        else
          _buildDesktopLayout(text, image, icon, imageOnRight),
      ],
    );
  }

  Widget _buildMobileLayout(
    String text,
    String? image,
    IconData icon,
    bool imageOnRight,
  ) {
    return Column(
      children: [
        if (imageOnRight)
          _buildTextCard(text, icon)
        else
          _buildImageCard(image),
        SizedBox(height: 20.sH),
        if (imageOnRight)
          _buildImageCard(image)
        else
          _buildTextCard(text, icon),
      ],
    );
  }

  Widget _buildDesktopLayout(
    String text,
    String? image,
    IconData icon,
    bool imageOnRight,
  ) {
    final textWidget = Expanded(child: _buildTextCard(text, icon));
    final imageWidget = Expanded(child: _buildImageCard(image));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageOnRight) textWidget else imageWidget,
        SizedBox(width: 40.sW),
        if (imageOnRight) imageWidget else textWidget,
      ],
    );
  }

  Widget _buildTextCard(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20.sW : 28.sW),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16.r : 20.r),
        border: Border.all(color: AppColor.gray200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.isLoading
          ? _buildLoadingText()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10.sW : 12.sW),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(
                          isMobile ? 12.r : 14.r,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: isMobile ? 20.sW : 24.sW,
                      ),
                    ),
                    SizedBox(width: 12.sW),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16.sH : 20.sH),
                Text(
                  text,
                  style: TextStyleHelper.instance.title16Inter.copyWith(
                    color: AppColor.gray700,
                    fontSize: isMobile ? 14.sSp : 16.sSp,
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageCard(String? imageUrl) {
    final size = Size(isMobile ? 300.sW : 400.sW, isMobile ? 200.sH : 280.sH);

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 16.r : 20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16.r : 20.r),
        child: widget.isLoading
            ? _buildLoadingImage()
            : (imageUrl == null || imageUrl.isEmpty)
            ? _buildPlaceholder()
            : CustomImageView(imagePath: imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildLoadingText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _shimmerBox(width: 44, height: 44, radius: 12),
            SizedBox(width: 12.sW),
            Expanded(child: _shimmerBox(width: double.infinity, height: 3)),
          ],
        ),
        SizedBox(height: 20.sH),
        _shimmerBox(width: double.infinity, height: 16),
        SizedBox(height: 8.sH),
        _shimmerBox(width: double.infinity, height: 16),
        SizedBox(height: 8.sH),
        _shimmerBox(width: 200.sW, height: 16),
      ],
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: AppColor.gray100,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColor.gray50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12.sW : 16.sW),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.image_outlined,
              size: isMobile ? 32.sW : 40.sW,
              color: AppColor.gray400,
            ),
          ),
          SizedBox(height: 12.sH),
          Text(
            'Image coming soon',
            style: TextStyleHelper.instance.title14MediumInter.copyWith(
              color: AppColor.gray500,
              fontSize: isMobile ? 12.sSp : 14.sSp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.gray200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
