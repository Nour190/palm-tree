import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';

class IthraAboutFooterSection extends StatelessWidget {
  const IthraAboutFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding = isDesktop
        ? 48.sW
        : isTablet
        ? 32.sW
        : 18.sW;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // About section
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isMobile ? 32.sH : 48.sH,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About title
                Text(
                  'About',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isDesktop 
                        ? 24.sSp 
                        : isTablet 
                        ? 22.sSp 
                        : 20.sSp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.black,
                  ),
                ),
                
                SizedBox(height: 24.sH),
                
                // About content
                if (isMobile)
                  _buildMobileAboutContent(context)
                else
                  _buildDesktopTabletAboutContent(context, deviceType),
                
                SizedBox(height: 48.sH),
                
                // Vision and Mission sections
                _buildVisionMissionSection(context, deviceType),
              ],
            ),
          ),
          
          // Footer
          _buildFooter(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildMobileAboutContent(BuildContext context) {
    return Column(
      children: [
        // About images
        SizedBox(
          height: 200.sH,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.sR),
                    color: AppColor.gray200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.sR),
                    child: Container(
                      color: AppColor.gray400,
                      child: Center(
                        child: Icon(
                          Icons.people_outline,
                          size: 40.sW,
                          color: AppColor.gray500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.sW),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.sR),
                    color: AppColor.gray200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.sR),
                    child: Container(
                      color: AppColor.gray400,
                      child: Center(
                        child: Icon(
                          Icons.architecture_outlined,
                          size: 40.sW,
                          color: AppColor.gray600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20.sH),
        
        // About text
        Text(
          'The King Abdulaziz Center for World Culture (Ithra) is a major cultural destination in Saudi Arabia. We are dedicated to fostering creativity, learning, and cross-cultural dialogue through our diverse programs and exhibitions.',
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

  Widget _buildDesktopTabletAboutContent(BuildContext context, DeviceType deviceType) {
    final bool isTablet = deviceType == DeviceType.tablet;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - images
        Expanded(
          flex: 2,
          child: SizedBox(
            height: isTablet ? 250.sH : 300.sH,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.sR),
                      color: AppColor.gray200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.sR),
                      child: Container(
                        color: AppColor.gray400,
                        child: Center(
                          child: Icon(
                            Icons.people_outline,
                            size: isTablet ? 48.sW : 56.sW,
                            color: AppColor.gray500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.sW),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.sR),
                      color: AppColor.gray200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.sR),
                      child: Container(
                        color: AppColor.gray400,
                        child: Center(
                          child: Icon(
                            Icons.architecture_outlined,
                            size: isTablet ? 48.sW : 56.sW,
                            color: AppColor.gray600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(width: 32.sW),
        
        // Right side - text
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The King Abdulaziz Center for World Culture (Ithra) is a major cultural destination in Saudi Arabia. We are dedicated to fostering creativity, learning, and cross-cultural dialogue through our diverse programs and exhibitions.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 15.sSp : 16.sSp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.gray700,
                  height: 1.6,
                ),
              ),
              
              SizedBox(height: 20.sH),
              
              Text(
                'Our mission is to be a bridge between cultures, inspiring innovation and creativity while preserving our rich heritage for future generations.',
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

  Widget _buildVisionMissionSection(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    return Column(
      children: [
        // Vision section
        Container(
          padding: EdgeInsets.all(isMobile ? 20.sW : 24.sW),
          decoration: BoxDecoration(
            color: AppColor.gray50,
            borderRadius: BorderRadius.circular(16.sR),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vision',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 18.sSp : isTablet ? 20.sSp : 22.sSp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
              
              SizedBox(height: 12.sH),
              
              Text(
                'To be a leading cultural institution that inspires creativity, fosters learning, and builds bridges between cultures worldwide.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 14.sSp : 15.sSp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.gray700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16.sH),
        
        // Mission section
        Container(
          padding: EdgeInsets.all(isMobile ? 20.sW : 24.sW),
          decoration: BoxDecoration(
            color: AppColor.gray50,
            borderRadius: BorderRadius.circular(16.sR),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mission',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 18.sSp : isTablet ? 20.sSp : 22.sSp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                ),
              ),
              
              SizedBox(height: 12.sH),
              
              Text(
                'We aim to enrich the cultural landscape through innovative programs, world-class exhibitions, and meaningful community engagement that celebrates both local heritage and global perspectives.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 14.sSp : 15.sSp,
                  fontWeight: FontWeight.w400,
                  color: AppColor.gray700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final double horizontalPadding = isDesktop
        ? 48.sW
        : isTablet
        ? 32.sW
        : 18.sW;

    return Container(
      color: AppColor.black,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 32.sH : 48.sH,
      ),
      child: Column(
        children: [
          // Footer content
          if (isMobile)
            _buildMobileFooterContent(context)
          else
            _buildDesktopTabletFooterContent(context, deviceType),
          
          SizedBox(height: 32.sH),
          
          // Bottom section with logo
          Column(
            children: [
              // Large ithra logo
              Text(
                'ithra',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 48.sSp : isTablet ? 64.sSp : 80.sSp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              
              SizedBox(height: 16.sH),
              
              // Copyright
              Text(
                '© 2025 King Abdulaziz Center for World Culture. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 12.sSp : 14.sSp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFooterContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact info
        _buildFooterSection(
          'Contact',
          [
            'info@ithra.com',
            '+966 13 123 4567',
            'King Abdulaziz Center',
            'Dhahran, Saudi Arabia',
          ],
          DeviceType.mobile,
        ),
        
        SizedBox(height: 24.sH),
        
        // Social media
        _buildSocialMediaSection(DeviceType.mobile),
      ],
    );
  }

  Widget _buildDesktopTabletFooterContent(BuildContext context, DeviceType deviceType) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact info
        Expanded(
          child: _buildFooterSection(
            'Contact',
            [
              'info@ithra.com',
              '+966 13 123 4567',
              'King Abdulaziz Center',
              'Dhahran, Saudi Arabia',
            ],
            deviceType,
          ),
        ),
        
        SizedBox(width: 48.sW),
        
        // Follow us
        Expanded(
          child: _buildSocialMediaSection(deviceType),
        ),
      ],
    );
  }

  Widget _buildFooterSection(String title, List<String> items, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 16.sSp : 18.sSp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 16.sH),
        
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 8.sH),
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 14.sSp : 15.sSp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSocialMediaSection(DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow us',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 16.sSp : 18.sSp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 16.sH),
        
        Row(
          children: [
            _buildSocialIcon(Icons.facebook, deviceType),
            SizedBox(width: 12.sW),
            _buildSocialIcon(Icons.camera_alt, deviceType), // Instagram
            SizedBox(width: 12.sW),
            _buildSocialIcon(Icons.alternate_email, deviceType), // Twitter/X
            SizedBox(width: 12.sW),
            _buildSocialIcon(Icons.video_library, deviceType), // YouTube
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      width: isMobile ? 40.sW : 44.sW,
      height: isMobile ? 40.sW : 44.sW,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.sR),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: isMobile ? 20.sW : 22.sW,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}
