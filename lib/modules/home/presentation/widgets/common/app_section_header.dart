import 'package:baseqat/core/responsive/responsive.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double? maxTextWidthFraction;
  final bool emphasize;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.maxTextWidthFraction,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.deviceTypeOf(context);
    final bool isMobile = deviceType == DeviceType.mobile;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isDesktop = deviceType == DeviceType.desktop;

    final screenWidth = MediaQuery.of(context).size.width;
    final styles = TextStyleHelper.instance;

    // Use full width by default, or use provided fraction
    final double safeFraction = (maxTextWidthFraction ?? 1.0).clamp(0.0, 1.0);
    final maxWidth = screenWidth * safeFraction;

    // Enhanced title styles with better responsive scaling
    final TextStyle titleStyle;
    if (emphasize) {
      if (isDesktop) {
        titleStyle = styles.display48BoldInter.copyWith(
          color: AppColor.gray900,
          height: 1.15,
          letterSpacing: -0.02,
        );
      } else if (isTablet) {
        titleStyle = styles.headline24BoldInter.copyWith(
          color: AppColor.gray900,
          height: 1.2,
          letterSpacing: -0.01,
        );
      } else {
        // Enhanced mobile title with better scaling
        final fontSize = screenWidth < 375 ? 24.0 : 28.0;
        titleStyle = styles.headline28BoldInter.copyWith(
          color: AppColor.gray900,
          height: 1.25,
          fontSize: fontSize,
          letterSpacing: -0.01,
        );
      }
    } else {
      if (isDesktop) {
        titleStyle = styles.headline32BoldInter.copyWith(
          color: AppColor.gray900,
          height: 1.22,
          letterSpacing: -0.01,
        );
      } else if (isTablet) {
        titleStyle = styles.headline28BoldInter.copyWith(
          color: AppColor.gray900,
          height: 1.24,
          letterSpacing: -0.01,
        );
      } else {
        final fontSize = screenWidth < 375 ? 22.0 : 24.0;
        titleStyle = styles.headline28BoldInter.copyWith(
          color: AppColor.gray900,
          height: 1.28,
          fontSize: fontSize,
        );
      }
    }

    // Enhanced subtitle styles with better line height and spacing
    final TextStyle subtitleStyle;
    if (isDesktop) {
      subtitleStyle = styles.title16LightInter.copyWith(
        color: AppColor.gray700,
        height: 1.6,
        letterSpacing: 0.01,
      );
    } else if (isTablet) {
      subtitleStyle = styles.body14LightInter.copyWith(
        color: AppColor.gray700,
        height: 1.55,
      //  fontSize: 17.0,
      );
    } else {
      final fontSize = screenWidth < 375 ? 15.0 : 16.0;
      subtitleStyle = styles.body14LightInter.copyWith(
        color: AppColor.gray700,
        height: 1.5,
    //    fontSize: fontSize,
      );
    }

    // Responsive spacing
    final double titleSubtitleSpacing;
    if (isDesktop) {
      titleSubtitleSpacing = 24.sH;
    } else if (isTablet) {
      titleSubtitleSpacing = 20.sH;
    } else {
      titleSubtitleSpacing = 16.sH;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(title, style: titleStyle),

        // Subtitle with full width and 5 max lines
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          SizedBox(height: titleSubtitleSpacing),
          SizedBox(
            width: maxWidth,
            child: Text(
              subtitle!,
              style: subtitleStyle,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
