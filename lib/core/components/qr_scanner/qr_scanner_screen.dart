import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:baseqat/core/responsive/size_ext.dart';
import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/core/resourses/style_manager.dart';
import 'package:permission_handler/permission_handler.dart';


class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({
    super.key,
    required this.onCodeScanned,
    this.title,
    this.subtitle,
  });

  final Function(String artworkId) onCodeScanned;
  final String? title;
  final String? subtitle;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _hasPermission = false;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        setState(() {
          _hasPermission = false;
          _errorMessage = 'camera_permission_denied'.tr();
        });
        return;
      }
    }

    setState(() {
      _hasPermission = true;
    });

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isScanning = false;
    });


    String artworkId = _extractArtworkId(code);

    _controller?.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sW),
            SizedBox(width: 8.sW),
            Expanded(
              child: Text('qr_scanned_successfully'.tr()),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        widget.onCodeScanned(artworkId);
      }
    });
  }

  String _extractArtworkId(String code) {
    if (code.startsWith('http://') || code.startsWith('https://')) {
      final uri = Uri.tryParse(code);
      if (uri != null) {
        final segments = uri.pathSegments;
        if (segments.length >= 2 &&
            (segments[0] == 'artwork' || segments[0] == 'artwork_details')) {
          return segments[1];
        }
        if (segments.length == 1 && segments[0].isNotEmpty) {
          return segments[0];
        }
        if (uri.queryParameters.containsKey('artworkId')) {
          return uri.queryParameters['artworkId']!;
        }
        if (uri.queryParameters.containsKey('id')) {
          return uri.queryParameters['id']!;
        }
      }
    }

    if (code.startsWith('{') && code.endsWith('}')) {
      try {
        final match = RegExp(r'"artworkId"\s*:\s*"([^"]+)"').firstMatch(code);
        if (match != null) {
          return match.group(1)!;
        }
      } catch (e) {
        // Ignore JSON parse errors
      }
    }

    // Otherwise, treat as direct ID
    return code.trim();
  }

  void _toggleFlash() {
    _controller?.toggleTorch();
  }

  Future<void> _restartScanning() async {
    setState(() {
      _isScanning = false;
      _isProcessing = false;
      _errorMessage = null;
      _hasPermission = false;
    });

    await _controller?.dispose();
    _controller = null;

    await _initializeScanner();

    if (_hasPermission && _controller != null) {
      setState(() {
        _isScanning = true;
      });
      await _controller?.start();
    }
  }

  void _goBack() {
    _controller?.dispose();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera view
            if (_hasPermission && _controller != null)
              MobileScanner(
                controller: _controller,
                onDetect: _handleBarcode,
                errorBuilder: (context, error, child) {
                  return _buildErrorView(error.errorDetails?.message ?? 'scanner_error'.tr());
                },
              )
            else if (_errorMessage != null)
              _buildErrorView(_errorMessage!),

            if (_isScanning) _buildScanningOverlay(),

            _buildTopBar(),

            // Bottom instructions
            if (_isScanning) _buildBottomInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sW, vertical: 12.sH),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _goBack,
              icon: Container(
                padding: EdgeInsets.all(8.sW),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24.sW,
                ),
              ),
            ),
            // Title
            Text(
              widget.title ?? 'scan_qr_code'.tr(),
              style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                color: Colors.white,
              ),
            ),
            // Flash toggle button
            if (!kIsWeb && _hasPermission)
              IconButton(
                onPressed: _toggleFlash,
                icon: Container(
                  padding: EdgeInsets.all(8.sW),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 24.sW,
                  ),
                ),
              )
            else
              SizedBox(width: 48.sW),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: Center(
        child: Container(
          width: 280.sW,
          height: 280.sH,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColor.primaryColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // Corner decorations
              ..._buildCornerDecorations(),
              // Scanning line animation
              _buildScanningLine(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerDecorations() {
    const cornerSize = 30.0;
    const cornerThickness = 4.0;

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
              left: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
            ),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
              right: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
            ),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
              left: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
            ),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
              right: BorderSide(color: AppColor.primaryColor, width: cornerThickness),
            ),
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanningLine() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * 280.sH,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColor.primaryColor,
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isScanning) {
          setState(() {}); // Restart animation
        }
      },
    );
  }

  Widget _buildBottomInstructions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(24.sW),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 48.sW,
            ),
            SizedBox(height: 16.sH),
            Text(
              widget.subtitle ?? 'align_qr_code_instruction'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.title16RegularInter.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.sH),
            Text(
              'qr_scan_tip'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.sW),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64.sW,
              ),
              SizedBox(height: 24.sH),
              Text(
                'scanner_error'.tr(),
                style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.sH),
              Text(
                message,
                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.sH),

            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final scanAreaSize = 280.0;
    final scanAreaRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
