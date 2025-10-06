import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

    final blob = html.Blob([pngBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final nav = html.window.navigator;
    final file = html.File([pngBytes], 'qr_code.png', {'type': 'image/png'});
    final canShare = jsCanShare({'files': [file]});

    if (canShare) {
      await nav.share({
        'title': 'QR Code',
        'text': 'Scan this QR code!',
        'files': [file],
      });
    } else {
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'qr_code.png')
        ..click();
    }

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR: $e')),
      );
    }
  }
}

bool jsCanShare(Object? data) {
  try {
    final nav = html.window.navigator;
    final func = (nav as dynamic).canShare;
    if (func is Function) return func(data) == true;
    return false;
  } catch (_) {
    return false;
  }
}
