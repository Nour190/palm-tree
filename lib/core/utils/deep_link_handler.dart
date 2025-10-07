import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:baseqat/modules/artwork_details/presentation/view/tabs/artwork_details_tabs_view.dart';
import 'package:baseqat/core/resourses/constants_manager.dart';
import 'package:baseqat/core/resourses/navigation_manger.dart';

/// Handles deep linking for the app
/// Supports URLs like: https://yourapp.com/artwork/artwork-id-123
class DeepLinkHandler {
  static StreamSubscription? _linkSubscription;
  static BuildContext? _context;

  /// Initialize deep link handling
  static Future<void> initialize(BuildContext context) async {
    _context = context;

    // Handle initial link (when app is opened from a link)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Handle link streams (when app is already running)
    if (!kIsWeb) {
      _linkSubscription = linkStream.listen(
        (String? link) {
          if (link != null) {
            _handleDeepLink(link);
          }
        },
        onError: (err) {
          debugPrint('Error listening to link stream: $err');
        },
      );
    }
  }

  /// Dispose deep link handler
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _context = null;
  }

  /// Handle incoming deep link
  static void _handleDeepLink(String link) {
    if (_context == null) return;

    debugPrint('[DeepLink] Received: $link');

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    // Extract artwork ID from URL
    // Supports: /artwork/{id}, /artwork_details/{id}, /{id}
    final segments = uri.pathSegments;
    
    String? artworkId;
    
    if (segments.length >= 2 &&
        (segments[0] == 'artwork' || segments[0] == 'artwork_details')) {
      artworkId = segments[1];
    } else if (segments.length == 1 && segments[0].isNotEmpty) {
      artworkId = segments[0];
    } else if (uri.queryParameters.containsKey('artworkId')) {
      artworkId = uri.queryParameters['artworkId'];
    } else if (uri.queryParameters.containsKey('id')) {
      artworkId = uri.queryParameters['id'];
    }

    if (artworkId != null && artworkId.isNotEmpty) {
      debugPrint('[DeepLink] Navigating to artwork: $artworkId');
      
      // Navigate to artwork details
      navigateTo(
        _context!,
        ArtWorkDetailsScreen(
          artworkId: artworkId,
          userId: AppConstants.userIdValue ?? "",
        ),
      );
    } else {
      debugPrint('[DeepLink] Could not extract artwork ID from: $link');
    }
  }

  /// Manually handle a deep link (useful for testing)
  static void handleLink(BuildContext context, String link) {
    _context = context;
    _handleDeepLink(link);
  }
}
