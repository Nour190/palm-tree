import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  /// The text to display on the button
  final String text;

  /// Callback function triggered when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color of the button text
  final Color? textColor;

  /// Font size of the button text
  final double? fontSize;

  /// Font weight of the button text
  final FontWeight? fontWeight;

  /// Border radius of the button corners
  final double? borderRadius;

  /// Internal padding of the button content
  final EdgeInsetsGeometry? padding;

  /// Width of the button
  final double? width;

  /// Height of the button
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 40.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColor.whiteCustom,
          foregroundColor: textColor ?? Color(0xFF12130F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
          ),
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 10.h, horizontal: 30.h),
        ),
        child: Text(
          text,
          style: TextStyleHelper.instance.title16BoldInter.copyWith(
            color: textColor ?? Color(0xFF12130F),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
