//  import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class ScreenUtilResponsive {
//   // Device type detection based on screen width
//   static bool get isMobile => 1.sw < 768;
//   static bool get isTablet => 1.sw >= 768 && 1.sw < 1024;
//   static bool get isDesktop => 1.sw >= 1024;
//
//   // More specific mobile breakpoints
//   static bool get isMobileSmall => 1.sw < 360;
//   static bool get isMobileLarge => 1.sw >= 360 && 1.sw < 768;
//
//   // Responsive values based on device type
//   static double get responsivePadding {
//     if (isMobile) return 16.w;
//     if (isTablet) return 24.w;
//     return 32.w;
//   }
//
//   static double get responsiveMargin {
//     if (isMobile) return 12.w;
//     if (isTablet) return 16.w;
//     return 20.w;
//   }
//
//   static double get responsiveBorderRadius {
//     if (isMobile) return 8.r;
//     if (isTablet) return 12.r;
//     return 16.r;
//   }
//
//   static double get responsiveIconSize {
//     if (isMobile) return 20.w;
//     if (isTablet) return 24.w;
//     return 28.w;
//   }
//
//   // Form field heights
//   static double get textFieldHeight {
//     if (isMobile) return 48.h;
//     if (isTablet) return 52.h;
//     return 56.h;
//   }
//
//   // Button heights
//   static double get buttonHeight {
//     if (isMobile) return 48.h;
//     if (isTablet) return 52.h;
//     return 56.h;
//   }
//
//   // Content width constraints
//   static double get maxContentWidth {
//     if (isMobile) return 1.sw;
//     if (isTablet) return 600.w;
//     return 800.w;
//   }
//
//   // Spacing values
//   static double get smallSpacing => isMobile ? 8.h : 12.h;
//   static double get mediumSpacing => isMobile ? 16.h : 24.h;
//   static double get largeSpacing => isMobile ? 24.h : 32.h;
//   static double get extraLargeSpacing => isMobile ? 32.h : 48.h;
// }
