import 'package:flutter/widgets.dart';

/// Fixed gap scale (use these when you don’t need dynamic logic)
const double kGapXS = 8;
const double kGapS = 12;
const double kGapM = 16;
const double kGapL = 24;
const double kGapXL = 32;
const double kGapXXL = 40;

/// Quick vertical/horizontal gaps
SizedBox vGap(double h) => SizedBox(height: h);
SizedBox hGap(double w) => SizedBox(width: w);

/// Simple responsive gap chooser.
/// Tune the defaults per component when needed.
double responsiveGap({
  required bool isMobile,
  required bool isTablet,
  required bool isDesktop,
  double mobile = kGapM,
  double tablet = kGapL,
  double desktop = kGapXL,
}) {
  if (isDesktop) return desktop;
  if (isTablet) return tablet;
  return mobile;
}

/// Symmetric horizontal padding that follows your layout grid.
EdgeInsets responsiveHPad({
  required bool isMobile,
  required bool isTablet,
  required bool isDesktop,
  double mobile = 16,
  double tablet = 24,
  double desktop = 48,
  double vertical = 0,
}) {
  final h = isDesktop
      ? desktop
      : isTablet
      ? tablet
      : mobile;
  return EdgeInsets.symmetric(horizontal: h, vertical: vertical);
}

/// Handy extensions when you want inline sugar:
///  - 16.vgap, 24.hgap, etc.
extension GapExtensions on num {
  Widget get vgap => SizedBox(height: toDouble());
  Widget get hgap => SizedBox(width: toDouble());
}
