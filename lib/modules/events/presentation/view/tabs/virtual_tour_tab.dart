import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../../../core/resourses/color_manager.dart';
import '../../../../../core/resourses/style_manager.dart';
import '../../../../../core/responsive/size_ext.dart';

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
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;
  int _loadingProgress = 0;
  int _crashCount = 0;
  static const int _maxCrashRetries = 2;

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(widget.url),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            useHybridComposition: false,
            allowsInlineMediaPlayback: true,
            mediaPlaybackRequiresUserGesture: true,
            supportZoom: true,
            builtInZoomControls: true,
            displayZoomControls: false,
            useShouldOverrideUrlLoading: false,
            transparentBackground: false,
            hardwareAcceleration: false,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            cacheEnabled: true,
            cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
            clearCache: false,
            thirdPartyCookiesEnabled: true,
            allowContentAccess: true,
            allowFileAccess: true,
            disableVerticalScroll: false,
            disableHorizontalScroll: false,
            minimumFontSize: 8,
            supportMultipleWindows: false,
            verticalScrollBarEnabled: true,
            horizontalScrollBarEnabled: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onLoadStop: (controller, url) {
            setState(() {
              _isLoading = false;
            });
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onRenderProcessGone: (controller, detail) {
            _crashCount++;

            if (_crashCount <= _maxCrashRetries) {
              // Auto-retry for first few crashes
              setState(() {
                _isLoading = true;
              });

              // Reload after a short delay
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  _webViewController?.reload();
                }
              });
            } else {
              // Show error after max retries
              setState(() {
                _isLoading = false;
                _errorMessage = 'The virtual tour content is too heavy for this device. '
                    'Try using a lighter browser or reducing graphics quality.';
              });
            }
            return null;
          },
          onReceivedError: (controller, request, error) {
            if (request.isForMainFrame!) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to load: ${error.description}';
              });
            }
          },
          onReceivedHttpError: (controller, request, errorResponse) {
            if (request.isForMainFrame! && errorResponse.statusCode! >= 400) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'HTTP Error ${errorResponse.statusCode}: Unable to load the page';
              });
            }
          },
          onConsoleMessage: (controller, consoleMessage) {
            if (kDebugMode) {
              print('[WebView Console] ${consoleMessage.message}');
            }
          },
        ),
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
            if (_crashCount > 0) ...[
              SizedBox(height: 12.sH),
              Text(
                'Retry attempt $_crashCount of $_maxCrashRetries',
                style: TextStyleHelper.instance.body14RegularInter.copyWith(
                  color: AppColor.gray400,
                ),
              ),
            ],
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
                  _crashCount = 0;
                });
                _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(widget.url)),
                );
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
