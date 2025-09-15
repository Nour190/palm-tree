import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../resourses/color_manager.dart';

class SuccessDialog {
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
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            contentPadding: contentPadding ?? const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Icon(
                    CupertinoIcons.check_mark_circled,
                    color: iconColor ?? Colors.green,
                    size: iconSize ?? 86,
                  ),
                ),
                if (message != null) ...[
                  Text(
                    message,
                    style:
                        messageStyle ?? Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
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
                  buttonText ?? "OK",
                  style:
                      buttonStyle ??
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColor.primaryColor,
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
