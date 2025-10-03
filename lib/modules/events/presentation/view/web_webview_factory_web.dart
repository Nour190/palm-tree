// lib/modules/events/presentation/view/web_webview_factory_web.dart
// Web-only implementation. Uses dart:html and ui.platformViewRegistry.
import 'dart:html' as html;
import 'dart:ui' as ui; // web-only

void registerIFrame(String viewId, String url) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewId, (int viewIdInt) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
    // Tune sandbox attributes if needed; remove attributes you require.
      ..setAttribute('sandbox', 'allow-same-origin allow-scripts allow-forms allow-popups allow-modals')
      ..allow = 'camera; microphone; autoplay; fullscreen; clipboard-write;';
    return iframe;
  });
}
