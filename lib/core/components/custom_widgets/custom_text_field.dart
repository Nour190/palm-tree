import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:flutter/material.dart';
import '../../resourses/color_manager.dart';
import '../../resourses/style_manager.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.hintStyle,
    this.textStyle,
    this.borderRadius,
    this.contentPadding,
    this.enabled,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Color? borderColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final double? borderRadius;
  final EdgeInsets? contentPadding;
  final bool? enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {

    final defaultBorderColor = borderColor ?? Colors.grey.shade300;
    final focusColor = AppColor.black;

    return Container(
      margin: EdgeInsets.only(bottom: 24.sH), // Added consistent spacing between fields
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        enabled: enabled ?? true,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: textStyle ??
            TextStyleHelper.instance.title16BoldInter,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: hintStyle ??
              TextStyleHelper.instance.title16BoldInter,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: false,
          contentPadding: contentPadding ?? EdgeInsets.symmetric(
            vertical: 16.sH,
            horizontal: 0.sW,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: defaultBorderColor,
              width: 1.sW,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: defaultBorderColor,
              width: 1.sW,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: focusColor,
              width: 2.sW,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColor.redCustom,
              width: 1.sW,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColor.redCustom,
              width: 2.sW,
            ),
          ),
        ),
      ),
    );
  }
}
