import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';

/// Utility class for generating QR codes for artworks
class QRCodeGenerator {
  /// Generates QR data string from artwork ID
  /// Format matches what QRScannerScreen expects to parse
  static String generateArtworkQRData(String artworkId) {
    // Return direct ID format (simplest and most reliable)
    // The scanner supports: direct ID, URL, or JSON format
    return artworkId;
  }

  /// Builds a QR code widget with optional label
  static Widget buildQRCodeWidget({
    required String artworkId,
    double? size,
    bool? showLabel,
  }) {
    final qrData = generateArtworkQRData(artworkId);
    final qrSize = size ?? 250.0;
    final displayLabel = showLabel ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(16.sW),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: qrSize,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            padding: EdgeInsets.all(8.sW),
          ),
        ),
        if (displayLabel) ...[
          SizedBox(height: 12.sH),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.sW,
              vertical: 8.sH,
            ),
            decoration: BoxDecoration(
              color: AppColor.backgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'qr.artwork_id'.tr(args: [artworkId]),
              style: TextStyleHelper.instance.body12MediumInter.copyWith(
                color: AppColor.gray600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Generates a shareable message for QR code
  static String generateShareMessage(String artworkId, String artworkName) {
    return 'qr.share_message'.tr(args: [artworkName, artworkId]);
  }
}
