import 'package:flutter/material.dart';
import 'screen_util_responsive.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ScreenUtilResponsive.isDesktop && desktop != null) {
      return desktop!;
    }
    if (ScreenUtilResponsive.isTablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
