import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../resourses/color_manager.dart';
import '../../resourses/values_manager.dart';

class ErrorDialog {
  static void show(
    BuildContext context, {
    String? message,
    String? buttonText,
    VoidCallback? onPressed,
    Color? iconColor,
    double? iconSize,
    double? borderRadius,
    TextStyle? messageStyle,
    TextStyle? buttonStyle,
    EdgeInsets? contentPadding,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? AppSize.s16),
            ),
            contentPadding: contentPadding ?? const EdgeInsets.all(AppSize.s24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSize.s32),
                  child: Icon(
                    CupertinoIcons.xmark_circle,
                    color: iconColor ?? AppColor.red,
                    size: iconSize ?? AppSize.s86,
                  ),
                ),
                if (message != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.s15,
                    ),
                    child: Text(
                      message,
                      style:
                          messageStyle ??
                          Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed?.call();
                },
                child: Text(
                  buttonText ?? "Close",
                  style:
                      buttonStyle ??
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColor.red,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
