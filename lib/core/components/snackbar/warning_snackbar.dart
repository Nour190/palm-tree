import 'package:flutter/material.dart';

class WarningSnackBar {
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
            Icon(Icons.warning_amber, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? Duration(seconds: 3),
        action: action,
        width: width,
        margin: margin ?? EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
