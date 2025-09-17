// lib/utils/web_utils_web.dart
import 'dart:html' as html;

/// Cleans the browser URL after an OAuth redirect so that
/// back button doesn't return to the OAuth fragment (access_token/code).
///
/// This works both in debug and release builds.
///
/// If you use hash-based routing (HashUrlStrategy) we also clear `location.hash`.
void clearWebAuthFragment() {
  print('clearWebAuthFragment called (web)'); // تأكد ظهور هذا في Console المتصفح
  try {
    final uri = Uri.base;

    // Build a "clean" URL: keep path + query (without fragment)
    final cleanPath = uri.path.isEmpty ? '/' : uri.path;
    final cleanQuery = uri.hasQuery ? '?${uri.query}' : '';
    final cleanUrl = '$cleanPath$cleanQuery';

    // Replace current history entry with the clean URL (no reload)
    html.window.history.replaceState(null, '', cleanUrl);

    // If your app uses hash routing (eg: #/route), also clear the hash part.
    // Clearing the hash ensures the fragment left by OAuth (e.g. access_token=...) is removed.
    if (html.window.location.hash.isNotEmpty) {
      html.window.location.hash = '';
    }
  } catch (e) {
    print('clearWebAuthFragment error: $e');
    // ignore errors in environments where dart:html isn't available or replaceState fails
  }
}
