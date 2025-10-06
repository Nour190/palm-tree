import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareQRCode(String qrData, BuildContext context) async {
  try {
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    final ui.Image qrImage = await qrPainter.toImage(400);
    final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final result = await Share.shareXFiles(
      [
        XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'qr_code.png',
        ),
      ],
      text: 'Scan this QR code!',
      subject: 'QR Code',
    );

    // Handle the result
    if (context.mounted) {
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code shared successfully!')),
        );
      } else if (result.status == ShareResultStatus.unavailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share not supported. Image will be downloaded.'),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}