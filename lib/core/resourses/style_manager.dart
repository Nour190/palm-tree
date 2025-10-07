import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }


  TextStyle get display56BoldInter =>
      TextStyle(
        fontSize: 56.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.whiteCustom,
      );

  TextStyle get display48BoldInter =>
      TextStyle(
        fontSize: 48.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.whiteCustom,
      );
  TextStyle get display48BlackBoldInter =>
      TextStyle(
        fontSize: 48.sSp,
        fontWeight: FontWeight.w900,
        fontFamily: 'Inter',
        color: AppColor.black,
      );
  TextStyle get display40BoldInter =>
      TextStyle(
        fontSize: 40.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.whiteCustom,
      );

  // Headline Styles
  TextStyle get headline32MediumInter =>
      TextStyle(
        fontSize: 32.sSp,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: AppColor.whiteCustom,
      );


  TextStyle get headline32BoldInter =>
      TextStyle(
        fontSize: 32.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );
  TextStyle get headline28BoldInter =>
      TextStyle(
        fontSize: 28.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );

  TextStyle get headline28MediumInter =>
      TextStyle(
        fontSize: 28.sSp,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      );
  TextStyle get headline24BoldInter =>
      TextStyle(
        fontSize: 24.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );

  TextStyle get headline24MediumInter =>
      TextStyle(
        fontSize: 24.sSp,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      );

  TextStyle get title20RegularRoboto =>
      TextStyle(
        fontSize: 20.sSp,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title16RegularInter =>
      TextStyle(
        fontSize: 16.sSp,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColor.gray400,
      );
  TextStyle get title16BlackRegularInter =>
      TextStyle(
        fontSize: 16.sSp,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColor.black,
      );

  TextStyle get title16BoldInter =>
      TextStyle(
        fontSize: 16.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );

  TextStyle get title16LightInter =>
      TextStyle(
        fontSize: 16.sSp,
        fontWeight: FontWeight.w300,
        fontFamily: 'Inter',
      );

  TextStyle get title16Inter => TextStyle(fontSize: 16.sp, fontFamily: 'Inter');

  TextStyle get title16MediumInter =>
      TextStyle(
        fontSize: 16.sSp,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );

  // Body Styles
  TextStyle get body12LightInter =>
      TextStyle(
        fontSize: 12.sSp,
        fontWeight: FontWeight.w300,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );
  TextStyle get title18LightInter =>
      TextStyle(
        fontSize: 18.sSp,
        fontWeight: FontWeight.w300,
        fontFamily: 'Inter',
      );
  TextStyle get title18BoldInter =>
      TextStyle(
        fontSize: 18.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );
  TextStyle get body12BoldInter =>
      TextStyle(
        fontSize: 12.sSp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );

  TextStyle get title14MediumInter => TextStyle(
   // fontSize: 14.fSize,
    fontSize: 14.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );
  TextStyle get title14BoldInter => TextStyle(
    // fontSize: 14.fSize,
    fontSize: 14.sSp,
    fontWeight: FontWeight.w900,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );
  TextStyle get body14LightInter =>
      TextStyle(
        fontSize: 14.sSp,
        fontWeight: FontWeight.w300,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );
  TextStyle get title14BlackRegularInter =>
      TextStyle(
        fontSize: 14.sSp,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColor.black,
      );

  TextStyle get title18MediumInter => TextStyle(
    fontSize: 18.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );

  TextStyle get title18Inter =>
      TextStyle(
        fontSize: 18.sSp,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        color: AppColor.gray900,
      );
  TextStyle get body14RegularInter => TextStyle(
    fontSize: 14.sSp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColor.gray700,
  );
  TextStyle get body18MediumInter => TextStyle(
    fontSize: 18.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray700,
  );

  TextStyle get body14MediumInter => TextStyle(
    fontSize: 14.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray700,
  );

  TextStyle get body16MediumInter => TextStyle(
    fontSize: 16.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );

  TextStyle get body12MediumInter => TextStyle(
    fontSize: 12.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );

  TextStyle get caption12RegularInter => TextStyle(
    fontSize: 12.sSp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColor.gray600,
  );
  TextStyle get body9MediumInter => TextStyle(
    fontSize: 9.sSp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );

  TextStyle get caption9RegularInter => TextStyle(
    fontSize: 9.sSp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColor.gray600,
  );

  TextStyle get headline20BoldInter => TextStyle(
    fontSize: 20.sSp,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColor.gray900,
  );

  TextStyle get headline20MediumInter =>
      TextStyle(
        fontSize: 20.sSp,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      );

  TextStyle get bodyTextInter => TextStyle(fontFamily: 'Inter');
}
//   // ------------------------------
//   // Responsive variants using Responsive.responsiveFontSize(context, baseSize)
//   // Use these in widgets that must clamp/scale on large screens (web/desktop).
//   // ------------------------------
//
//   TextStyle display48BoldInterResponsive(BuildContext context) {
//     return display48BoldInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 48),
//     );
//   }
//
//   TextStyle display40BoldInterResponsive(BuildContext context) {
//     return display40BoldInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 40),
//     );
//   }
//
//   TextStyle headline32MediumInterResponsive(BuildContext context) {
//     return headline32MediumInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 32),
//     );
//   }
//
//   TextStyle headline32BoldInterResponsive(BuildContext context) {
//     return headline32BoldInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 32),
//     );
//   }
//
//
//
//   TextStyle headline24BoldInterResponsive(BuildContext context) {
//     return headline24BoldInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 24),
//     );
//   }
//
//   TextStyle headline24MediumInterResponsive(BuildContext context) {
//     return headline24MediumInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 24),
//     );
//   }
//
//   TextStyle title20RegularRobotoResponsive(BuildContext context) {
//     return title20RegularRoboto.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 20),
//     );
//   }
//
//   TextStyle title16RegularInterResponsive(BuildContext context) {
//     return title16RegularInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 16),
//     );
//   }
//
//   TextStyle title16BoldInterResponsive(BuildContext context) {
//     return title16BoldInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 16),
//     );
//   }
//
//   TextStyle title16LightInterResponsive(BuildContext context) {
//     return title16LightInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 16),
//     );
//   }
//
//   TextStyle title16InterResponsive(BuildContext context) {
//     return title16Inter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 16),
//     );
//   }
//
//   TextStyle title16MediumInterResponsive(BuildContext context) {
//     return title16MediumInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 16),
//     );
//   }
//
//   TextStyle body12LightInterResponsive(BuildContext context) {
//     return body12LightInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 12),
//     );
//   }
//
//   TextStyle body12BoldInterResponsive(BuildContext context) {
//     return body12BoldInter.copyWith(
//       fontSize: Responsive.responsiveFontSize(context, 12),
//     );
//   }
// }
