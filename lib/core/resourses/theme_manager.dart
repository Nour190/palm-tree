import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';
import 'color_manager.dart';

class ThemeManager {
  static ThemeData get light => AppTheme.light;
  static ThemeData get dark => AppTheme.dark;
}

class AppTheme {
  static final TextStyleHelper _textStyle = TextStyleHelper.instance;

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.white,
    textTheme: TextTheme(
      displayLarge: _textStyle.display48BoldInter,
      displayMedium: _textStyle.display40BoldInter,
      displaySmall: _textStyle.headline32MediumInter,
      headlineLarge: _textStyle.headline24BoldInter,
      headlineMedium: _textStyle.headline24MediumInter,
      headlineSmall: _textStyle.title20RegularRoboto,
      titleLarge: _textStyle.title16BoldInter,
      titleMedium: _textStyle.title16MediumInter,
      titleSmall: _textStyle.title16RegularInter,
      bodyLarge: _textStyle.title16Inter,
      bodyMedium: _textStyle.body12LightInter,
      bodySmall: _textStyle.bodyTextInter,
      labelLarge: _textStyle.title16LightInter,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColor.primarySwatch,
    ).copyWith(surface: AppColor.white, brightness: Brightness.light),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColor.black,
    primaryColor: AppColor.primaryColor,
    textTheme: TextTheme(
      displayLarge: _textStyle.display48BoldInter.copyWith(
        color: AppColor.white,
      ),
      displayMedium: _textStyle.display40BoldInter.copyWith(
        color: AppColor.white,
      ),
      displaySmall: _textStyle.headline32MediumInter.copyWith(
        color: AppColor.white,
      ),
      headlineLarge: _textStyle.headline24BoldInter.copyWith(
        color: AppColor.white,
      ),
      headlineMedium: _textStyle.headline24MediumInter.copyWith(
        color: AppColor.white,
      ),
      headlineSmall: _textStyle.title20RegularRoboto.copyWith(
        color: AppColor.white,
      ),
      titleLarge: _textStyle.title16BoldInter.copyWith(color: AppColor.white),
      titleMedium: _textStyle.title16MediumInter.copyWith(
        color: AppColor.white,
      ),
      titleSmall: _textStyle.title16RegularInter.copyWith(
        color: AppColor.gray400,
      ),
      bodyLarge: _textStyle.title16Inter.copyWith(color: AppColor.white),
      bodyMedium: _textStyle.body12LightInter.copyWith(color: AppColor.gray400),
      bodySmall: _textStyle.bodyTextInter.copyWith(color: AppColor.gray400),
      labelLarge: _textStyle.title16LightInter.copyWith(color: AppColor.white),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColor.primarySwatch,
    ).copyWith(surface: AppColor.black, brightness: Brightness.dark),
  );
}
