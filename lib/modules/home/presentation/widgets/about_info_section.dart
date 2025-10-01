import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:baseqat/modules/home/data/models/InfoModel.dart';
import '../../../../core/resourses/assets_manager.dart';
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

class _AboutInfoState extends State<AboutInfo> {
  DeviceType get _deviceType =>
      widget.deviceTypeOverride ?? Responsive.deviceTypeOf(context);

  bool get isMobile => _deviceType == DeviceType.mobile;
  bool get isTablet => _deviceType == DeviceType.tablet;
  bool get isDesktop => _deviceType == DeviceType.desktop;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isDesktop
        ? 48.sW
        : isTablet
        ? 32.sW
        : 18.sW;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 32.sH : 48.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSection(),

          SizedBox(height: isMobile ? 32.sH : 48.sH),

          _buildVisionSection(),

          SizedBox(height: isMobile ? 32.sH : 48.sH),

          _buildMissionSection(),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final aboutImages =
      widget.info.aboutImages+[AppAssetsManager.imgRectangle21];
      //AppAssetsManager.imgRectangle21

    final aboutText = widget.info.about ??
        'The King Abdulaziz Center for World Culture (Ithra), meaning "enrichment" in Arabic, was built as part of Saudi Aramco\'s vision to be an ambitious initiative for the public. Ithra is the Kingdom\'s leading cultural and creative destination for talent development and cross-cultural experiences. Since its opening in 2018, each attraction by Ithra serves as a window to global experiences, celebrating human potential and empowering creativity. The pillars include culture, creativity, community, art, and knowledge. With the visionary platforms and key pillars, Ithra continuously offers inspiring workshops, performances, and events.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About title
        Text(
          'About',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isDesktop ? 24.sSp : isTablet ? 22.sSp : 20.sSp,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
        ),

        SizedBox(height: 24.sH),

        // About content - responsive layout
        if (isMobile)
          _buildMobileAboutContent(aboutImages, aboutText)
        else
          _buildDesktopTabletAboutContent(aboutImages, aboutText),
      ],
    );
  }

  Widget _buildMobileAboutContent(List<String> images, String text) {
    return Column(
      children: [
        // First image (people on couches)
        if (images.isNotEmpty)
          _buildRoundedImage(images[0], height: 200.sH),

        SizedBox(height: 12.sH),

        // Second image (architectural curves)
        if (images.length > 1)
          _buildRoundedImage(images[1], height: 200.sH),

        SizedBox(height: 20.sH),

        // About text
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sSp,
            fontWeight: FontWeight.w400,
            color: AppColor.gray700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTabletAboutContent(List<String> images, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - two images stacked
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Expanded(
                flex: 3,
                child: _buildRoundedImage(
                  images[0],
                  height: isTablet ? 220.sH : 240.sH,
                ),
              ),

            SizedBox(width: 12.sW),

            if (images.length > 1)
              Expanded(
                flex: 2,
                child: _buildRoundedImage(
                  images[1],
                  height: isTablet ? 180.sH : 220.sH,
                ),
              ),
          ],
        ),

        SizedBox(height: 24.sH),

        // Right side - text
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isTablet ? 15.sSp : 16.sSp,
            fontWeight: FontWeight.w400,
            color: AppColor.gray700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildVisionSection() {
    final visionImages = widget.info.visionImages;
    final visionText = widget.info.vision ??
        'At Ithra, we envision a future in which Saudi Arabia is a beacon for knowledge and creativity.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          _buildMobileVisionContent(visionImages, visionText)
        else
          _buildDesktopTabletVisionContent(visionImages, visionText),
      ],
    );
  }

  Widget _buildMobileVisionContent(List<String> images, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vision image
        if (images.isNotEmpty)
          _buildRoundedImage(images[0], height: 250.sH),

        SizedBox(height: 20.sH),

        // Vision title
        Text(
          'Vision',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20.sSp,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
        ),

        SizedBox(height: 12.sH),

        // Vision text
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sSp,
            fontWeight: FontWeight.w400,
            color: AppColor.gray700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTabletVisionContent(List<String> images, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - image
        Expanded(
          flex: 2,
          child: images.isNotEmpty
              ? _buildRoundedImage(
            images[0],
            height: isTablet ? 280.sH : 320.sH,
          )
              : _buildPlaceholderImage(height: isTablet ? 280.sH : 320.sH),
        ),

        SizedBox(width: 32.sW),

        // Right side - title and text
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vision',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 28.sSp : 32.sSp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),

              SizedBox(height: 16.sH),

              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 15.sSp : 16.sSp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.gray700,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSection() {
    final missionImages = widget.info.missionImages;
    final missionText = widget.info.mission ??
        'Ithra aims to make a tangible and positive impact on human development by inspiring a passion for knowledge, creativity and cross-cultural engagement for the future of the Kingdom.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          _buildMobileMissionContent(missionImages, missionText)
        else
          _buildDesktopTabletMissionContent(missionImages, missionText),
      ],
    );
  }

  Widget _buildMobileMissionContent(List<String> images, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Mission image
        if (images.isNotEmpty)
          _buildRoundedImage(images[0], height: 250.sH),
        SizedBox(height: 12.sH),
        Text(
          'Mission',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20.sSp,
            fontWeight: FontWeight.w700,
            color: AppColor.black,
          ),
        ),
        SizedBox(height: 20.sH),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sSp,
            fontWeight: FontWeight.w400,
            color: AppColor.gray700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTabletMissionContent(List<String> images, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - title and text
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mission',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 28.sSp : 32.sSp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),

              SizedBox(height: 16.sH),

              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 15.sSp : 16.sSp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.gray700,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 32.sW),

        // Right side - image
        Expanded(
          flex: 2,
          child: images.isNotEmpty
              ? _buildRoundedImage(
            images[0],
            height: isTablet ? 280.sH : 320.sH,
          )
              : _buildPlaceholderImage(height: isTablet ? 280.sH : 320.sH),
        ),
      ],
    );
  }

  Widget _buildRoundedImage(String imageUrl, {required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.sR),
        color: AppColor.gray100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.sR),
        child: widget.isLoading
            ? _buildLoadingImage()
            : CustomImageView(
          imagePath: imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.gray100,
        borderRadius: BorderRadius.circular(16.sR),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48.sW,
          color: AppColor.gray400,
        ),
      ),
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
}
