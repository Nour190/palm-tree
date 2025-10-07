import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:baseqat/core/components/alerts/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

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

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr_code.png');
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'qr.share_qr_text'.tr(),
    );
  } catch (e) {
    if (context.mounted) {
      context.showErrorSnackBar('qr.share_error'.tr());
    }
  }
}
