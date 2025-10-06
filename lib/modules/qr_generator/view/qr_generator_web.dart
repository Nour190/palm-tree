import 'dart:html' as html;
import 'dart:typed_data';

String createObjectUrl(Uint8List bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  return url;
}

void revokeObjectUrl(String url) {
  html.Url.revokeObjectUrl(url);
}

void triggerDownload(String url, String filename) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
}