import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:baseqat/core/components/alerts/custom_snackbar.dart';
import 'package:flutter/material.dart';
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

    final result = await Share.shareXFiles(
      [
        XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'qr_code.png',
        ),
      ],
      text: 'qr.share_qr_text'.tr(),
      subject: 'qr.share_subject'.tr(),
    );

    if (context.mounted) {
      if (result.status == ShareResultStatus.success) {
        context.showSuccessSnackBar('qr.share_success'.tr());
      } else if (result.status == ShareResultStatus.unavailable) {
        context.showWarningSnackBar('qr.share_unavailable'.tr());
      }
    }
  } catch (e) {
    if (context.mounted) {
      context.showErrorSnackBar('qr.share_error'.tr());
    }
  }
}
