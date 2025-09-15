import 'package:flutter/material.dart';

class LoadingDialog {
  static void show(
    BuildContext context, {
    String? message,
    Color? barrierColor,
    Color? progressColor,
    double? borderRadius,
    EdgeInsets? padding,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressColor ?? Theme.of(context).primaryColor,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
