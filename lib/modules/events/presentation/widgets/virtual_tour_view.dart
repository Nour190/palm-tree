import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../core/resourses/color_manager.dart';
import '../../../../core/resourses/style_manager.dart';
import '../../../../core/responsive/size_ext.dart';

class VirtualTourView extends StatefulWidget {
  final String url;
  
  const VirtualTourView({
    super.key,
    this.url = 'https://www.3dvista.com/en/',
  });

  @override
  State<VirtualTourView> createState() => _VirtualTourViewState();
}

class _VirtualTourViewState extends State<VirtualTourView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Create platform-specific parameters
    late final PlatformWebViewControllerCreationParams params;
    
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColor.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation within the webview
            return NavigationDecision.navigate;
          },
        ),
      );

    // Platform-specific configurations
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // Load the URL
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColor.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60.sW,
              height: 60.sH,
              child: CircularProgressIndicator(
                value: _loadingProgress / 100,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 16.sH),
            Text(
              'Loading Virtual Tour...',
              style: TextStyleHelper.instance.body16MediumInter.copyWith(
                color: AppColor.gray600,
              ),
            ),
            SizedBox(height: 8.sH),
            Text(
              '$_loadingProgress%',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24.sSp),
        padding: EdgeInsets.all(20.sSp),
        decoration: BoxDecoration(
          color: AppColor.gray50,
          border: Border.all(color: AppColor.gray200),
          borderRadius: BorderRadius.circular(12.sSp),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColor.gray700,
              size: 48.sSp,
            ),
            SizedBox(height: 16.sH),
            Text(
              'Failed to Load Virtual Tour',
              style: TextStyleHelper.instance.headline20BoldInter.copyWith(
                color: AppColor.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.sH),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: TextStyleHelper.instance.body14RegularInter.copyWith(
                color: AppColor.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.sH),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _controller.loadRequest(Uri.parse(widget.url));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: AppColor.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.sW,
                  vertical: 12.sH,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
