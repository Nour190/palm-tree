import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ImageCacheService {
  static const String _imageCacheBox = 'image_cache_box';
  static const Duration _cacheExpiry = Duration(days: 7);

  /// Initialize the image cache box
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_imageCacheBox)) {
      await Hive.openBox(_imageCacheBox);
    }
  }

  /// Generate a cache key from URL
  static String _getCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Cache an image from URL
  static Future<void> cacheImage(String url) async {
    try {
      final box = Hive.box(_imageCacheBox);
      final key = _getCacheKey(url);

      // Check if already cached and not expired
      if (box.containsKey(key)) {
        final cached = box.get(key) as Map?;
        if (cached != null) {
          final cachedAt = DateTime.parse(cached['cachedAt'] as String);
          if (DateTime.now().difference(cachedAt) < _cacheExpiry) {
            debugPrint('[ImageCache] Image already cached: $url');
            return;
          }
        }
      }

      // Download image
      debugPrint('[ImageCache] Downloading image: $url');
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = {
          'url': url,
          'bytes': response.bodyBytes,
          'cachedAt': DateTime.now().toIso8601String(),
        };

        await box.put(key, data);
        debugPrint('[ImageCache] Image cached successfully: $url');
      } else {
        debugPrint('[ImageCache] Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ImageCache] Error caching image: $e');
    }
  }

  /// Get cached image bytes
  static Uint8List? getCachedImage(String url) {
    try {
      final box = Hive.box(_imageCacheBox);
      final key = _getCacheKey(url);

      if (!box.containsKey(key)) {
        return null;
      }

      final cached = box.get(key) as Map?;
      if (cached == null) return null;

      // Check expiry
      final cachedAt = DateTime.parse(cached['cachedAt'] as String);
      if (DateTime.now().difference(cachedAt) >= _cacheExpiry) {
        box.delete(key);
        return null;
      }

      return cached['bytes'] as Uint8List?;
    } catch (e) {
      debugPrint('[ImageCache] Error getting cached image: $e');
      return null;
    }
  }

  /// Check if image is cached
  static bool isCached(String url) {
    try {
      final box = Hive.box(_imageCacheBox);
      final key = _getCacheKey(url);
      return box.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  /// Cache multiple images in parallel
  static Future<void> cacheImages(List<String> urls) async {
    await Future.wait(
      urls.map((url) => cacheImage(url)),
      eagerError: false,
    );
  }

  /// Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    try {
      final box = Hive.box(_imageCacheBox);
      final keysToDelete = <String>[];

      for (var key in box.keys) {
        final cached = box.get(key) as Map?;
        if (cached != null) {
          final cachedAt = DateTime.parse(cached['cachedAt'] as String);
          if (DateTime.now().difference(cachedAt) >= _cacheExpiry) {
            keysToDelete.add(key as String);
          }
        }
      }

      for (var key in keysToDelete) {
        await box.delete(key);
      }

      debugPrint('[ImageCache] Cleared ${keysToDelete.length} expired entries');
    } catch (e) {
      debugPrint('[ImageCache] Error clearing expired cache: $e');
    }
  }

  /// Clear all cached images
  static Future<void> clearAll() async {
    final box = Hive.box(_imageCacheBox);
    await box.clear();
    debugPrint('[ImageCache] All cached images cleared');
  }

  /// Get cache size in bytes
  static int getCacheSize() {
    try {
      final box = Hive.box(_imageCacheBox);
      int totalSize = 0;

      for (var key in box.keys) {
        final cached = box.get(key) as Map?;
        if (cached != null && cached['bytes'] != null) {
          totalSize += (cached['bytes'] as Uint8List).length;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
