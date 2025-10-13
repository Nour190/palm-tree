import 'package:baseqat/core/resourses/color_manager.dart';
import 'package:baseqat/modules/programs/presentation/theme/programs_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:easy_localization/easy_localization.dart';

class VirtualTourView extends StatefulWidget {
  const VirtualTourView({super.key, this.url = 'https://www.3dvista.com/en/'});

  final String url;

  @override
  State<VirtualTourView> createState() => _VirtualTourViewState();
}

class _VirtualTourViewState extends State<VirtualTourView> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  int _progress = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final borderRadius = ProgramsLayout.radius20(context);

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _reload);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              allowsInlineMediaPlayback: true,
              supportZoom: false,
              mediaPlaybackRequiresUserGesture: true,
            ),
            onWebViewCreated: (controller) => _controller = controller,
            onLoadStart: (_, __) => setState(() {
              _isLoading = true;
              _error = null;
            }),
            onLoadStop: (_, __) => setState(() => _isLoading = false),
            onProgressChanged: (_, progress) =>
                setState(() => _progress = progress),
            onReceivedError: (_, request, error) {
              if (request.isForMainFrame ?? false) {
                setState(() {
                  _error = error.description;
                  _isLoading = false;
                });
              }
            },
            onReceivedHttpError: (_, request, response) {
              if ((request.isForMainFrame ?? false) &&
                  (response.statusCode ?? 0) >= 400) {
                setState(() {
                  final status =
                      (response.statusCode ?? 0).toString();
                  _error = 'programs.virtual_tour.http_error'.tr(
                    args: [status],
                  );
                  _isLoading = false;
                });
              }
            },
          ),
          if (_isLoading) _LoadingOverlay(progress: _progress),
        ],
      ),
    );
  }

  void _reload() {
    setState(() {
      _error = null;
      _isLoading = true;
      _progress = 0;
    });
    _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(widget.url)));
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final localeName = context.locale.toLanguageTag();
    final percentLabel =
        NumberFormat.percentPattern(localeName).format(progress / 100);
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ProgramsLayout.size(context, 56),
              height: ProgramsLayout.size(context, 56),
              child: CircularProgressIndicator(
                value: progress == 0 ? null : progress / 100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.primaryColor,
                ),
              ),
            ),
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
            Text(
              'programs.virtual_tour.loading'.tr(),
              style: ProgramsTypography.bodyPrimary(
                context,
              ).copyWith(color: AppColor.gray600),
            ),
            SizedBox(height: ProgramsLayout.spacingSmall(context)),
            Text(
              percentLabel,
              style: ProgramsTypography.bodySecondary(
                context,
              ).copyWith(color: AppColor.gray500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final padding = ProgramsLayout.sectionPadding(context);
    final radius = ProgramsLayout.radius20(context);

    return Center(
      child: Container(
        margin: padding,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColor.gray50,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColor.gray200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_off,
              color: AppColor.gray600,
              size: ProgramsLayout.size(context, 40),
            ),
            SizedBox(height: ProgramsLayout.spacingLarge(context)),
            Text(
              'programs.virtual_tour.unavailable_title'.tr(),
              style: ProgramsTypography.headingMedium(
                context,
              ).copyWith(color: AppColor.gray900),
            ),
            SizedBox(height: ProgramsLayout.spacingMedium(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ProgramsTypography.bodySecondary(
                context,
              ).copyWith(color: AppColor.gray600),
            ),
            SizedBox(height: ProgramsLayout.spacingLarge(context)),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('programs.actions.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
