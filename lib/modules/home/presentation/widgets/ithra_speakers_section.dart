import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/home/presentation/widgets/common/home_image.dart';
import 'package:baseqat/core/components/custom_widgets/custom_image_view.dart';

class IthraSpeakersSection extends StatelessWidget {
  final VoidCallback? onSeeMore;
  final VoidCallback? onJoinNow;
  final String? speakerImagePath;

  const IthraSpeakersSection({
    super.key,
    this.onSeeMore,
    this.onJoinNow,
    this.speakerImagePath,
  });

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
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24.sH : 32.sH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speakers',
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
              if (onSeeMore != null)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Text(
                    'See More',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isDesktop ? 14.sSp : 13.sSp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.gray600,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 24.sH),
          
          // Speaker card
          _buildSpeakerCard(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildSpeakerCard(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.sW : 20.sW),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(16.sR),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile 
          ? _buildMobileLayout(context, deviceType)
          : _buildDesktopTabletLayout(context, deviceType),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DeviceType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio waveform section
        _buildAudioWaveformSection(context, deviceType),
        
        SizedBox(height: 20.sH),
        
        // Speaker info section
        _buildSpeakerInfoSection(context, deviceType),
      ],
    );
  }

  Widget _buildDesktopTabletLayout(BuildContext context, DeviceType deviceType) {
    return Row(
      children: [
        // Left side - Audio waveform
        Expanded(
          flex: 3,
          child: _buildAudioWaveformSection(context, deviceType),
        ),
        
        SizedBox(width: 32.sW),
        
        // Right side - Speaker info
        Expanded(
          flex: 2,
          child: _buildSpeakerInfoSection(context, deviceType),
        ),
      ],
    );
  }

  Widget _buildAudioWaveformSection(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio icon and title
        Row(
          children: [
            Container(
              width: isMobile ? 32.sW : 36.sW,
              height: isMobile ? 32.sW : 36.sW,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.sR),
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                color: Colors.white,
                size: isMobile ? 18.sW : 20.sW,
              ),
            ),
            SizedBox(width: 12.sW),
            Expanded(
              child: Text(
                'A lineup of 300+ voices\nfrom industry leaders',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 16.sSp : isTablet ? 18.sSp : 20.sSp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16.sH),
        
        // Description
        Text(
          'Hear from thought leaders, innovators, and visionaries who are shaping the future of arts and culture.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 14.sSp : 15.sSp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
            height: 1.4,
          ),
        ),
        
        SizedBox(height: 20.sH),
        
        // Audio waveform visualization
        _buildWaveformVisualization(context, deviceType),
        
        SizedBox(height: 16.sH),
        
        // Play controls
        _buildPlayControls(context, deviceType),
      ],
    );
  }

  Widget _buildWaveformVisualization(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      height: isMobile ? 60.sH : 80.sH,
      child: CustomPaint(
        painter: WaveformPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildPlayControls(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Row(
      children: [
        // Play button
        Container(
          width: isMobile ? 36.sW : 40.sW,
          height: isMobile ? 36.sW : 40.sW,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColor.black,
            size: isMobile ? 20.sW : 24.sW,
          ),
        ),
        
        SizedBox(width: 12.sW),
        
        // Progress indicator
        Expanded(
          child: Container(
            height: 4.sH,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.sR),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.3, // 30% progress
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.sR),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12.sW),
        
        // Join Now button
        if (onJoinNow != null)
          GestureDetector(
            onTap: onJoinNow,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.sW : 20.sW,
                vertical: isMobile ? 8.sH : 10.sH,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.sR),
              ),
              child: Text(
                'Join Now',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 12.sSp : 14.sSp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpeakerInfoSection(BuildContext context, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Speaker avatar
        Container(
          width: isMobile ? 80.sW : isTablet ? 100.sW : 120.sW,
          height: isMobile ? 80.sW : isTablet ? 100.sW : 120.sW,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _buildSpeakerImage(),
          ),
        ),
        
        SizedBox(height: 16.sH),
        
        // Speaker name
        Text(
          'Dr. Sarah Johnson',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 16.sSp : isTablet ? 18.sSp : 20.sSp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 4.sH),
        
        // Speaker title
        Text(
          'Cultural Innovation Expert',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 14.sSp : 15.sSp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        
        SizedBox(height: 16.sH),
        
        // Speaker badges/credentials
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 8.sW,
          runSpacing: 8.sH,
          children: [
            _buildSpeakerBadge('TEDx Speaker', deviceType),
            _buildSpeakerBadge('Author', deviceType),
            _buildSpeakerBadge('Innovator', deviceType),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeakerImage() {
    if (speakerImagePath != null && speakerImagePath!.isNotEmpty) {
      if (speakerImagePath!.toLowerCase().startsWith('http')) {
        return HomeImage(
          path: speakerImagePath!,
          fit: BoxFit.cover,
          errorChild: _buildFallbackSpeakerImage(),
        );
      } else {
        return CustomImageView(
          imagePath: speakerImagePath!,
          fit: BoxFit.cover,
        );
      }
    }
    
    return _buildFallbackSpeakerImage();
  }

  Widget _buildFallbackSpeakerImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Text(
          'SJ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32.sSp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakerBadge(String text, DeviceType deviceType) {
    final bool isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.sW : 10.sW,
        vertical: isMobile ? 4.sH : 6.sH,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.sR),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: isMobile ? 10.sSp : 12.sSp,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = 3.0;
    final barSpacing = 2.0;
    final totalBars = (size.width / (barWidth + barSpacing)).floor();
    final activeProgress = 0.3; // 30% progress
    final activeBars = (totalBars * activeProgress).floor();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + barSpacing);
      final normalizedHeight = _generateWaveformHeight(i, totalBars);
      final barHeight = size.height * normalizedHeight;
      final y = (size.height - barHeight) / 2;

      final currentPaint = i < activeBars ? activePaint : paint;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + barHeight),
        currentPaint,
      );
    }
  }

  double _generateWaveformHeight(int index, int totalBars) {
    // Generate a realistic waveform pattern
    final normalizedIndex = index / totalBars;
    final baseHeight = 0.3;
    final variation = 0.7;
    
    // Create multiple sine waves for complexity
    final wave1 = math.sin(normalizedIndex * math.pi * 4) * 0.3;
    final wave2 = math.sin(normalizedIndex * math.pi * 8) * 0.2;
    final wave3 = math.sin(normalizedIndex * math.pi * 16) * 0.1;
    
    final height = baseHeight + (wave1 + wave2 + wave3) * variation;
    return height.clamp(0.1, 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
