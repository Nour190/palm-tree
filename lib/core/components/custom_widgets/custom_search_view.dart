import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:flutter/material.dart';

import './custom_image_view.dart';

class CustomSearchView extends StatelessWidget {
  CustomSearchView({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.hintStyle,
    this.textStyle,
    this.borderRadius,
    this.contentPadding,
    this.iconSize,
    this.enabled,
  }) : super(key: key);

  /// Controller for managing the text input
  final TextEditingController? controller;

  /// Placeholder text displayed when the field is empty
  final String? hintText;

  /// Path to the prefix icon image
  final String? prefixIcon;

  /// Function to validate the input text
  final String? Function(String?)? validator;

  /// Callback function triggered when text changes
  final Function(String)? onChanged;

  /// Callback function triggered when the field is tapped
  final VoidCallback? onTap;

  /// Background color of the search field
  final Color? fillColor;

  /// Border color of the search field
  final Color? borderColor;

  /// Text style for the hint text
  final TextStyle? hintStyle;

  /// Text style for the input text
  final TextStyle? textStyle;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Internal padding of the text field
  final EdgeInsets? contentPadding;

  /// Size of the prefix icon
  final double? iconSize;

  /// Whether the field is enabled for interaction
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      enabled: enabled ?? true,
      style:
          textStyle ??
          TextStyleHelper.instance.title16LightInter.copyWith(
            color: AppColor.colorFF0000,
          ),
      decoration: InputDecoration(
        hintText: hintText ?? "What do you want to see today ?",
        hintStyle:
            hintStyle ??
            TextStyleHelper.instance.title16LightInter.copyWith(
              color: AppColor.gray400,
            ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: EdgeInsets.all(12.h),
                child: CustomImageView(
                  imagePath: prefixIcon!,
                  height: iconSize ?? 24.h,
                  width: iconSize ?? 24.h,
                ),
              )
            : null,
        filled: true,
        fillColor: fillColor ?? Color(0xFFFFFFFF),
        contentPadding:
            contentPadding ??
            EdgeInsets.only(top: 16.h, right: 12.h, bottom: 16.h, left: 40.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 24.h),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFB6B6B6),
            width: 1.h,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 24.h),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFB6B6B6),
            width: 1.h,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 24.h),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFB6B6B6),
            width: 1.h,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 24.h),
          borderSide: BorderSide(color: AppColor.redCustom, width: 1.h),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 24.h),
          borderSide: BorderSide(color: AppColor.redCustom, width: 1.h),
        ),
      ),
    );
  }
}
