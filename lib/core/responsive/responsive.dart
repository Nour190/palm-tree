import 'dart:math';

import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static double mobileMaxWidth = 400;
  static double tabletMaxWidth = 800;

  // last known values from init
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late DeviceType deviceType;
  static late Orientation orientation;
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final w = MediaQuery.of(context).size.width;

    if (w <= 600) {
      // mobile: use base
      return baseSize;
    } else if (w <= 1024) {
      // tablet: small increase
      return (baseSize * 1.05).roundToDouble();
    } else {
      // desktop: scale with width but clamp
      final double scale = (w / 1200).clamp(1.0, 1.25); // never more than 1.25x
      final double size = baseSize * scale;
      return max(14.0, min(size, baseSize * 1.25));
    }
  }
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    deviceType = _getDeviceTypeFromWidth(screenWidth);
  }

  static DeviceType _getDeviceTypeFromWidth(double width) {
    if (width >= tabletMaxWidth) return DeviceType.desktop;
    if (width >= mobileMaxWidth) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static DeviceType deviceTypeOf(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return _getDeviceTypeFromWidth(w);
  }

  static bool isMobile(BuildContext context) => deviceTypeOf(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => deviceTypeOf(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => deviceTypeOf(context) == DeviceType.desktop;

  static double width() => screenWidth;
  static double height() => screenHeight;
  static Orientation getOrientation() => orientation;

  static void setBreakpoints({double? mobileMax, double? tabletMax}) {
    if (mobileMax != null) mobileMaxWidth = mobileMax;
    if (tabletMax != null) tabletMaxWidth = tabletMax;
  }
}
