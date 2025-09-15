import 'package:flutter/material.dart';

class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Duration? duration,
    SnackBarAction? action,
    double? width,
    EdgeInsets? margin,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? Duration(seconds: 4),
        action: action,
        width: width,
        margin: margin ?? EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
