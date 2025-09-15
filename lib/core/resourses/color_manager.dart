import 'package:flutter/material.dart';

class AppColor {
  // Core Colors
  static const Color background = Color(0xFFCACACA);
  static const Color primaryColor = Color(0xFFC28A30);
  static const Color gray = Color(0xFF6C6C6C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color blackGrey = Color(0xFF272727);
  static const Color blueGrey = Color(0xFF607D8B);
  static const Color backgroundBlack = Color(0xFF252525);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF0F0F0);
  static const Color transparent = Colors.transparent;

  // Basic Material Colors
  static const Color red = Colors.red;
  static const Color pink = Color(0xFFE91E63);
  static const Color purple = Color(0xFF9C27B0);
  static const Color deepPurple = Color(0xFF673AB7);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color blue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFF03A9F4);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color teal = Color(0xFF009688);
  static const Color green = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color lime = Color(0xFFCDDC39);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color amber = Color(0xFFFFC107);
  static const Color orange = Color(0xFFFF9800);
  static const Color deepOrange = Color(0xFFFF5722);
  static const Color brown = Color(0xFF795548);

  // Custom Swatch for primary
  static const MaterialColor primarySwatch =
      MaterialColor(0xFFC28A30, <int, Color>{
        50: Color(0xFFE1C598),
        100: Color(0xFFDAB983),
        200: Color(0xFFD4AD6E),
        300: Color(0xFFCEA159),
        400: Color(0xFFC89645),
        500: Color(0xFFC28A30),
        600: Color(0xFFAF7C2B),
        700: Color(0xFF9B6E26),
        800: Color(0xFF886122),
        900: Color(0xFF74531D),
      });

  // Grays & Utility
  static const Color gray900 = Color(0xFF12130F);
  static const Color gray400 = Color(0xFFB6B6B6);
  static const Color gray700 = Color(0xFF4A4A4A);

  static const Color blueGray100 = Color(0xFFD9D9D9);
  static const Color blueGray100Alt = Color(0xFFD7D7D7);

  // Additional Named Colors
  static const Color whiteCustom = Colors.white;
  static const Color greyCustom = Colors.grey;
  static const Color redCustom = Colors.red;
  static const Color colorFF0000 = Color(0xFF000000);

  // Shades
  static Color get grey200 => Colors.grey.shade200;
  static Color get grey100 => Colors.grey.shade100;
}
