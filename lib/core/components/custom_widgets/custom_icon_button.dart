import 'package:baseqat/core/resourses/assets_manager.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/responsive/size_utils.dart';
import 'package:flutter/material.dart';

import './custom_image_view.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.onPressed,
    this.iconPath,
    this.backgroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.iconSize,
  });

  /// Callback function executed when button is tapped
  final VoidCallback? onPressed;

  /// Path to the icon asset (SVG, PNG, etc.)
  final String? iconPath;

  /// Background color of the button
  final Color? backgroundColor;

  /// Width of the button
  final double? width;

  /// Height of the button
  final double? height;

  /// Border radius of the button
  final double? borderRadius;

  /// Internal padding around the icon
  final EdgeInsetsGeometry? padding;

  /// Size of the icon
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 64.h,
      height: height ?? 64.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColor.black,
        borderRadius: BorderRadius.circular(borderRadius ?? 32.h),
      ),
      child: Material(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? 32.h),
          child: Padding(
            padding: padding ?? EdgeInsets.all(8.h),
            child: Center(
              child: CustomImageView(
                imagePath: iconPath ?? AppAssetsManager.imgArrowIcon,
                width: iconSize ?? 48.h,
                height: iconSize ?? 48.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
